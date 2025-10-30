MPSKit._gaugecenter(::SharedFiniteMPS) = _gaugecenter(parent(ψ))

function Base.propertynames(::SharedFiniteMPS)
    return (:AL, :AR, :AC, :C, :center)
end