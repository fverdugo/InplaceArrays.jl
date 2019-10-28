"""
    const Point{D,T} = VectorValue{D,T}

Type representing a point of D dimensions with coordinates of type T
"""
const Point{D,T} = VectorValue{D,T}

"""
    abstract type Field{V,D} <: Kernel

Abstract type representing physical field, basis of fields, and other related objects. 

- `D` is the number of components of the points where the field can be evaluated.
- `V` has to be a type `<:Number` if the field returns a number when evaluated at a single point.
- `V` has to be a type `<:AbstractArray` if the field returns an array when evaluated at a single point. E.g., for basis of fields `V` is a type `<:AbstractVector`.
- Note that `eltype(V)` is allowed to be any number type since the actual returned type can depend in general on the particular type of the evaluation point components.

The following functions need to be overloaded for derived types:

- [`evaluate!(cache,f::Field,x::Point)`](@ref)
- [`field_cache(f::Field,x::Point)`](@ref)

The following functions can be also provided optionally

- [`gradient(f::Field)`](@ref)
- [`field_return_type(f::Field,x::Point)`](@ref)

The following vectorized versions can be (optionally) rewritten
for specific types to improve performance:

- [`evaluate!(cache,f::Field,x::AbstractVector{<:Point})`](@ref)
- [`field_cache(f::Field,x::AbstractVector{<:Point})`](@ref)
- [`field_return_type(f::Field,x::AbstractVector{<:Point})`](@ref)

The interface can be tested with

- [`test_field`](@ref)

"""
abstract type Field{V,D} <: Kernel end
#TODO not sure if we need Field{D,T}
# Even if we adopt this, T will be a number for a field
# and a vector for a basis
# The advantage is that we could dispatch on field or basis
# The disadvantage is that implementing concrete types resulting
# from operation trees is more difficult
# TODO valuetype and field_return_type kind of duplicated, even though
# the last one allows to dispatch for vectorized and non-vectorized versions
# Any decision here has consequences in AppliedField
# EDIT:
# V needed to dispatch by either number or AbstractArray
# D needed in order to define gradients
# V first to facilitate dispatching


"""
    const Basis = Field{V,D} where {V<:AbstractVector, D}

Alias for the particular case, where the field returns a vector of values.
"""
const Basis = Field{<:AbstractVector}

"""
    field_cache(f::Field,x::Point)

Returns the cache object needed to evaluate field `f` at point `x`.
"""
function field_cache(f::Field,x::Point)
  @abstractmethod
end

"""
    evaluate!(cache,f::Field,x::Point)

Returns the value of field at point x.
The value of a field is typically a number or an array.
When the value is a vector, the field is in fact a *basis*.
"""
function evaluate!(cache,f::Field,x::Point)
  @abstractmethod
end

"""
    gradient(f::Field) -> Field

Returns another field that represents the gradient of the given one
"""
function gradient(f::Field)
  @abstractmethod
end

"""
   const ∇ = gradient

A fancy alias for the `gradient` function.
"""
const ∇ = gradient

# Default return type

"""
    field_return_type(f::Field,x::Point)

Computes the type obtained when evaluating field `f` at point `x`.
"""
function field_return_type(f::Field,x::Point)
  typeof(evaluate(f,x))
end

#Default vectorized versions

"""
    field_cache(f::Field,x::AbstractVector{<:Point})

Returns the cache object needed to evaluate the field `f` at the vector of points
`x` by means of the vectorized version of `evaluate!`.
"""
function field_cache(f::Field,x::AbstractVector{<:Point})
  _field_cache(valuetype(f),f,x)
end

function _field_cache(::Type{<:AbstractArray},f,x)
  xi = testitem(x)
  fi = evaluate(f,xi)
  si = size(fi)
  s = (si...,length(x))
  a = zeros(eltype(fi),s)
  ca = CachedArray(a)
  cfi = field_cache(f,xi)
  cis = CartesianIndices(fi)
  (ca,cfi,cis)
end

function _field_cache(::Type{<:Number},f,x)
  xi = testitem(x)
  fi = evaluate(f,xi)
  s = (length(x),)
  a = zeros(typeof(fi),s)
  ca = CachedArray(a)
  cfi = field_cache(f,xi)
  (ca,cfi)
end

"""
    evaluate!(cache,f::Field,x::AbstractVector{<:Point})

Vectorized version of [`evaluate!(f::Field,x::Point)`](@ref). 

For fields `f` with `valuetype(f)<:Number`, it returns a vector with the value of `f` at each of the point in `x`. 

For Fields `f` with `valuetype(f)<:AbstractArray`, it returns an array with one dimension more than the value of the field. E.g., for basis, it should return a matrix. The axis associated with the points `x` is the last axis in the resulting array. E.g., for a basis with `ndof` degrees of freedom, the returned matrix has size `(ndof,length(x))` .
"""
@inline function evaluate!(cache,f::Field,x::AbstractVector{<:Point})
  _evaluate!(valuetype(f),cache,f,x)
