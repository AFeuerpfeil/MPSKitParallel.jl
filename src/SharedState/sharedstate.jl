## This defines functionality that automatically guarantees that only the root rank can change the MPS and that all changes are synchronized across all ranks.#
const _mps_types = [FiniteMPS, InfiniteMPS, MultilineMPS, WindowMPS]
const _abstract_mps_types = [AbstractFiniteMPS, AbstractInfiniteMPS, Multiline{<:InfiniteMPS}, AbstractFiniteMPS]

for (mpstype, abstractmpstype) in zip(_mps_types, _abstract_mps_types)
    shared_name = Symbol("Shared", nameof(mpstype))
    ex = :(struct $(shared_name){T<:$(mpstype)} <: $(abstractmpstype)
            parent::T
        end)
    @eval $ex
    @eval function Base.parent(ψ::$(shared_name))
        return ψ.parent
    end
    @eval function Base.parent(ψtype::Type{$(shared_name)})
        return $(mpstype)
    end
end

const AbstractSharedMPS = Union{SharedFiniteMPS, SharedInfiniteMPS, SharedMultilineMPS, SharedWindowMPS}

## This is the relevant overload to make this MPI-safe for all MPS operations:
function Base.setindex(ψ::AbstractSharedMPS, A::TensorMap, i::Int)
    if MPI.Comm_rank(MPI.COMM_WORLD) == 0
        parent(ψ)[i] = A
    end
    MPI.Barrier(MPI.COMM_WORLD)
    A_shared = MPI.Bcast(A, 0, MPI.COMM_WORLD)
    parent(ψ)[i] = A_shared
    return ψ
end

Base.summary(io::IO, ::AbstractSharedMPS) = print(io, "SharedState wrapping:\n"); Base.summary(io, parent(ψ))
Base.show(io::IO, ::MIME"text/plain", ψ::AbstractSharedMPS) = print(io, "SharedState wrapping:\n"); Base.show(io, MIME"text/plain"(), parent(ψ))
Base.show(io::IO, ψ::AbstractSharedMPS) = show(convert(IOContext, io), ψ)
function Base.show(io::IOContext, ψ::AbstractSharedMPS)
    print(io, "SharedState wrapping:\n")
    show(io, parent(ψ))
end

Base.eltype(ψ::AbstractSharedMPS) = eltype(parent(ψ))
VectorInterface.scalartype(T::Type{<:AbstractSharedMPS}) = VectorInterface.scalartype(parent(T))

Base.checkbounds(ψ::AbstractSharedMPS, i::Int) = Base.checkbounds(parent(ψ), i)

MPSKit.site_type(ψ::AbstractSharedMPS, i::Int) = MPSKit.site_type(parent(ψ), i)
MPSKit.site_type(ψtype::Type{<:AbstractSharedMPS}) = MPSKit.site_type(parent(ψtype))
MPSKit.bond_type(ψtype::Type{<:AbstractSharedMPS}) = MPSKit.bond_type(parent(ψtype))

MPSKit.bond_type(ψ::AbstractSharedMPS) = MPSKit.bond_type(parent(ψ))
TensorKit.spacetype(ψ::AbstractSharedMPS) = TensorKit.spacetype(parent(ψ))
TensorKit.spacetype(ψtype::Type{<:AbstractSharedMPS}) = TensorKit.spacetype(site_type(ψtype))
TensorKit.sectortype(ψ::AbstractSharedMPS) = TensorKit.sectortype(parent(ψ))
TensorKit.sectortype(ψtype::Type{<:AbstractSharedMPS}) = TensorKit.sectortype(site_type(ψtype))

