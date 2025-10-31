function Base.getproperty(ψ::InfiniteMPS, prop::Symbol)
    return MPIPropertyWrapper(getfield(ψ, prop))
end

## Issue: Base.getproperty is already overloaded for MultilineMPS, QP, MultilineQP, WindowMPS, FiniteMPS