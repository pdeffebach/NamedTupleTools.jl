"""
     NamedTupleTools

This module provides some useful NamedTuple tooling.

see [`namedtuple`](@ref), [`isprototype`](@ref), [`fieldnames`](@ref), [`fieldname`](@ref), 
    [`keys`](@ref), [`values`](@ref), [`valtypes`](@ref), [`delete`](@ref), [`merge`](@ref)
"""
module NamedTupleTools

export namedtuple, valtypes, isprototype, delete, fieldvalues, ntfromstruct, structfromnt

import Base: values, merge, valtype

# accept comma delimited values
NamedTuple{T}(xs...) where {T} = NamedTuple{T}(xs)

"""
    fieldvalues

obtain values assigned to fields of a struct type
(in field order)
"""
function fieldvalues(x::T) where {T}
     !isstructtype(T) && throw(ArgumentError("$(T) is not a struct type"))
     
     return ((getfield(x, name) for name in fieldnames(T))...,)
end

function ntfromstruct(x::T) where {T}
     !isstructtype(T) && throw(ArgumentError("$(T) is not a struct type"))
     names = fieldnames(T)
     values = fieldvalues(x)
     return NamedTuple{names}(values)
end

function structfromnt(::Type{S}, x::NT) where {S, N, T, NT<:NamedTuple{N,T}}
     names = N
     values = fieldvalues(x)
     if fieldnames(S) != names
          throw(ErrorException("fields in ($S) do not match ($x)"))
     end
     return S(values...,)
end


len(::Type{T}) where {T<:Tuple} = length(T.parameters)
len(::Type{T}) where {T<:NamedTuple} = length(T.parameters[1])
len(::Type{T}) where {N,T<:NamedTuple{N}} = length(N)

"""
    namedtuple(  name1, name2, ..  )
    namedtuple( (name1, name2, ..) )
    namedtuple(  namedtuple )

Generate a NamedTuple prototype by specifying or obtaining the fieldnames.
The prototype is applied to fieldvalues, giving a completed NamedTuple.

# Example

julia> ntprototype = namedtuple( :a, :b, :c )

NamedTuple{(:a, :b, :c),T} where T<:Tuple

julia> nt123 = ntprototype(1, 2, 3)

(a = 1, b = 2, c = 3)

julia> ntAb3 = ntprototype("A", "b", 3)

(a = "A", b = "b", c = 3)

see: [`isprototype`](@ref)
"""
namedtuple(names::NTuple{N,Symbol}) where {N} = NamedTuple{names}
namedtuple(names::Vararg{Symbol}) = NamedTuple{names}
namedtuple(names::NTuple{N,String}) where {N}  = namedtuple(Symbol.(names))
namedtuple(names::Vararg{String}) = namedtuple(Symbol.(names))
namedtuple(names::T) where {T<:AbstractVector{Symbol}} = namedtuple(names...,)
namedtuple(names::T) where {T<:AbstractVector{String}} = namedtuple(Symbol.(names))

namedtuple(nt::T) where {N,V,T<:NamedTuple{N,V}} = NamedTuple{N}
# for speed
namedtuple(nm1::T) where T<:Symbol = NamedTuple{(nm1,)}
namedtuple(nm1::T, nm2::T) where T<:Symbol = NamedTuple{(nm1,nm2)}
namedtuple(nm1::T, nm2::T, nm3::T) where T<:Symbol = NamedTuple{(nm1,nm2,nm3)}
namedtuple(nm1::T, nm2::T, nm3::T, nm4::T) where T<:Symbol = NamedTuple{(nm1,nm2,nm3,nm4)}
namedtuple(nm1::T, nm2::T, nm3::T, nm4::T, nm5::T) where T<:Symbol =
    NamedTuple{(nm1,nm2,nm3,nm4,nm5)}
namedtuple(nm1::T, nm2::T, nm3::T, nm4::T, nm5::T, nm6::T) where T<:Symbol =
    NamedTuple{(nm1,nm2,nm3,nm4,nm5,nm6)}