MPSKit.left_virtualspace(ψ::AbstractSharedMPS) = MPSKit.left_virtualspace(parent(ψ))
MPSKit.right_virtualspace(ψ::AbstractSharedMPS) = MPSKit.right_virtualspace(parent(ψ))
MPSKit.physicalspace(ψ::AbstractSharedMPS) = MPSKit.physicalspace(parent(ψ))
MPSKit.left_virtualspace(ψ::AbstractSharedMPS, site::Int) = MPSKit.left_virtualspace(parent(ψ), site)
MPSKit.right_virtualspace(ψ::AbstractSharedMPS, site::Int) = MPSKit.right_virtualspace(parent(ψ), site)
MPSKit.physicalspace(ψ::AbstractSharedMPS, site::Int) = MPSKit.physicalspace(parent(ψ), site)
TensorKit.space(ψ::AbstractSharedMPS, site::Int) = TensorKit.space(parent(ψ), site)
MPSKit.max_virtualspaces(ψ::AbstractSharedMPS) = MPSKit.max_virtualspaces(parent(ψ))
MPSKit.max_Ds(ψ::AbstractSharedMPS) = MPSKit.max_Ds(parent(ψ))

MPSKit.eachsite(ψ::AbstractSharedMPS) = MPSKit.eachsite(parent(ψ))

Base.size(ψ::AbstractSharedMPS) = size(parent(ψ))
Base.length(ψ::AbstractSharedMPS) = length(parent(ψ))
Base.copy(ψ::T) where {T<:AbstractSharedMPS} = T(copy(parent(ψ)))
function Base.copy!(ψ::T, ϕ::T) where {T<:AbstractSharedMPS}
    return copy!(parent(ψ), parent(ϕ))
end

Base.similar(ψ::T) where {T<:AbstractSharedMPS} = T(similar(parent(ψ)))

Base.eachindex(ψ::AbstractSharedMPS) = Base.eachindex(parent(ψ))
Base.eachindex(l::IndexStyle, ψ::AbstractSharedMPS) = Base.eachindex(l, parent(ψ))
Base.checkbounds(::Type{Bool}, ψ::AbstractSharedMPS, i::Int) = Base.checkbounds(Bool, parent(ψ), i)

Base.@propagate_inbounds function Base.getindex(ψ::AbstractSharedMPS, i::Int)
    return parent(ψ)[i]
end

MPSKit.AC2(psi::AbstractSharedMPS, site::Int; kwargs...) = MPSKit.AC2(parent(psi), site; kwargs...)

Base.complex(ψ::T) where {T<:AbstractSharedMPS} = T(complex(parent(ψ)))

@inline function Base.getindex(ψ::AbstractSharedMPS, I::AbstractUnitRange)
    return Base.getindex(parent(ψ), I)
end

function Base.getproperty(ψ::AbstractSharedMPS, prop::Symbol)
    return getproperty(parent(ψ), prop)
end

function Base.propertynames(::AbstractSharedMPS)
    return (:AL, :AR, :AC, :C)
end

Base.convert(::Type{TensorMap}, ψ::AbstractSharedMPS) = convert(TensorMap, parent(ψ))

Base.:*(ψ::T, a::Number) where {T<:AbstractSharedMPS} = T(parent(ψ) * a)
Base.:*(a::Number, ψ::T) where {T<:AbstractSharedMPS} = T(a * parent(ψ))
Base.:+(ψ1::T, ψ2::T) where {T<:AbstractSharedMPS} = T(parent(ψ1) + parent(ψ2))
Base.:-(ψ1::T, ψ2::T) where {T<:AbstractSharedMPS} = T(parent(ψ1) - parent(ψ2))
TensorKit.dot(ψ1::T, ψ2::T; kwargs...) where {T<:AbstractSharedMPS} = TensorKit.dot(parent(ψ1), parent(ψ2); kwargs...)
Base.isapprox(ψ1::T, ψ2::T; kwargs...) where {T<:AbstractSharedMPS} = isapprox(parent(ψ1), parent(ψ2); kwargs...)
TensorKit.normalize!(ψ::T) where {T<:AbstractSharedMPS} = normalize!(parent(ψ))
TensorKit.normalize(ψ::T) where {T<:AbstractSharedMPS} = T(normalize(parent(ψ)))

MPSKit.r_RR(ψ::AbstractSharedMPS, site::Int) = MPSKit.r_RR(parent(ψ), site)
MPSKit.l_LL(ψ::AbstractSharedMPS, site::Int) = MPSKit.l_LL(parent(ψ), site)
