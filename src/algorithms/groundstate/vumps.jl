
function MPSKit.localupdate_step!(
        it::IterativeSolver{<:VUMPS{S, MPIOperator{O}, E}}, state, scheduler = MPSKit.Defaults.scheduler[]
    ) where {S, O, E}
    alg_eigsolve = updatetol(it.alg_eigsolve, state.iter, state.ϵ)
    alg_orth = MPSKit.Defaults.alg_qr()

    mps = state.mps
    src_Cs = mps isa Multiline ? eachcol(mps.C) : mps.C
    src_ACs = mps isa Multiline ? eachcol(mps.AC) : mps.AC
    ACs = similar(mps.AC)
    dst_ACs = mps isa Multiline ? eachcol(ACs) : ACs

    tforeach(eachsite(mps), src_ACs, src_Cs; scheduler) do site, AC₀, C₀
        dst_ACs[site] = MPSKit._localupdate_vumps_step!(
            site, mps, state.operator, state.envs, AC₀, C₀;
            parallel = false, alg_orth, state.which, alg_eigsolve
        )
        return nothing
    end

    return ACs
end

function MPSKit._localupdate_vumps_step!(
        site, mps, operator::MPIOperator, envs, AC₀, C₀;
        parallel::Bool = false, alg_orth = MPSKit.Defaults.alg_qr(),
        alg_eigsolve = MPSKit.Defaults.eigsolver, which
    )
    if !parallel
        Hac = AC_hamiltonian(site, mps, operator, mps, envs)
        _, AC = fixedpoint(Hac, AC₀, which, alg_eigsolve)
        Hc = C_hamiltonian(site, mps, operator, mps, envs)
        _, C = fixedpoint(Hc, C₀, which, alg_eigsolve)
        return mpi_regauge!(AC, C; alg = alg_orth)
    end

    local AC, C
    @sync begin
        @spawn begin
            Hac = AC_hamiltonian(site, mps, operator, mps, envs)
            _, AC = fixedpoint(Hac, AC₀, which, alg_eigsolve)
        end
        @spawn begin
            Hc = C_hamiltonian(site, mps, operator, mps, envs)
            _, C = fixedpoint(Hc, C₀, which, alg_eigsolve)
        end
    end
    return mpi_regauge!(AC, C; alg = alg_orth)
end

function MPSKit.gauge_step!(it::IterativeSolver{<:VUMPS{S, MPIOperator{O}, E}}, state, ACs::AbstractVector) where {S, O, E}
    alg_gauge = updatetol(it.alg_gauge, state.iter, state.ϵ)
    if mpi_is_root()
        psi = InfiniteMPS(ACs, state.mps.C[end]; alg_gauge.tol, alg_gauge.maxiter)
    else
        psi = nothing
    end
    psi = large_bcast(psi, 0, MPI.COMM_WORLD)
    return psi
end

function MPSKit.gauge_step!(it::IterativeSolver{<:VUMPS{S, MPIOperator{O}, E}}, state, ACs::AbstractMatrix) where {S, O, E}
    alg_gauge = updatetol(it.alg_gauge, state.iter, state.ϵ)
    if mpi_is_root()
        psi = MultilineMPS(ACs, @view(state.mps.C[:, end]); alg_gauge.tol, alg_gauge.maxiter)
    else
        psi = nothing
    end
    psi = large_bcast(psi, 0, MPI.COMM_WORLD)
    return psi
end