namedtuple(nm1::T, nm2::T, nm3::T, nm4::T, nm5::T, nm6::T, nm7::T) where T<:Symbol =
    NamedTuple{(nm1,nm2,nm3,nm4,nm5,nm6,nm7)}
namedtuple(nm1::T, nm2::T, nm3::T, nm4::T, nm5::T, nm6::T, nm7::T, nm8::T) where T<:Symbol =
    NamedTuple{(nm1,nm2,nm3,nm4,nm5,nm6,nm7,nm8)}
namedtuple(nm1::T, nm2::T, nm3::T, nm4::T, nm5::T, nm6::T, nm7::T, nm8::T, nm9::T) where T<:Symbol =
    NamedTuple{(nm1,nm2,nm3,nm4,nm5,nm6,nm7,nm8,nm9)}
namedtuple(nm1::T, nm2::T, nm3::T, nm4::T, nm5::T, nm6::T, nm7::T, nm8::T, nm9::T, nm10::T) where T<:Symbol =
    NamedTuple{(nm1,nm2,nm3,nm4,nm5,nm6,nm7,nm8,nm9,nm10)}

"""
    valtype( namedtuple )

Retrieve the values' types as a typeof(tuple).

see: [`valtypes`](@ref)
"""
valtype(x::T) where {N,S, T<:NamedTuple{N,S}} = T.parameters[2]
valtype(::Type{T}) where {N, S<:Tuple, T<:Union{NamedTuple{N},NamedTuple{N,S}}} =
    typeof(T) === UnionAll ? NTuple{len(N),Any} : T.parameters[2]

"""
    valtypes( namedtuple )
    valtypes( typeof(namedtuple) )

Retrieve the values' types as a tuple.

see: [`valtype`](@ref)
"""
valtypes(x::T) where {N,S, T<:NamedTuple{N,S}} = Tuple(T.parameters[2].parameters)
valtypes(::Type{T}) where {N, S<:Tuple, T<:Union{NamedTuple{N},NamedTuple{N,S}}} =
       typeof(T) === UnionAll ? Tuple((NTuple{len(N),Any}).parameters) :
                                Tuple(T.parameters[2].parameters)

"""
    isprototype( ntprototype )
    isprototype( namedtuple  )

Predicate that identifies NamedTuple prototypes.

see: [`namedtuple`](@ref)
"""
isprototype(::Type{T}) where {T<:NamedTuple} = eltype(T) === Any
isprototype(nt::T) where {T<:NamedTuple} = false
isprototype(::Type{UnionAll}) = false

"""
   delete(namedtuple, symbol(s)|Tuple)
   delete(ntprototype, symbol(s)|Tuple)
   
Generate a namedtuple [ntprototype] from the first arg omitting fields present in the second arg.

see: [`merge`](@ref)
"""
delete(a::NamedTuple, b::Symbol) = Base.structdiff(a, namedtuple(b))
delete(a::NamedTuple, b::NTuple{N,Symbol}) where {N} = Base.structdiff(a, namedtuple(b))
delete(a::NamedTuple, bs::Vararg{Symbol}) = Base.structdiff(a, namedtuple(bs))

delete(::Type{T}, b::Symbol) where {S,T<:NamedTuple{S}} = namedtuple((Base.setdiff(S,(b,))...,))
delete(::Type{T}, b::NTuple{N,Symbol}) where {S,N,T<:NamedTuple{S}} = namedtuple((Base.setdiff(S,b)...,))
delete(::Type{T}, bs::Vararg{Symbol}) where {S,N,T<:NamedTuple{S}} = namedtuple((Base.setdiff(S,bs)...,))

"""
    merge(namedtuple1, namedtuple2)
    merge(nt1, nt2, nt3, ..)

Generate a namedtuple with all fieldnames and values of namedtuple2
    and every fieldname of namedtuple1 that does not occur in namedtuple2
    along with their values.

see: [`delete!`](@ref)
"""
merge(::Type{T1}, ::Type{T2}) where {N1,N2,T1<:NamedTuple{N1},T2<:NamedTuple{N2}} =
    namedtuple((unique((N1..., N2...,))...,))
