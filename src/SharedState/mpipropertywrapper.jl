struct MPIPropertyWrapper{A}
    property::A
end

function Base.setindex!(wrapper::MPIPropertyWrapper, A::TensorMap, i::Int)
    mpi_is_root() && (wrapper.property[i] = A)
    A_shared = MPI.Bcast(A, 0, MPI.COMM_WORLD)
    wrapper.property[i] = A_shared
    return wrapper
end

Base.getindex(wrapper::MPIPropertyWrapper, i::Int) = wrapper.property[i]
Base.length(wrapper::MPIPropertyWrapper) = length(wrapper.property)
Base.size(wrapper::MPIPropertyWrapper) = size(wrapper.property)

function Base.getproperty(ψ::AbstractSharedMPS, prop::Symbol)
    property_obj = getproperty(parent(ψ), prop)
    return MPIPropertyWrapper(property_obj)
end
