macro forward_setindex_sync(ex)
    if !(isa(ex, Expr) && ex.head == :.)
        error("Syntax: @forward_setindex_sync Type.field")
    end
    Texpr = ex.args[1]
    field = ex.args[2]

    # Remove the outer esc() and only escape what needs escaping
    body = quote
        function Base.setindex!(obj::$(esc(Texpr)), A, i::Int)
            if MPI.Initialized()
                A = MPI.bcast(A, MPI.COMM_WORLD) ## TODO: Write own chunked version
                println("We have bcasted!")
            end
            return setindex!(getfield(obj, $(QuoteNode(field))), A, i)
        end
    end

    return body  # Don't wrap the whole thing in esc()
end

@forward_setindex_sync InfiniteMPS.AL
@forward_setindex_sync InfiniteMPS.AR
@forward_setindex_sync InfiniteMPS.AC
@forward_setindex_sync InfiniteMPS.C