function MPSKit.environments(
    below, operator::MPIOperator, above; kwargs...
)
    return MPSKit.environments(below, parent(operator), above; kwargs...)
end
function MPSKit.environments(
    below, operator::MPIOperator; kwargs...
)
    return MPSKit.environments(below, parent(operator); kwargs...)
end

function MPSKit.recalculate!(envs::AbstractMPSEnvironments, below, operator::MPIOperator, above = below; kwargs...)
    return MPSKit.recalculate!(envs, below, parent(operator), above; kwargs...)
end

function MPSKit.issamespace(
    envs::AbstractMPSEnvironments, below, operator::MPIOperator, above = below
)
    return MPSKit.issamespace(envs, below, parent(operator), above)
end

function MPSKit.initialize_environments(
    below, operator::MPIOperator,
    above = below; kwargs...
)
    return MPSKit.initialize_environments(below, parent(operator), above; kwargs...)
end

function MPSKit.compute_leftenvs!(
    envs::AbstractMPSEnvironments, below, operator::MPIOperator, above, alg; kwargs...
)
    return MPSKit.compute_leftenvs!(envs, below, parent(operator), above, alg; kwargs...)
end

function MPSKit.compute_rightenvs!(
    envs::AbstractMPSEnvironments, below, operator::MPIOperator, above, alg; kwargs...
)
    return MPSKit.compute_rightenvs!(envs, below, parent(operator), above, alg; kwargs...)
end

function TensorKit.normalize!(
    envs::AbstractMPSEnvironments, below, operator::MPIOperator, above; kwargs...
)
    return TensorKit.normalize!(envs, below, parent(operator), above; kwargs...)
end
