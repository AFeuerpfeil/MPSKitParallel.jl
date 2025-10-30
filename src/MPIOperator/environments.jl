@forward_1_1 MPIOperator.parent MPSKit.environments, MPSKit.initialize_environments, MPSKit.environment_alg
@forward_2_1 MPIOperator.parent MPSKit.recalculate!, MPSKit.issamespace, MPSKit.compute_leftenvs!, MPSKit.compute_rightenvs!

# function MPSKit.environments(
#     below, operator::MPIOperator, above; kwargs...
# )
#     return MPSKit.environments(below, parent(operator), above; kwargs...)
# end
# function MPSKit.environments(
#     below, operator::MPIOperator; kwargs...
# )
#     return MPSKit.environments(below, parent(operator); kwargs...)
# end

# function MPSKit.recalculate!(envs::AbstractMPSEnvironments, below, operator::MPIOperator, above = below; kwargs...)
#     return MPSKit.recalculate!(envs, below, parent(operator), above; kwargs...)
# end

# function MPSKit.issamespace(
#     envs::AbstractMPSEnvironments, below, operator::MPIOperator, above = below
# )
#     return MPSKit.issamespace(envs, below, parent(operator), above)
# end

# function MPSKit.initialize_environments(
#     below, operator::MPIOperator,
#     above = below; kwargs...
# )
#     return MPSKit.initialize_environments(below, parent(operator), above; kwargs...)
# end

# function MPSKit.compute_leftenvs!(
#     envs::AbstractMPSEnvironments, below, operator::MPIOperator, above, alg; kwargs...
# )
#     return MPSKit.compute_leftenvs!(envs, below, parent(operator), above, alg; kwargs...)
# end

# function MPSKit.compute_rightenvs!(
#     envs::AbstractMPSEnvironments, below, operator::MPIOperator, above, alg; kwargs...
# )
#     return MPSKit.compute_rightenvs!(envs, below, parent(operator), above, alg; kwargs...)
# end

function TensorKit.normalize!(
    envs::AbstractMPSEnvironments, below, operator::MPIOperator, above; kwargs...
)
    return TensorKit.normalize!(envs, below, parent(operator), above; kwargs...)
end

# function MPSKit.environment_alg(
#         below, ::Union{MPIOperator{InfiniteMPO}, MPIOperator{MultilineMPO}},
#         above;
#         kwargs...
#     )
#     return MPSKit.environment_alg(below, parent(operator), above; kwargs...)
# end
# function MPSKit.environment_alg(
#         below, ::MPIOperator{InfiniteMPOHamiltonian}, above; kwargs...
#     )
#     return MPSKit.environment_alg(below, parent(operator), above; kwargs...)
# end

function TensorKit.normalize!(
        envs::InfiniteEnvironments, below::InfiniteMPS, operator::MPIOperator{InfiniteMPO},
        above::InfiniteMPS
    )
    for i in 1:length(operator)
        normalize!(envs.GRs[i])
        Hc = C_hamiltonian(i, below, operator, above, envs)
        λ = dot(below.C[i], Hc * above.C[i])
        λ = MPI.allreduce(λ, +, MPI.COMM_WORLD)
        scale!(envs.GLs[i + 1], inv(λ))
    end
    return envs
end