merge(::Type{T1}, ::Type{T2}, ::Type{T3}) where {N1,N2,N3,T1<:NamedTuple{N1},T2<:NamedTuple{N2},T3<:NamedTuple{N3}} =
    namedtuple((unique((N1..., N2..., N3...,))...,))
merge(::Type{T1}, ::Type{T2}, ::Type{T3}, ::Type{T4}) where {N1,N2,N3,N4,T1<:NamedTuple{N1},T2<:NamedTuple{N2},T3<:NamedTuple{N3},T4<:NamedTuple{N4}} =
    namedtuple((unique((N1..., N2..., N3..., N4...,))...,))
merge(::Type{T1}, ::Type{T2}, ::Type{T3}, ::Type{T4}, ::Type{T5}) where {N1,N2,N3,N4,N5,T1<:NamedTuple{N1},T2<:NamedTuple{N2},T3<:NamedTuple{N3},T4<:NamedTuple{N4},T5<:NamedTuple{N5}} =
    namedtuple((unique((N1..., N2..., N3..., N4..., N5...,))...,))
merge(::Type{T1}, ::Type{T2}, ::Type{T3}, ::Type{T4}, ::Type{T5}, ::Type{T6}) where {N1,N2,N3,N4,N5,N6,T1<:NamedTuple{N1},T2<:NamedTuple{N2},T3<:NamedTuple{N3},T4<:NamedTuple{N4},T5<:NamedTuple{N5},T6<:NamedTuple{N6}} =
    namedtuple((unique((N1..., N2..., N3..., N4..., N5..., N6...,))...,))
merge(::Type{T1}, ::Type{T2}, ::Type{T3}, ::Type{T4}, ::Type{T5}, ::Type{T6}, ::Type{T7}) where {N1,N2,N3,N4,N5,N6,N7,T1<:NamedTuple{N1},T2<:NamedTuple{N2},T3<:NamedTuple{N3},T4<:NamedTuple{N4},T5<:NamedTuple{N5},T6<:NamedTuple{N6},T7<:NamedTuple{N7}} =
    namedtuple((unique((N1..., N2..., N3..., N4..., N5..., N6...,N7...))...,))

# merge(nt1::T1, nt2::T2) where {T1<:NamedTuple, T2<:NamedTuple} is already defined

merge(a::NamedTuple{an}, b::NamedTuple{bn}, c::NamedTuple{cn}) where {an, bn, cn} =
    reduce(merge,(a, b, c))
merge(a::NamedTuple{an}, b::NamedTuple{bn}, c::NamedTuple{cn}, d::NamedTuple{dn}) where {an, bn, cn, dn} =
    reduce(merge,(a, b, c, d))
merge(a::NamedTuple{an}, b::NamedTuple{bn}, c::NamedTuple{cn}, d::NamedTuple{dn}, e::NamedTuple{en}) where {an, bn, cn, dn, en} =
    reduce(merge,(a, b, c, d, e))
merge(a::NamedTuple{an}, b::NamedTuple{bn}, c::NamedTuple{cn}, d::NamedTuple{dn}, e::NamedTuple{en}, f::NamedTuple{fn}) where {an, bn, cn, dn, en, fn} =
    reduce(merge,(a, b, c, d, e, f))
merge(a::NamedTuple{an}, b::NamedTuple{bn}, c::NamedTuple{cn}, d::NamedTuple{dn}, e::NamedTuple{en}, f::NamedTuple{fn}, g::NamedTuple{gn}) where {an, bn, cn, dn, en, fn, gn} =
    reduce(merge,(a, b, c, d, e, f, g))


# conversions

# from Alex Arslan
Base.NamedTuple(d::Dict{Symbol,T}) where {T} = (; d...)

function Base.Dict(nt::NT) where {N,T,NT<:NamedTuple{N,T}}
    z = zip(fieldnames(typeof(nt)), fieldvalues(nt))
    return Dict(z)
end

namedtuple(v::Vector{<:Pair{<:Symbol}}) = namedtuple([p[1] for p in v]...)([p[2] for p in v]...)

end # module NamedTupleTools
