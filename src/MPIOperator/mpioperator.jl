## This shallow struct is used to indicate that each LazyMIPOperator should be evaluated on each rank and the result is to be reduced across all ranks using MPI.Allreduce
struct MPIOperator{O}
    parent::O
    function MPIOperator(parent::O) where {O}
        if !MPI.Initialized()
            @warn "MPI is currently not initialized. Please initialize MPI by running \n `using MPI; MPI.Init()` \n before creating an MPIOperator." maxlog=1
        end
        return new{O}(parent)
    end
end

function Base.parent(op::MPIOperator{O})::O where {O}
    return op.parent
end

function (Op::MPIOperator{O})(x::S) where {O,S}
    y_per_rank = parent(Op)(x)
    y = large_allreduce(y_per_rank, +, MPI.COMM_WORLD)
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

@forward MPIOperator.parent Base.getindex, Base.size, Base.length, Base.iterate, Base.eltype, Base.axes, Base.similar, Base.eachindex, Base.lastindex, Base.setindex!, Base.isfinite
@forward MPIOperator.parent LinearAlgebra.norm
@forward MPIOperator.parent TensorKit.spacetype, TensorKit.sectortype,TensorKit.storagetype
@forward MPIOperator.parent MPSKit.eachsite, MPSKit.left_virtualspace, MPSKit.right_virtualspace, MPSKit.physicalspace
@forward_astype MPIOperator.parent MPSKit.remove_orphans!
@forward_astype MPIOperator.parent Base.:+, Base.:-, Base.:*, Base.:/, Base.:\, Base.:(^), Base.conj!, Base.conj, Base.copy
@forward_1_1_astype MPIOperator.parent Base.:*
@forward_astype MPIOperator.parent VectorInterface.scale
@forward2 MPIOperator.parent MPSKit._fuse_mpo_mpo