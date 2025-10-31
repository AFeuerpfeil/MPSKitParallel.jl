import MPI: Comm, Buffer, Datatype, Status
using MPI
const _mpi_message_size_limit = typemax(Cint)
const _tag_shift = 1_000
function split_buffer(vec::Vector{UInt8})
    len = length(vec)
    N = cld(len, _mpi_message_size_limit)  # Number of pieces
    @show N
    if N == 1
        return [MPI.Buffer(vec)]
    end
    # Create the splits
    splits = Vector{Vector{UInt8}}(undef, N)
    start_idx = 1
    for i in 1:N
        end_idx = start_idx + _mpi_message_size_limit - 1

        # Slice the vector for the current piece
        splits[i] = vec[start_idx:end_idx]

        # Update the starting index for the next piece
        start_idx = end_idx + 1
    end
    splits[N] = vec[start_idx:end]
    return MPI.Buffer.(splits)
end

large_send(obj, comm::Comm; dest::Integer, tag::Integer=0) = large_send(obj, dest, tag, comm)
function large_send(obj, dest::Integer, tag::Integer, comm::Comm)
    buf = MPI.serialize(obj)
    buf = split_buffer(buf)
    return Large_send(buf, dest, tag, comm)
end

function Large_send(buf::Vector{MPI.Buffer}, dest::Integer, tag::Integer, comm::Comm)
    counts = map(x -> x.count, buf)
    MPI.send(counts, comm; dest=dest, tag=tag)
    for i in eachindex(buf)
        MPI.Send(buf[i], comm; dest=dest, tag=tag + i * _tag_shift)
    end
    return nothing
end

function large_receive(comm::Comm, status=nothing; source::Integer=MPI.API.MPI_ANY_SOURCE[], tag::Integer=MPI.API.MPI_ANY_TAG[])
    return large_receive(source, tag, comm, status)
end

function large_receive(source::Integer, tag::Integer, comm::Comm, status::Union{Ref{Status},Nothing})
    buf_sizes = MPI.recv(comm; source=source, tag=tag)
    if sum(buf_sizes) <= _mpi_message_size_limit
        return MPI.recv(comm; source=source, tag=tag + _tag_shift, status=status)
    end
    recv_buf = map(x -> Array{UInt8}(undef, x), buf_sizes)
    for i in eachindex(recv_buf)
        if !(tag == MPI.API.MPI_ANY_TAG[])
            tag_i = tag + i * _tag_shift
        else
            tag_i = tag
        end
        MPI.Recv!(recv_buf[i], comm; source=source, tag=tag_i)
    end
    return MPI.deserialize(reduce(vcat, recv_buf))
end

large_bcast(obj, comm::Comm; root::Integer=Cint(0)) = large_bcast(obj, root, comm)

function large_bcast(obj, root::Integer, comm::Comm)
    isroot = Comm_rank(comm) == root
    counts = Vector{Int}()
    if isroot
        buf = MPI.serialize(obj)
        buf = split_buffer(buf)
        counts = map(x -> x.count, buf)
    end
    Bcast!(counts, root, comm)
    if !isroot
        buf = [Array{UInt8}(undef, c) for c in counts]
    end
    for i in eachindex(buf)
        MPI.Bcast!(buf[i], root, comm)
    end
    if !isroot
        obj = MPI.deserialize(reduce(vcat, buf))
    end
    return obj
end

function large_allreduce(obj, op, comm::Comm; root::Integer=Cint(0))
    buf = nothing
    count = 0

    buf = MPI.serialize(obj)
    count = length(buf)

    counts = Allgather(count, MPI.COMM_WORLD)

    if all(counts .<= _mpi_message_size_limit)
        resbuf = MPI.allreduce(buf, op, comm)
        return MPI.deserialize(resbuf)
    end
    buf = split_buffer(buf)
    counts = map(x -> x.count, buf)
    counts = Gather(counts, MPI.COMM_WORLD; root = root)

    theta = nothing
    if mpi_is_root(root)
        theta = obj
        for i in 1:length(counts)-1
            theta = op(theta, large_receive(MPI.COMM_WORLD; source = i, tag = i))
        end
    else
        Large_send(buf, root, mpi_rank(), comm)
    end

    theta = large_bcast(theta, comm; root = root)
    return theta
end

function large_allreduce(obj, op::typeof(+), comm::Comm; root::Integer=Cint(0))
    buf = nothing
    count = 0

    buf = MPI.serialize(obj)
    count = length(buf)

    counts = MPI.Allgather(count, MPI.COMM_WORLD)

    if all(counts .<= _mpi_message_size_limit)
        resbuf = MPI.Allreduce(buf, op, comm)
        return MPI.deserialize(resbuf)
    end
    buf = split_buffer(buf)
    counts = map(x -> x.count, buf)
    counts = Gather(counts, MPI.COMM_WORLD; root = root)

    theta = nothing
    if mpi_is_root(root)
        theta = obj
        for i in 1:length(counts)-1
            theta .+= large_receive(MPI.COMM_WORLD; source = i, tag = i)
        end
    else
        Large_send(buf, root, mpi_rank(), comm)
    end

    theta = large_bcast(theta, comm; root = root)
    return theta
end