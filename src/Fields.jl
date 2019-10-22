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
import Base: length

export Point
export evaluate
export evaluate!
export new_cache
export gradient
export ∇
export num_dofs
export FieldLike
export Field
export Basis
export test_field_like
export test_field
export test_field_with_gradient
export test_basis
export test_basis_with_gradient
export valuetype
export pointdim
export gradtype

"""
    const Point{D,T} = VectorValue{D,T}

Type representing a point of D dimensions with coordinates of type T
"""
const Point{D,T} = VectorValue{D,T}

# Definition of the interface

"""
    abstract type FieldLike{D,T,N}

Abstract type representing either a field ( for `N==1`) or a basis of fields
(for `N==2`) of value `T`, evaluable at points with `D` components.

The following functions need to be overloaded for derived types:

- [`evaluate!`](@ref)
- [`new_cache`](@ref)
- [`return_type(::FieldLike)`](@ref)
- [`num_dofs`](@ref) (Only for `CellBasis`, i.e. `N==2`.)

The following functions can optionally be also provided

- [`gradient(f::FieldLike)`](@ref)

The interface can be tested with these functions

- [`test_field_like`](@ref)
- [`test_field`](@ref)
- [`test_field_with_gradient`](@ref)

"""
abstract type FieldLike{D,T,N} end

"""
    const Field = FieldLike{D,T,1} where {D,T}
"""
const Field = FieldLike{D,T,1} where {D,T}

"""
    const Basis = FieldLike{D,T,2} where {D,T}
"""
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

function gradient end
const ∇ = gradient

"""
    gradient(f::FieldLike) -> FieldLike
"""
function gradient(f::FieldLike) end

"""
    return_type(::FieldLike) -> DataType
"""
function return_type(::FieldLike) end
# TODO really needed? I think it is only needed if we want to implement
# the functor interface. But, I think it is not needed to implement this
# interface anymore. EDIT: YES! it is needed for evaluating cell fields
# Perhaps not needed since we always return a CachedArray

#TODO use @abstract method, also in new array interface

# Testers

"""
"""
function test_field_like(
  f::FieldLike{D,T,N},x::AbstractVector{<:Point},v::AbstractArray,cmp=(==)) where {D,T,N}
  w = evaluate(f,x)
  @test ndims(w) == N
  @test T == eltype(w)
  @test cmp(w,v)
  @test D == pointdim(f)
  @test T == valuetype(f)
  test_functor(f,(x,),v,cmp)
end

function functor_return_type(f::FieldLike,Ts...)
  return_type(f)
end

"""
"""
function test_field(f::Field,x,v,cmp::Function=(==))
  test_field_like(f,x,v,cmp)
  r = evaluate(f,x)
  npoin = length(r)
  @test npoin == length(x)
end

"""
"""
function test_field_with_gradient(f::Field,x,v,g,cmp::Function=(==))
  test_field(f,x,v,cmp)
  ∇f = gradient(f)
  test_field(∇f,x,g,cmp)
end

"""
"""
function test_basis(f::Basis,x,v,cmp::Function=(==))
  test_field_like(f,x,v,cmp)
  r = evaluate(f,x)
  ndofs, npoin = size(r)
  @test ndofs == num_dofs(f)
  @test ndofs == length(f)
  @test npoin == length(x)
end

"""
"""
function test_basis_with_gradient(f::Basis,x,v,g,cmp::Function=(==))
  test_basis(f,x,v,cmp)
  ∇f = gradient(f)
  test_basis(∇f,x,g,cmp)
end

# info getters

"""
    evaluate(f::FieldLike,x::AbstractVector{<:Point})
"""
function evaluate(f::FieldLike,x::AbstractVector{<:Point})
  cache = new_cache(f)
  v = evaluate!(cache,f,x)
  v
end

"""
    valuetype(::Type) -> DataType
"""
valuetype(::Type{<:FieldLike{D,T}}) where {D,T} = T

valuetype(f::T) where T = valuetype(T)

"""
    pointdim(::Type) -> Int
"""
pointdim(::Type{<:FieldLike{D}}) where D = D

pointdim(f::T) where T = pointdim(T)


"""
    num_dofs(b::Basis) -> Int
"""
function num_dofs end #TODO use in tester

length(b::Basis) = num_dofs(b)

"""
    gradtype(::Type) -> DataType
"""
function gradtype(::Type{F}) where F<:FieldLike{D,T} where {D,T}
  E = eltype(T)
  P = Point{D,E}
  p = zero(P)
  v = zero(T)
  g = outer(p,v)
  typeof(g)
end

gradtype(f::T) where T = gradtype(T)

function valuetypes(a,b...)
  Ta = valuetype(a)
  Tb = valuetypes(b...)
  (Ta,Tb...)
end

# TODO needed if we have map?

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

# TODO needed if we have map?
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
