# This does not work, as this is not a more specific type than the generic constructors in MPSKit, so it will never be executed:
# @forward_3_1_astype MPIOperator.parent MPSKit.C_hamiltonian, MPSKit.AC_hamiltonian, MPSKit.AC2_hamiltonian, MPSKit.C_projection, MPSKit.AC_projection, MPSKit.AC2_projection

# In case the scheduler is parallel, we create new communicators for each site to separate the communication. Therefore, the MPIOperator has a Vector{MPI.Comm}, which we parse to the MPO derivatives here.
# In that case, it is crucial that MPI.ThreadLevel(3) is used, otherwise the communication will deadlock or fail!

function MPSKit.C_hamiltonian(site::Int, below, operator::MPIOperator{O, F}, above, envs) where {O, F}
    return MPIOperator(MPSKit.C_hamiltonian(site, below, parent(operator), above, envs), operator.reduction, operator.comm[site])
end

function MPSKit.AC_hamiltonian(site::Int, below, operator::MPIOperator{O, F}, above, envs) where {O, F}
    return MPIOperator(MPSKit.AC_hamiltonian(site, below, parent(operator), above, envs), operator.reduction, operator.comm[site])
end

function MPSKit.AC2_hamiltonian(site::Int, below, operator::MPIOperator{O, F}, above, envs) where {O, F}
    return MPIOperator(MPSKit.AC2_hamiltonian(site, below, parent(operator), above, envs), operator.reduction, operator.comm[site])
end

function MPSKit.C_projection(site::Int, below, operator::MPIOperator{O, F}, above, envs) where {O, F}
    return MPIOperator(MPSKit.C_projection(site, below, parent(operator), above, envs), operator.reduction, operator.comm[site])
end

function MPSKit.AC_projection(site::Int, below, operator::MPIOperator{O, F}, above, envs) where {O, F}
    return MPIOperator(MPSKit.AC_projection(site, below, parent(operator), above, envs), operator.reduction, operator.comm[site])
end

function MPSKit.AC2_projection(site::Int, below, operator::MPIOperator{O, F}, above, envs) where {O, F}
    return MPIOperator(MPSKit.AC2_projection(site, below, parent(operator), above, envs), operator.reduction, operator.comm[site])
end