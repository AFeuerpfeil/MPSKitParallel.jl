## This shallow struct is used to indicate that each LazyMIPOperator should be evaluated on each rank and the result is to be reduced across all ranks using MPI.Allreduce
struct MPIOperator{O,T}
    parent::O
    reduction::T # usually '+'
end

function Base.parent(op::MPIOperator{O,T})::O where {O,T}
    return op.parent
end

function (Op::MPIOperator{O,T})(x::S) where {O,T,S}
    y_per_rank = parent(x)
    y = MPI.allreduce(y_per_rank, Op.reduction, MPI.COMM_WORLD)
    return y
end

Base.:*(Op::MPIOperator, v) = Op(v)
(Op::MPIOperator)(x, ::Number) = Op(x)

function Base.show(io::IO, ::MIME"text/plain", op::MPIOperator)
    print(io, "MPIOperator wrapping:\n")
    show(io, MIME"text/plain"(), parent(op))
end
Base.show(io::IO, op::MPIOperator) = show(convert(IOContext, io), op)
function Base.show(io::IOContext, op::MPIOperator)
    print(io, "MPIOperator wrapping:\n")
    show(io, parent(op))
end