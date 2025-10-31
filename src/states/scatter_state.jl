function scatter_state(psi::AbstractMPS)
    psi = large_bcast(psi, 0, MPI.COMM_WORLD)
    return psi
end

function set_entry!(psi::AbstractMPS, A::TensorMap, sym::Symbol, i::Int)
    A_shared = large_bcast(A, 0, MPI.COMM_WORLD)
    return getproperty(psi, sym)[i] = A_shared
end
function set_entry!(psi::AbstractMPS, A::AbstractVector{<:TensorMap}, sym::Symbol)
    A_shared = large_bcast(A, 0, MPI.COMM_WORLD)
    return getproperty(psi, sym) .= A_shared
end