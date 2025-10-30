function mpi_barrier(blocking::Bool=true)
    blocking && MPI.Initializer() && (MPI.Barrier(MPI.COMM_WORLD))
    return nothing
end
function mpi_init()
    if !MPI.Initialized()
        MPI.Init()
    end
    return nothing
end
function mpi_size()
    if MPI.Initialized()
        return MPI.Comm_size(MPI.COMM_WORLD)
    else
        return 1
    end
end
function mpi_rank()
    if MPI.Initialized()
        return MPI.Comm_rank(MPI.COMM_WORLD)
    else
        return 0
    end
end
function mpi_is_root()
    return mpi_rank() == 0
end

function mpi_execute_on_root(F::Function, args...; blocking::Bool, kwargs...)
    mpi_blocking(blocking)
    if mpi_is_root()
        x = F(args...; kwargs...)
    else
        x = nothing
    end
    mpi_blocking(blocking)
    return x
end
function mpi_execute_on_root_and_bcast(F::Function, args...; blocking::Bool, kwargs...)
    mpi_blocking(blocking)
    if mpi_is_root()
        x = F(args...; kwargs...)
    else
        x = nothing
    end
    x = MPI.bcast(x, MPI.COMM_WORLD; root=0)
    return x
end