module Arrays

using Test
using InplaceArrays

export test_inplace_array
export evaluate_functor_elemwise
export array_cache
export getindex!
export testvalue

import InplaceArrays: functor_cache
import InplaceArrays: evaluate_functor!

"""
testvalue(::Type)
"""
function testvalue end

testvalue(::Type{T}) where T = zero(T)

function testvalue(::Type{T}) where T<:AbstractArray{E,N} where {E,N}
   similar(T,fill(0,N)...)
end

"""
array_cache(a)
"""
function array_cache end

"""
getindex!(cache,a,index...)
"""
function getindex! end

# Test the interface

function test_inplace_array(
  a::AbstractArray{T,N}, b::AbstractArray{T,N},cmp=(==)) where {T,N}
  @test cmp(a,b)
  cache = array_cache(a)
  t = true
  for i in eachindex(a)
    bi = b[i]
    ai = getindex!(cache,a,i)
    t = t && cmp(bi,ai)
  end
  @test t
  @test IndexStyle(a) == IndexStyle(b)
  true
end

# Add a default interface for all AbstractArrays

array_cache(::AbstractArray) = nothing

getindex!(cache,a::AbstractArray,i...) = a[i...]

# Construct a index-wise functor from an array
struct ArrayFunctor{A}
  array::A
  function ArrayFunctor(a::AbstractArray)
    new{typeof(a)}(a)
  end
end

functor_cache(f::ArrayFunctor,i...) = array_cache(f.array)

evaluate_functor!(cache,f::ArrayFunctor,i...) = getindex!(cache,f.array,i...)

# Wrap an index-wise functor with array metadata

function evaluate_functor_elemwise(f,a::AbstractArray...)
  x = _test_values(a...)
  N, size, I = _prepare_shape(a...)
  v = evaluate_functor(f,x...)
  T = typeof(v)
  b = _array_functors(a...)
  r = apply_functor(f,b...)
  F = typeof(r)
  ResultArray{T,N,I,F}(size,r)
end

struct ResultArray{T,N,I,F} <: AbstractArray{T,N}
  size::NTuple{N,Int}
  f::F
end

function Base.getindex(a::ResultArray,i...)
  cache = functor_cache(a.f,i...)
  evaluate_functor!(cache,a.f,i...)
end

function getindex!(cache,a::ResultArray,i...)
  evaluate_functor!(cache,a.f,i...)
end

function array_cache(a::ResultArray)
  if length(a)>0
    functor_cache(a.f,1)
  else
    nothing
  end
end

function Base.IndexStyle(::Type{ResultArray{T,N,I,F}}) where {T,N,I,F}
  I
end

Base.size(a::ResultArray) = a.size

function _test_values(a,b...)
  va = _test_value(a)
  vb = _test_values(b...)
  (va,vb...)
end

function _test_values(a)
  va = _test_value(a)
  (va,)
end

function _test_value(a::AbstractArray{T}) where T
  if length(a) >0
    a[1]
  else
    testvalue(T)
  end::T
end

function _array_functors(a,b...)
  c = ArrayFunctor(a)
  d = _array_functors(b...)
  (c,d...)
end

function _array_functors(a)
  c = ArrayFunctor(a)
  (c,)
end

#TODO not sure what to do with shape and index-style
function _prepare_shape(a...)
  a1, = a
  c = all([length(a1) == length(ai) for ai in a])
  if !c
    error("Array lengths are not compatible.")
  end
  N = 1
  s = (length(a1),)
  I = IndexLinear()
  (N,s,I)
end

end # module
