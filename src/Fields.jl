#module Fields

# TODO move to TensorValues
using StaticArrays
using TensorValues
export mutable
mutable(::Type{MultiValue{S,T,N,L}}) where {S,T,N,L} = MArray{S,T,N,L}

using Test
using TensorValues
import InplaceArrays.Functors: functor_cache
import InplaceArrays.Functors: evaluate_functor!

"""
    const Point{D,T} = VectorValue{D,T}

Type representing a point of D dimensions with coordinates of type T
"""
const Point{D,T} = VectorValue{D,T}

# Definition of the interface

abstract type FieldLike{D,T,N} end

const Field = FieldLike{D,T,1} where {D,T}

const Basis = FieldLike{D,T,2} where {D,T}

"""
    evaluate!(cache,f::FieldLike,x::AbstractVector{<:Point}) -> AbstractArray

For `Fields` it returns an instance of `AbstractVector` and for `Basis` 
and an instance of `AbstractMatrix`.
"""
function evaluate! end

"""
    new_cache(f::FieldLike)
"""
function new_cache end

"""
    gradient(f::FieldLike) -> FieldLike
"""
function gradient end

# Testers

function test_fieldlike(
  f::FieldLike{D,T,N},x::AbstractVector{<:Point},v::AbstractVector,cmp=(==)) where {D,T,N}
  w = evaluate(f,x)
  @test ndims(w) == N
  @test T == eltype(w)
  @test cmp(w,v)
  @test D == pointdim(f)
  @test T == valuetype(f)
end

function test_field(f::Field,x,v)
  test_fieldlike(f,x,v)
end

function test_basis(f::Basis,x,v)
  test_fieldlike(f,x,v)
end

# info getters

function evaluate(f::FieldLike,x::AbstractVector{<:Point})
  cache = new_cache(f)
  v = evaluate!(cache,f,x)
  v
end

"""
    valuetype(::Type) -> DataType
"""
valuetype(::Type{<:FieldLike{D,T}}) where {D,T} = T

valuetype(f::T) where T<:FieldLike = valuetype(T)

"""
    pointdim(::Type) -> Int
"""
pointdim(::Type{<:FieldLike{D}}) where D = D

pointdim(f::T) where T<:FieldLike = pointdim(T)


"""
    num_dofs(b::Basis) -> Int
"""
function num_dofs end

"""
    gradtype(::Type) -> DataType
"""
function gradtype(::Type{T},::Val{D}) where {T,D}
  P = Point{D,Int16}
  p = zero(P)
  v = zero(T)
  g = outer(p,v)
  typeof(g)
end

function gradtype(::Type{F}) where F<:FieldLike
  T = valuetype(F)
  D = pointdim(F)
  gradtype(T,Val(D))
end

gradtype(f::T) where T<:FieldLike = gradtype(T)

function valuetypes(a,b...)
  Ta = valuetype(a)
  Tb = valuetypes(b...)
  (Ta,Tb...)
end

function valuetypes(a)
  Ta = valuetype(a)
  (Ta,)
end

function functor_cache(f::FieldLike,x::AbstractVector{<:Point})
  new_cache(f)
end

@inline function evaluate_functor!(cache,f::FieldLike,x::AbstractVector{<:Point})
  evaluate!(cache,f,x)
end

function testvectors(Ta,Tb...)
  va = Vector{Ta}(undef,0)
  vb = testvectors(Tb...)
  (va,vb...)
end

function testvectors(Ta)
  va = Vector{Ta}(undef,0)
  (va,)
end

function new_caches(a,b...)
  ca = new_cache(a)
  cb = new_caches(b...)
  (ca,cb...)
end

function new_caches(a)
  ca = new_cache(a)
  (ca,)
end

using InplaceArrays.Functors: Composed

struct ComposedField{D,T,C<:Composed} <: Field{D,T}
  c::C
  function ComposedField(g,f::Field{D}...) where D
    vs = testvectors(valuetypes(f...)...)
    r = evaluate_functor(g,vs...)
    T = eltype(r)
    c = compose_functors(g,f...)
    C = typeof(c)
    new{D,T,C}(c)
  end
end

function new_cache(f::ComposedField)
   vs = testvectors(valuetypes(f.c.f...)...)
   cg = functor_cache(f.c.g,vs...)
   cf = new_caches(f.c.f...)
   (cg,cf)
end

function evaluate!(cache,f::ComposedField,x::AbstractVector{<:Point})
  evaluate_functor!(cache,f.c,x)
end

#TODO this is not really the gradient, but we have followed this criterion
function gradient(f::ComposedField)
  g = gradient(f.c.g)
  ComposedField(g,f.c.f...)
end

function compose(g::Function,f::Field...)
  b = bcast(g)
  ComposedField(b,f...)
end

#end # module
