struct MPIPropertyWrapper{A<:AbstractVector}
    property::A
end

Base.parent(wrapper::MPIPropertyWrapper) = wrapper.property
function Base.setindex!(wrapper::MPIPropertyWrapper{B}, A::C, i::Int) where {B<:AbstractVector, C}
    A_shared = MPI.bcast(A, MPI.COMM_WORLD) ## TODO: Write own chunked version
    wrapper.property[i] = A_shared
    return parent(wrapper)
end

Base.getindex(wrapper::MPIPropertyWrapper, i::Int) = parent(wrapper)[i]
Base.getindex(wrapper::MPIPropertyWrapper, I) = parent(wrapper)[I]

function Base.show(io::IO, ::MIME"text/plain", op::MPIPropertyWrapper)
    show(io, MIME"text/plain"(), parent(op))
end
Base.show(io::IO, op::MPIOperator) = show(convert(IOContext, io), op)
function Base.show(io::IOContext, op::MPIOperator)
    show(io, parent(op))
end