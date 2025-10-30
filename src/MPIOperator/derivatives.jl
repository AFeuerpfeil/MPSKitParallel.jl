function MPSKit.C_hamiltonian(site::Int, below, operator::MPIOperator, above, envs)
    return MPIOperator(MPSKit.C_hamiltonian(site, below, parent(operator), above, envs))
end

function MPSKit.AC_hamiltonian(site::Int, below, operator::MPIOperator, above, envs)
    return MPIOperator(MPSKit.AC_hamiltonian(site, below, parent(operator), above, envs))
end

function MPSKit.AC2_hamiltonian(site::Int, below, operator::MPIOperator, above, envs)
    return MPIOperator(MPSKit.AC2_hamiltonian(site, below, parent(operator), above, envs))
end

function MPSKit.C_projection(site::Int, below, operator::MPIOperator, above, envs)
    return MPIOperator(MPSKit.C_projection(site, below, parent(operator), above, envs))
end

function MPSKit.AC_projection(site::Int, below, operator::MPIOperator, above, envs)
    return MPIOperator(MPSKit.AC_projection(site, below, parent(operator), above, envs))
end

function MPSKit.AC2_projection(site::Int, below, operator::MPIOperator, above, envs)
    return MPIOperator(MPSKit.AC2_projection(site, below, parent(operator), above, envs))
end