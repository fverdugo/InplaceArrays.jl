module Fields

using Test
using TensorValues
using InplaceArrays
using InplaceArrays.Functors: BCasted
using InplaceArrays.Functors: Applied
import InplaceArrays.Functors: functor_cache
import InplaceArrays.Functors: apply_functor
import InplaceArrays.Functors: evaluate_functor!
import InplaceArrays.Functors: functor_return_type
import InplaceArrays: return_type
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
export ApplyToGradStyle
export ApplyGradStyle
import InplaceArrays: apply

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

function testvector(::Type{T}) where T
  Vector{T}(undef,0)
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

using InplaceArrays.Functors: Applied

abstract type GradStyle end
struct ApplyToGradStyle <: GradStyle end
struct ApplyGradStyle <: GradStyle end

const FieldLikeOrData = Union{FieldLike,Number,AbstractArray}

struct AppliedFieldLike{D,T,N,C<:Applied,G} <: FieldLike{D,T,N}
  c::C
  #function AppliedFieldLike(
  #  g,f::FieldLike{D}...;gradstyle::GradStyle=ApplyGradStyle()) where D
  #  Ts = map(return_type,f)
  #  V = functor_return_type(g,Ts...)
  #  N = ndims(V)
  #  @assert N in (1,2) "N=$N but should be 1 or 2"
  #  T = eltype(V)
  #  c = Applied(g,f...)
  #  C = typeof(c)
  #  G = typeof(gradstyle)
  #  new{D,T,N,C,G}(c)
  #end
  function AppliedFieldLike(
    D::Int, ::Type{T}, N::Int, g::GradStyle, c::Applied) where T
    new{D,T,N,typeof(c),typeof(g)}(c)
  end
end

function return_type(f::AppliedFieldLike)
  Ts = map(return_type,f.c.f)
  functor_return_type(f.c.g,Ts...)
end

function new_cache(f::AppliedFieldLike)
   Ts = map(return_type,f.c.f)
   vs = testvalues(Ts...)
   cg = functor_cache(f.c.g,vs...)
   cf = new_caches(f.c.f...)
   (cg,cf)
end

function evaluate!(cache,f::AppliedFieldLike,x::AbstractVector{<:Point})
  evaluate_functor!(cache,f.c,x)
end

GradStyle(f::AppliedFieldLike{D,T,N,C,G}) where {D,T,N,C,G} = G()

#TODO this is not really the gradient, but we have followed this criterion
gradient(f::AppliedFieldLike) = _gradient(f,GradStyle(f))

function _gradient(f::AppliedFieldLike{D,T,N},s::ApplyGradStyle) where {D,T,N}
  g = gradient(f.c.g)
  G = gradtype(f)
  c = apply_functor(g,f.c.f...)
  AppliedFieldLike(D,G,N,s,c)
end

function _gradient(f::AppliedFieldLike{D,T,N},s::ApplyToGradStyle) where {D,T,N}
  gs = gradients(f.c.f...)
  c = apply_functor(f.c.g,gs...)
  G = gradtype(f)
  AppliedFieldLike(D,G,N,s,c)
end

gradient(f::BCasted) = bcast(gradient(f.f))

function gradients(a,b...)
  ga = gradient(a)
  gb = gradients(b...)
  (ga,gb...)
end

function gradients(a)
  ga = gradient(a)
  (ga,)
end

function apply(
  ::Type{T}, s::GradStyle, g::Function, f::FieldLike{D,S,N}...) where {T,D,S,N}

  b = bcast(g)
  c = apply_functor(b,f...)
  AppliedFieldLike(D,T,N,s,c)
end

#function apply_functor(g,f::Field...)
#    AppliedFieldLike(g,f...)
#end

for op in (:+,:-)
  @eval begin
    function ($op)(f::FieldLike{D,T,N}) where {D,T,N}
      s = ApplyToGradStyle()
      apply(T,s,$op,f)
    end
  end
end

# TODO DOF basis

end # module
