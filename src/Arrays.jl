module Arrays

using Test
using InplaceArrays

export test_inplace_array
export test_inplace_array_of_functors
export evaluate_functor_elemwise
export evaluate_array_of_functors
export apply_functor_elemwise
export array_cache
export array_caches
export array_of_functors_cache
export getindex!
export getitems!
export testvalue
export testitem
export testitems

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
testitem(a::AbstractArray)
"""
function testitem end

function testitem(a::AbstractArray{T}) where T
  if length(a) >0
    first(a)
  else
    testvalue(T)
  end::T
end

function testitems(a::AbstractArray,b::AbstractArray...)
  va = testitem(a)
  vb = testitems(b...)
  (va,vb...)
end

function testitems(a::AbstractArray)
  va = testitem(a)
  (va,)
end

"""
array_cache(hash::Dict,a)
"""
function array_cache end

function array_cache(a)
  hash = Dict{UInt,Any}()
  array_cache(hash,a)
end

function array_of_functors_cache(a::AbstractArray,x...)
  xi = testitems(x...)
  cx = array_caches(x...)
  ai = testitem(a)
  cai = functor_cache(ai,xi...)
  ca = array_cache(a)
  (ca, cai, cx) # TODO think what to do with last argument
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
  t = true
  for i in eachindex(a)
    ai = getindex!(cache,a,i)
    t = t && (typeof(ai) == eltype(a))
    t = t && (typeof(ai) == T)
  end
  @test t
  @test IndexStyle(a) == IndexStyle(b)
  true
end

function test_inplace_array_of_functors(
  a::AbstractArray, x::Tuple, r::AbstractArray, cmp=(==) )
  ca, cai, cx = array_of_functors_cache(a,x...)
  t = true
  for i in eachindex(a)
    ai = getindex!(ca,a,i)
    xi = getitems!(cx,x,i...)
    vi = evaluate_functor!(cai,ai,xi...)
    t = t && cmp(vi,r[i])
  end
  @test t
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
  x = testitems(a...)
  N, size, I = _prepare_shape(a...)
  v = evaluate_functor(f,x...)
  T = typeof(v)
  b = _array_functors(a...)
  r = apply_functor(f,b...)
  F = typeof(r)
  EvaluatedArray{T,N,I,F}(size,r)
end

# TODO if we remove this and implement the operation tree at the array level,
# we don't need to expose hash in the Functor interface. In fact, we will only
# cach at the array level since we can efficiently compare indices. In general,
# one cannot efficienlty compare arbitrary functor arguments.
struct Indexed{A}
  array::A
  function Indexed(a::AbstractArray)
    new{typeof(a)}(a)
  end
end

functor_cache(hash::Dict,f::Indexed,i...) = array_cache(hash,f.array)

evaluate_functor!(cache,f::Indexed,i...) = getindex!(cache,f.array,i...)

struct EvaluatedArray{T,N,I,F} <: AbstractArray{T,N}
  size::NTuple{N,Int}
  f::F
end

function Base.getindex(a::EvaluatedArray,i...)
  cache = functor_cache(a.f,i...)
  evaluate_functor!(cache,a.f,i...)
end

function getindex!(cache,a::EvaluatedArray,i...)
  cf, e = cache
  v = e.fx
  if e.x != i
    v = evaluate_functor!(cf,a.f,i...)
    e.x = i
    e.fx = v
  end
   v
end

function array_cache(hash::Dict,a::EvaluatedArray)
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

function Base.IndexStyle(::Type{EvaluatedArray{T,N,I,F}}) where {T,N,I,F}
  I
end

Base.size(a::EvaluatedArray) = a.size

function index_functor(a::AbstractArray)
  Indexed(a)
end

#function index_functor(a::EvaluatedArray)
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

function apply_functor_elemwise(g,f::AbstractArray...)
  fi = testitems(f...)
  a = apply_functor(g,fi...)
  T = typeof(a)
  N, size, I = _prepare_shape(f...)
  G = typeof(g)
  F = typeof(f)
  AppliedArray{T,N,I,G,F}(size,g,f)
end

struct AppliedArray{T,N,I,G,F<:Tuple} <:AbstractArray{T,N}
  size::NTuple{N,Int}
  g::G
  f::F
end

function testitem(a::AppliedArray)
  fi = testitems(a.f...)
  r = apply_functor(a.g,fi...)
  r
end

function array_cache(a::AppliedArray)
  array_caches(a.f...)
end

@inline function getindex!(cache,a::AppliedArray,i...)
  fi = getitems!(cache,a.f,i...)
  r = apply_functor(a.g,fi...)
  r
end

function Base.getindex(a::AppliedArray,i...)
  cache = array_cache(a)
  getindex!(cache,a,i...)
end

Base.size(a::AppliedArray) = a.size

function Base.IndexStyle(
  ::Type{AppliedArray{T,N,I,G,F}}) where {T,N,I,G,F}
  I
end

function evaluate_array_of_functors(f::AbstractArray,a::AbstractArray...)
  ai = testitems(a...)
  fi = testitem(f)
  vi = evaluate_functor(fi,ai...)
  T = typeof(vi)
  N, size, I = _prepare_shape(f,a...)
  b = _array_functors(a...)
  g, = _array_functors(f)
  r = apply_meta_functor(g,b...)
  F = typeof(r)
  EvaluatedArray{T,N,I,F}(size,r)
end

end # module
