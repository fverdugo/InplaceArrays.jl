module Fields

using Test
using TensorValues
using InplaceArrays
using InplaceArrays.Functors: BCasted
import InplaceArrays.Functors: functor_cache
import InplaceArrays.Functors: evaluate_functor!
import InplaceArrays.Functors: functor_return_type
import InplaceArrays: return_type # Needed?
import Base: +, -, *

export Point
export evaluate
export evaluate!
export new_cache
export gradient
export ∇
export FieldLike
export Field
export Basis
export test_fieldlike
export test_field
export test_field_with_gradient
export test_basis
export valuetype
export pointdim
export gradtype
#export ApplyToGradStyle
#export ApplyGradStyle

#TODO list of methods to overwrite

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

const ∇ = gradient

# Testers

function test_fieldlike(
  f::FieldLike{D,T,N},x::AbstractVector{<:Point},v::AbstractVector,cmp=(==)) where {D,T,N}
  w = evaluate(f,x)
  @test ndims(w) == N
  @test T == eltype(w)
  @test cmp(w,v)
  @test D == pointdim(f)
  @test T == valuetype(f)
  test_functor(f,(x,),v,cmp)
end

function functor_return_type(f::Field,Ts...)
  return_type(f)
end

function test_field(f::Field,x,v,cmp::Function=(==))
  test_fieldlike(f,x,v,cmp)
end

function test_field_with_gradient(f::Field,x,v,g,cmp::Function=(==))
  test_field(f,x,v,cmp)
  ∇f = gradient(f)
  test_field(∇f,x,g,cmp)
end

function test_basis(f::Basis,x,v,cmp::Function=(==))
  test_fieldlike(f,x,v,cmp)
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
function num_dofs end #TODO use in tester

"""
    gradtype(::Type) -> DataType
"""
function gradtype(::Type{F}) where F<:FieldLike{D,T} where {D,T}
  P = Point{D,Int16}
  p = zero(P)
  v = zero(T)
  g = outer(p,v)
  typeof(g)
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

function new_caches(a,b...)
  ca = new_cache(a)
  cb = new_caches(b...)
  (ca,cb...)
end

function new_caches(a)
  ca = new_cache(a)
  (ca,)
end

# TODO DOF basis

end # module
