## This shallow struct is used to indicate that each LazyMIPOperator should be evaluated on each rank and the result is to be reduced across all ranks using MPI.Allreduce
## This is the MPI-parallelized version of a linear operator
struct MPIOperator{O, F, C}
    parent::O
    reduction::F
    comm::C
    MPIOperator{O, F, C}(parent::O, reduction::F=Base.:+, comm::C=MPI.COMM_WORLD) where {O, F, C} = new{O, F, C}(parent, reduction, comm)
    MPIOperator{O, F}(parent::O, reduction::F=Base.:+, comm::C=MPI.COMM_WORLD) where {O, F, C} = new{O, F, C}(parent, reduction, comm)
    MPIOperator{O}(parent::O, reduction::F=Base.:+, comm::C=MPI.COMM_WORLD) where {O, F, C} = new{O, F, C}(parent, reduction, comm)
    MPIOperator(parent::O, reduction::F=Base.:+, comm::C=MPI.COMM_WORLD) where {O, F, C} = new{O, F, C}(parent, reduction, comm)
end

function Base.parent(op::MPIOperator{O, F})::O where {O, F}
    return op.parent
end

function (Op::MPIOperator{O, F})(x::S) where {O, F, S}
    y_per_rank = parent(Op)(x)
    y = MPIHelper.allreduce(y_per_rank, Op.reduction, Op.comm)
    return y
end

Base.:*(Op::MPIOperator, v) = Op(v)
(Op::MPIOperator)(x, ::Number) = Op(x)

function Base.show(io::IO, ::MIME"text/plain", op::MPIOperator)
    print(io, "MPIOperator with communicator $(op.comm) and reduction $(op.reduction) wrapping:\n")
    show(io, MIME"text/plain"(), parent(op))
end
Base.show(io::IO, op::MPIOperator) = show(convert(IOContext, io), op)
function Base.show(io::IOContext, op::MPIOperator)
    print(io, "MPIOperator with communicator $(op.comm) and reduction $(op.reduction) wrapping:\n")
    show(io, parent(op))
end

@forward MPIOperator.parent Base.getindex, Base.size, Base.length, Base.iterate, Base.eltype, Base.axes, Base.similar, Base.eachindex, Base.lastindex, Base.setindex!, Base.isfinite
@forward MPIOperator.parent LinearAlgebra.norm
@forward MPIOperator.parent TensorKit.spacetype, TensorKit.sectortype,TensorKit.storagetype
@forward MPIOperator.parent MPSKit.eachsite, MPSKit.left_virtualspace, MPSKit.right_virtualspace, MPSKit.physicalspace
@forward_astype MPIOperator.parent MPSKit.remove_orphans!
@forward_astype MPIOperator.parent Base.:+, Base.:-, Base.:*, Base.:/, Base.:\, Base.:(^), Base.conj!, Base.conj, Base.copy
@forward_1_1_astype MPIOperator.parent Base.:*
@forward_astype MPIOperator.parent VectorInterface.scale
@forward2 MPIOperator.parent MPSKit._fuse_mpo_mpo