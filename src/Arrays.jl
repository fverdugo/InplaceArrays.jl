
import InplaceArrays: new_cache
import InplaceArrays: evaluate!
export test_inplace_array
export data_array_apply
export array_cache
export getindex!

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

new_cache(f::ArrayFunctor,i...) = array_cache(f.array)

evaluate!(cache,f::ArrayFunctor,i...) = getindex!(cache,f.array,i...)

# Wrap an index-wise functor with array metadata

function data_array_apply(f,a::AbstractArray...)
  x = _test_values(a...)
  N, size, I = _prepare_shape(a...)
  v = evaluate(f,x...)
  T = typeof(v)
  b = _array_functors(a...)
  r = apply(f,b...)
  F = typeof(r)
  AppliedDataArray{T,N,I,F}(size,r)
end

struct AppliedDataArray{T,N,I,F} <: AbstractArray{T,N}
  size::NTuple{N,Int}
  f::F
end

function Base.getindex(a::AppliedDataArray,i...)
  cache = new_cache(a.f,i...)
  evaluate!(cache,a.f,i...)
end

function getindex!(cache,a::AppliedDataArray,i...)
  evaluate!(cache,a.f,i...)
end

function array_cache(a::AppliedDataArray)
  if length(a)>0
    new_cache(a.f,1)
  else
    nothing
  end
end

function Base.IndexStyle(::Type{AppliedDataArray{T,N,I,F}}) where {T,N,I,F}
  I
end

Base.size(a::AppliedDataArray) = a.size

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

testvalue(::Type{T}) where T<:Number = zero(T)

testvalue(::Type{Array{T,N}}) where {T,N} = zeros(T,fill(0,N)...)

function _array_functors(a,b...)
  c = ArrayFunctor(a)
  d = _array_functors(b...)
  (c,d...)
end

function _array_functors(a)
  c = ArrayFunctor(a)
  (c,)
end

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

#using Test
#using Base: @propagate_inbounds
#
#"""
#new_cache(a::InplaceArray)
#
#getindex!(cache,a::InplaceArray,i::Integer)
#getindex!(cache,a::InplaceArray,I::Integer...)
#"""
#abstract type InplaceArray{T,N} <: AbstractArray{T,N} end
#
#function getindex! end
#
#function test_inplace_array(
#  a::InplaceArray{T,N}, b::AbstractArray{T,N},cmp=(==)) where {T,N}
#
#  @test cmp(a,b)
#
#  cache = new_cache(a)
#
#  t = true
#  for i in eachindex(a)
#    bi = b[i]
#    ai = getindex!(cache,a,i)
#    t = t && cmp(bi,ai)
#  end
#
#  @test t
#
#  @test IndexStyle(a) == IndexStyle(b)
#
#  true
#end
#
#struct InplaceArrayFromArray{T,N,A<:AbstractArray} <: InplaceArray{T,N}
#  array::A
#  function InplaceArrayFromArray(array::AbstractArray{T,N}) where {T,N}
#    A = typeof(array)
#    new{T,N,A}(array)
#  end
#end
#
#"""
#Construct an inplace Array from an AbstractArray
#"""
#InplaceArray(a::AbstractArray) = InplaceArrayFromArray(a)
#
#new_cache(::InplaceArrayFromArray) = nothing
#
#@propagate_inbounds function getindex!(::Nothing,a::InplaceArrayFromArray,I...)
#  a.array[I...]
#end
#
#Base.size(a::InplaceArrayFromArray) = size(a.array)
#
#@propagate_inbounds function Base.getindex(
#  a::InplaceArrayFromArray,I...)
#  a.array[I...]
#end
#
#@propagate_inbounds function Base.setindex!(
#  a::InplaceArrayFromArray,v,I...)
#  a.array[I...] = v
#end
#
#function Base.IndexStyle(
#  ::Type{InplaceArrayFromArray{T,N,A}}) where {T,N,A}
#  IndexStyle(A)
#end
#
## Implement lazy operations
#
#new_cache(a::InplaceArray,index...) = new_cache(a)
#
#@inline evaluate!(cache,a::InplaceArray,i...) = getindex!(cache,a,i...)





