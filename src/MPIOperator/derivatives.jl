# This does not work, as this is not a more specific type than the generic constructors in MPSKit, so it will never be executed:

# @forward_3_1_astype MPIOperator.parent MPSKit.C_hamiltonian, MPSKit.AC_hamiltonian, MPSKit.AC2_hamiltonian, MPSKit.C_projection, MPSKit.AC_projection, MPSKit.AC2_projection

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