end

@inline function _evaluate!(::Type{<:AbstractArray},cache,f,x)
  ca, cfi, cis = cache
  s = (size(cis)...,length(x))
  setsize!(ca,s)
  for i in 1:length(x)
    xi = x[i]
    fi = evaluate!(cfi,f,xi)
    for ci in cis
      @inbounds ca[ci,i] = fi[ci]
    end
  end
  ca
end

@inline function _evaluate!(::Type{<:Number},cache,f,x)
  ca, cfi = cache
  s = (length(x),)
  setsize!(ca,s)
  for i in 1:length(x)
    xi = x[i]
    fi = evaluate!(cfi,f,xi)
    @inbounds ca[i] = fi
  end
  ca
end

"""
    field_return_type(f::Field,x::AbstractVector{<:Point})

Returns the type of the object obtained when the field `f` is evaluated at the vector of points `x` by means of the vectorized version of `evaluate!`.
"""
function field_return_type(f::Field,x::AbstractVector{<:Point})
  _field_return_type(valuetype(f),f,x)
end

function _field_return_type(::Type{<:AbstractArray},f,x)
  xi = testitem(x)
  Ti = field_return_type(f,xi)
  ca = CachedArray(eltype(Ti),ndims(Ti)+1)
  typeof(ca)
end

function _field_return_type(::Type{<:Number},f,x)
  xi = testitem(x)
  Ti = field_return_type(f,xi)
  ca = CachedArray(Ti,1)
  typeof(ca)
end

# Implement kernel interface

function kernel_return_type(f::Field,x)
  field_return_type(f,x)
end

function kernel_cache(f::Field,x)
  field_cache(f,x)
end

@inline function apply_kernel!(cache,f::Field,x)
  evaluate!(cache,f,x)
end

# Testers

"""
    test_field(
      f::Field,
      x::AbstractVector{<:Point},
      v::AbstractArray,cmp=(==);
      grad=nothing)

Function used to test the field interface.
"""
function test_field(
  f::Field{T,D},
  x::AbstractVector{<:Point},
  v::AbstractArray,cmp=(==);
  grad=nothing) where {T,D}

  w = evaluate(f,x)
  @test cmp(w,v)
  @test typeof(w) == field_return_type(f,x)
  test_kernel(f,(x,),v,cmp)
  @test pointdim(f) == D
  @test valuetype(f) == T

  _testloop(valuetype(f),f,x,v,cmp)

  t = true
  for i in 1:length(x)
    xi = x[i]
    fi = evaluate(f,xi)
    ti = (typeof(fi) == field_return_type(f,xi))
    t = t && ti
  end
  @test t

  t = true
  for i in 1:length(x)
    xi = x[i]
    fi = evaluate(f,xi)
    ti = (typeof(fi) == valuetype(f))
    t = t && ti
  end
  @test t

  if grad != nothing
    g = gradient(f)
    test_field(g,x,grad,cmp)
  end

end

function _testloop(::Type{<:AbstractArray},f,x,v,cmp)
  t = true
  for i in 1:length(x)
    xi = x[i]
    fi = evaluate(f,xi)
    for j in CartesianIndices(fi)
      ti = cmp(fi[j],v[j,i])
      t = t && ti
    end
  end
  @test t
end

function _testloop(::Type{<:Number},f,x,v,cmp)
  t = true
  for i in 1:length(x)
    xi = x[i]
    fi = evaluate(f,xi)
    ti = cmp(fi,v[i])
    t = t && ti
  end
  @test t
end

# Some API

"""
    evaluate(f::Field,x)

Equivalent to 

    cache = field_cache(f,x)
    evaluate!(cache,f,x)
"""
function evaluate(f::Field,x)
  cache = field_cache(f,x)
  evaluate!(cache,f,x)
end

"""
    valuetype(::Type{Field{T,D}}) where {T,D}

Returns `T`
"""
valuetype(::Type{<:Field{T,D}}) where {T,D} = T
valuetype(f::T) where T<:Field = valuetype(T)

"""
    pointdim(::Type{Field{T,D}}) where {T,D}

Returns `D`
"""
pointdim(::Type{<:Field{T,D}}) where {T,D} = D
pointdim(f::T) where T<:Field = pointdim(T)

valuetype(::Type{T}) where T<:Number = T
valuetype(f::T) where T<:Number = valuetype(T)

valuetype(::Type{T}) where T<:AbstractArray = T
valuetype(f::T) where T<:AbstractArray = valuetype(T)


