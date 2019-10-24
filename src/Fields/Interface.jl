"""
    const Point{D,T} = VectorValue{D,T}

Type representing a point of D dimensions with coordinates of type T
"""
const Point{D,T} = VectorValue{D,T}

"""
$(TYPEDEF)

Abstract type representing either a field.

The following functions need to be overloaded for derived types:

- [`evaluate!(cache,f::Field,x::Point)`](@ref)
- [`field_cache(f::Field,x::Point)`](@ref)

The following functions can optionally be also provided

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
abstract type Field{T} end
#TODO not sure if we need Field{D,T}
# Even if we adopt this, T will be a number for a field
# and a vector for a basis
# The advantage is that we could dispatch on field or basis
# The disadvantage is that implementing concrete types resulting
# from operation trees is more difficult
# TODO valuetype and field_return_type kind of duplicated, even though
# the last one allows to dispatch for vectorized and non-vectorized versions

"""
    field_cache(f::Field,x::Point)
"""
function field_cache(f::Field,x::Point)
  @abstractmethod
end

"""
    evaluate!(cache,f::Field,x::Point)

Returns the value of field at point x.
The value of a field is typically a number or an array.
When the value is a vector, the field is informally referred to as a *basis*.
"""
function evaluate!(cache,f::Field,x::Point)
  @abstractmethod
end

"""
    gradient(f::Field) -> Field
"""
function gradient(f::Field)
  @abstractmethod
end

"""
   const ∇ = gradient
"""
const ∇ = gradient

# Default return type

"""
    field_return_type(f::Field,x::Point)
"""
function field_return_type(f::Field,x::Point)
  typeof(evaluate(f,x))
end

#Default vectorized versions

"""
    field_cache(f::Field,x::AbstractVector{<:Point})
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
      ca[ci,i] = fi[ci]
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
    ca[i] = fi
  end
  ca
end

"""
    field_return_type(f::Field,x::AbstractVector{<:Point})
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
      f::Fiel,
      x::AbstractVector{<:Point},
      v::AbstractArray,cmp=(==);
      grad=nothing)
"""
function test_field(
  f::Field,
  x::AbstractVector{<:Point},
  v::AbstractArray,cmp=(==);
  grad=nothing)

  w = evaluate(f,x)
  @test cmp(w,v)
  @test typeof(w) == field_return_type(f,x)
  test_kernel(f,(x,),v,cmp)

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
    evaluate(f::Field,x::Point)
"""
function evaluate(f::Field,x)
  cache = field_cache(f,x)
  evaluate!(cache,f,x)
end

"""
    valuetype(::Type{Field{T}}) where T

Returns `T`
"""
valuetype(::Type{<:Field{T}}) where T = T
valuetype(f::T) where T<:Field = valuetype(T)

valuetype(::Type{T}) where T<:Number = T
valuetype(f::T) where T<:Number = valuetype(T)

valuetype(::Type{T}) where T<:AbstractArray = T
valuetype(f::T) where T<:AbstractArray = valuetype(T)


# Result of applying a kernel to the value of some fields

struct AppliedField{K,F,T} <: Field{T}
  k::K
  f::F
  function AppliedField(k,f...)
    Ts = map(valuetype,f)
    vs = map(testvalue,Ts)
    T = kernel_return_type(k,vs...)
    new{typeof(k),typeof(f),T}(k,f)
  end
end

function field_return_type(f::AppliedField,x::Point)
  Ts = kernel_return_types(f.f,x)
  kernel_return_type(f.k, map(testvalue,Ts)...)
end

function field_cache(f::AppliedField,x::Point)
  cf = kernel_caches(f.f,x)
  fx = apply_kernels!(cf,f.f,x)
  ck = kernel_cache(f.k,fx...)
  (ck,cf)
end

@inline function evaluate!(cache,f::AppliedField,x::Point)
  ck, cf = cache
  fx = apply_kernels!(cf,f.f,x)
  apply_kernel!(ck,f.k,fx...)
end

function gradient(f::AppliedField)
  gradient(f.k,f.f...) # TODO each kernel implements its gradient
  #TODO it also will be necessary to implement gradient for numbers and arrays
end

## Option B
#function gradient(f::AppliedField)
#  ∇f = map(gradient,f.f) # TODO Define gradient for numbers and arrays
#  ∇k = gradient(f.k) #TODO define gradient for kernels returning a tuple of coefs, one for each arg
#  _lincom(∇k,∇f) #TODO here we assume that * by scalar and binary + is defined to the objects in ∇f
#end

