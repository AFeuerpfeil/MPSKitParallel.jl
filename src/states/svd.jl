function mpi_svd_trunc!(A; kwargs...)
    if mpi_is_root()
        U, S, Vt = svd_trunc!(A; kwargs...)
    else
        U = nothing
        S = nothing
        Vt = nothing
    end
    U = large_bcast(U, 0, MPI.COMM_WORLD)
    S = large_bcast(S, 0, MPI.COMM_WORLD)
    Vt = large_bcast(Vt, 0, MPI.COMM_WORLD)
    return U, S, Vt
end