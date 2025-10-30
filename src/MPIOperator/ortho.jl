function MPSKit.left_orthogonalize!(
    H::MPIOperator{FiniteMPOHamiltonian}, i::Int; kwargs...
)
    return MPIOperator(MPSKit.left_orthogonalize!(parent(H), i; kwargs...), H.reduction)
end

function MPSKit.right_orthogonalize!(
    H::MPIOperator{FiniteMPOHamiltonian}, i::Int; kwargs...
)
    return MPIOperator(MPSKit.right_orthogonalize!(parent(H), i; kwargs...), H.reduction)
end