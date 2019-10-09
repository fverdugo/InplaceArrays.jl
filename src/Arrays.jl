module Arrays

using Test
using InplaceArrays

export test_inplace_array
export evaluate_functor_elemwise
export array_cache
export array_caches
export getindex!
export getitems!
export testvalue

import InplaceArrays: functor_cache
import InplaceArrays: evaluate_functor!
using InplaceArrays.Functors: _split

"""
testvalue(::Type)
"""
function testvalue end

testvalue(::Type{T}) where T = zero(T)

function testvalue(::Type{T}) where T<:AbstractArray{E,N} where {E,N}
   similar(T,fill(0,N)...)
end

"""
array_cache(hash::Dict,a)
"""
function array_cache end

function array_cache(a)
  hash = Dict{UInt,Any}()
  array_cache(hash,a)
end

"""
getindex!(cache,a,index...)
"""
function getindex! end

array_cache(hash::Dict,::AbstractArray) = nothing

getindex!(cache,a::AbstractArray,i...) = a[i...]

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

# Work with several arrays at once

function getitems!(cf::Tuple,a::Tuple{Vararg{<:AbstractArray}},i...)
  _getitems!(cf,i,a...)
end

function _getitems!(c,i,a,b...)
  ca,cb = _split(c...)
  ai = getindex!(ca,a,i...)
  bi = getitems!(cb,b,i...)
  (ai,bi...)
end

function _getitems!(c,i,a)
  ca, = c
  ai = getindex!(ca,a,i...)
  (ai,)
end

function array_caches(a::AbstractArray,b::AbstractArray...)
  ca = array_cache(a)
  cb = array_caches(b...)
  (ca,cb...)
end

function array_caches(a::AbstractArray)
  ca = array_cache(a)
  (ca,)
end


"""
evaluate_functor_elemwise(f,a::AbstractArray...)

Returns a (lazy) array representing the evaluation of the
given functor `f` to the entries of the input arrays `a`.
The returned array `r` is such that
`r[i] == evaluate(f,a1[i],a2[i],...)`
"""
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

struct ArrayFunctor{A}
  array::A
  function ArrayFunctor(a::AbstractArray)
    new{typeof(a)}(a)
  end
end

functor_cache(hash::Dict,f::ArrayFunctor,i...) = array_cache(hash,f.array)

evaluate_functor!(cache,f::ArrayFunctor,i...) = getindex!(cache,f.array,i...)

struct ResultArray{T,N,I,F} <: AbstractArray{T,N}
  size::NTuple{N,Int}
  f::F
end

function Base.getindex(a::ResultArray,i...)
  cache = functor_cache(a.f,i...)
  evaluate_functor!(cache,a.f,i...)
end

function getindex!(cache,a::ResultArray,i...)
  cf, e = cache
  v = e.fx
  if e.x != i
    v = evaluate_functor!(cf,a.f,i...)
    e.x = i
    e.fx = v
  end
   v
end

function array_cache(hash::Dict,a::ResultArray)
  if length(a)>0
    id = objectid(a)
    if haskey(hash,id)
      cache = hash[id]
    else
      i = 1
      cf = functor_cache(hash,a.f,i)
      fi = evaluate_functor!(cf,a.f,i)
      e = Evaluation((i,),fi)
      cache = (cf,e)
      hash[id] = cache
    end
    return cache
  else
    return nothing
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

function index_functor(a::AbstractArray)
  ArrayFunctor(a)
end

#function index_functor(a::ResultArray)
#  a.f
#end

function _array_functors(a,b...)
  c = index_functor(a)
  d = _array_functors(b...)
  (c,d...)
end

function _array_functors(a)
  c = index_functor(a)
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

mutable struct Evaluation{X,F}
  x::X
  fx::F
  function Evaluation(x::X,fx::F) where {X,F}
    new{X,F}(x,fx)
  end
end

end # module
