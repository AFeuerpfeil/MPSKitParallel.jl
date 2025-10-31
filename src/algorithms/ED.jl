function MPSKit.exact_diagonalization(
        H::MPIOperator{<:FiniteMPOHamiltonian};
        sector = one(sectortype(H)), num::Int = 1, which::Symbol = :SR,
        alg = Defaults.alg_eigsolve(; dynamic_tols = false)
    )
    L = length(H)
    @assert L > 1 "FiniteMPOHamiltonian must have length > 1"
    middle_site = (L >> 1) + 1

    T = storagetype(eltype(H))
    TA = tensormaptype(spacetype(H), 2, 1, T)

    # fuse from left to right
    ALs = Vector{Union{Missing, TA}}(missing, L)
    left = oneunit(spacetype(H))
    for i in 1:(middle_site - 1)
        P = physicalspace(H, i)
        ALs[i] = isomorphism(T, left ⊗ P ← fuse(left ⊗ P))
        left = right_virtualspace(ALs[i])
    end

    # fuse from right to left
    ARs = Vector{Union{Missing, TA}}(missing, L)
    right = spacetype(H)(sector => 1)
    for i in reverse((middle_site + 1):L)
        P = physicalspace(H, i)
        ARs[i] = _transpose_front(isomorphism(T, fuse(right ⊗ P') ← right ⊗ P'))
        right = left_virtualspace(ARs[i])
    end

    # center
    ACs = Vector{Union{Missing, TA}}(missing, L)
    P = physicalspace(H, middle_site)
    ACs[middle_site] = rand!(similar(ALs[1], left ⊗ P ← right))

    TB = tensormaptype(spacetype(H), 1, 1, T)
    Cs = Vector{Union{Missing, TB}}(missing, L + 1)
    state = FiniteMPS(ALs, ARs, ACs, Cs)
    envs = environments(state, H)

    # optimize the middle site
    # Because the MPS is full rank - this is equivalent to the full Hamiltonian
    AC₀ = state.AC[middle_site]
    H_ac = AC_hamiltonian(middle_site, state, H, state, envs)
    vals, vecs, convhist = eigsolve(H_ac, AC₀, num, which, alg)

    # repack eigenstates
    state_vecs = map(vecs) do v
        cs = copy(state)
        cs.AC[middle_site] = v
        return cs
    end

    return vals, state_vecs, convhist
end