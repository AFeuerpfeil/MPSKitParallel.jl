import MPI: Comm, Buffer, Datatype, Status
using MPI

function send_mailbox(obj, comm::Comm; dest::Integer, tag::Integer=0)
    return send_mailbox(obj, dest, tag, comm)
end
function send_mailbox(obj, dest::Integer, tag::Integer, comm::Comm)
    buf = MPI.serialize(obj)
    return Send_mailbox(buf, dest, tag, comm)
end

function Send_mailbox(data, comm::Comm; dest::Integer, tag::Integer=Cint(0))
    return Send_mailbox(data, dest, tag, comm)
end

function Send_mailbox(buf::Buffer, dest::Integer, tag::Integer, comm::Comm)
    return Send_mailbox([buf], dest::Integer, tag::Integer, comm::Comm)
end

function Send_mailbox(buf::Vector{<:Buffer}, dest::Integer, tag::Integer, comm::Comm)
    # int MPI_Send(const void* buf, int count, MPI_Datatype datatype, int dest,
    #              int tag, MPI_Comm comm)
    counts = map(x -> x.count, buf)
    MPI.send(counts, comm; dest=dest, tag=tag)
    for i in eachindex(buf)
        MPI.Send(buf[i], comm; dest=dest, tag=tag + i * 1000)
    end
    return nothing
end
function Send_mailbox(
    arr::Union{Ref,AbstractArray}, dest::Integer, tag::Integer, comm::Comm
)
    ## here, we split array into portions of length<2^31
    Send_mailbox(Buffer_mailbox(arr), dest, tag, comm)
    return nothing
end
function Send_mailbox(obj::T, dest::Integer, tag::Integer, comm::Comm) where {T}
    buf = Ref{T}(obj)
    return Send_mailbox(buf, dest, tag, comm)
end
Buffer_mailbox(buf::Buffer) = buf
Buffer_mailbox(buf::Vector{Buffer}) = buf

function split_buffer_into_pieces(vec::Vector{UInt8}, N::Integer)
    len = length(vec)
    base_size = div(len, N)  # Base size of each piece
    remainder = mod(len, N) # Extra elements to distribute

    # Create the splits
    splits = Vector{Vector{UInt8}}(undef, N)
    start_idx = 1
    for i in 1:N
        # Calculate the size of the current piece
        current_size = base_size + (i <= remainder ? 1 : 0)
        end_idx = start_idx + current_size - 1

        # Slice the vector for the current piece
        splits[i] = vec[start_idx:end_idx]

        # Update the starting index for the next piece
        start_idx = end_idx + 1
    end

    return splits
end

function Buffer_mailbox(arr::Array)
    len = length(arr)
    len_max = typemax(Cint)
    number_of_sends = cld(len, len_max)
    arrs = split_buffer_into_pieces(arr, number_of_sends)
    return [
        MPI.Buffer(arrs[i], Cint(length(arrs[i])), Datatype(eltype(arr))) for
        i in eachindex(arrs)
    ]
end
function Buffer_mailbox(ref::Ref)
    return [MPI.Buffer(ref, Cint(1), Datatype(eltype(ref)))]
end

function recv_mailbox(
    comm::Comm,
    status=nothing;
    source::Integer=MPI.API.MPI_ANY_SOURCE[],
    tag::Integer=MPI.API.MPI_ANY_TAG[],
)
    return recv_mailbox(source, tag, comm, status)
end

function recv_mailbox(
    source::Integer, tag::Integer, comm::Comm, status::Union{Ref{Status},Nothing}
)
    ## First, we receive the size of the messages to preallocate the buffers
    buf_sizes = MPI.recv(comm; source=source, tag=tag)
    recv_buf = map(x -> Array{UInt8}(undef, x), buf_sizes)
    for i in eachindex(recv_buf)
        if !(tag == MPI.API.MPI_ANY_TAG[])
            tag_i = tag + i * 1000
        else
            tag_i = tag
        end
        MPI.Recv!(recv_buf[i], comm; source=source, tag=tag_i)
    end
    return MPI.deserialize(reduce(vcat, recv_buf))
end

function recv_mailbox(source::Integer, tag::Integer, comm::Comm, ::Type{Status})
    status = Ref(MPI.STATUS_ZERO)
    val = recv_mailbox(source, tag, comm, status)
    return val, status[]
end
