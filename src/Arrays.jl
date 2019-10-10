module Arrays

using Test
using InplaceArrays
using FillArrays

export test_inplace_array
export test_inplace_array_of_functors
export evaluate_functor_elemwise
export evaluate_array_of_functors
export apply_functor_elemwise
export apply_array_of_functors
export array_cache
export array_caches
export array_of_functors_cache
export getindex!
export getitems!
export testvalue
export testitem
export testitems
export uses_hash

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

function testitem(a::Fill)
  a.value
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
array_cache(a::AbstractArray)
or
array_cache(hash::Dict,a::AbstractArray)
if
uses_hash(typeof(a)) == Val(true)
"""
function array_cache end

function array_cache(hash,a::T) where T
  if uses_hash(T) == Val(true)
    error("array_cache(::Dict,::$T) not defined")
  end
  array_cache(a)
end

function array_cache(a::T) where T
  _default_array_cache(a,uses_hash(T))
end

function _default_array_cache(a,::Val{false})
  nothing
end

function _default_array_cache(a,::Val{true})
  hash = Dict{UInt,Any}()
  array_cache(hash,a)
end

"""
uses_hash(::Type) -> Val{<:Bool}
"""
function uses_hash end

uses_hash(::Type{<:AbstractArray}) = Val(false)

uses_hash(::T) where T = uses_hash(T)

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

getindex!(cache,a::AbstractArray,i...) = a[i...]

# Test the interface

function test_inplace_array(
  a::AbstractArray{T,N}, b::AbstractArray{S,N},cmp=(==)) where {T,S,N}
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
  v = evaluate_array_of_functors(a,x...)
  test_inplace_array(v,r,cmp)
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
  hash = Dict{UInt,Any}()
  array_caches(hash,a,b...)
end

function array_caches(hash::Dict,a::AbstractArray,b::AbstractArray...)
  ca = array_cache(hash,a)
  cb = array_caches(hash,b...)
  (ca,cb...)
end

function array_caches(hash::Dict,a::AbstractArray)
  ca = array_cache(hash,a)
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
  s = common_size(a...)
  EvaluatedArray(Fill(f,s...),a...)
end

function _prepare_shape(a...)
  s = common_size(a...)
  N = length(s)
  I = common_index_style(a...)
  (N,s,I)
end

function common_size(a::AbstractArray...)
  a1, = a
  c = all([size(a1) == size(ai) for ai in a])
  if !c
    error("Array sizes are not compatible.")
  end
  s = size(a1)
  s
end

#TODO not sure what to do with shape and index-style
function common_index_style(a::AbstractArray...)
  IndexLinear()
end

mutable struct Evaluation{X,F}
  x::X
  fx::F
  function Evaluation(x::X,fx::F) where {X,F}
    new{X,F}(x,fx)
  end
end

function apply_functor_elemwise(g,f::AbstractArray...)
  s = common_size(f...)
  apply_array_of_functors(Fill(g,s...),f...)
end

function apply_array_of_functors(g::AbstractArray,f::AbstractArray...)
  AppliedArray(g,f...)
end

struct AppliedArray{T,N,I,G,F<:Tuple} <:AbstractArray{T,N}
  size::NTuple{N,Int}
  g::G
  f::F
  function AppliedArray(g::AbstractArray,f::AbstractArray...)
    fi = testitems(f...)
    gi = testitem(g)
    a = apply_functor(gi,fi...)
    T = typeof(a)
    N, size, I = _prepare_shape(g,f...)
    G = typeof(g)
    F = typeof(f)
    new{T,N,I,G,F}(size,g,f)
  end
end

function testitem(a::AppliedArray)
  fi = testitems(a.f...)
  gi = testitem(a.g)
  r = apply_functor(gi,fi...)
  r
end

function uses_hash(::Type{<:AppliedArray})
  Val(true)
end

function array_cache(hash::Dict,a::AppliedArray)
  cf = array_caches(hash,a.f...)
  cg = array_cache(hash,a.g)
  (cf,cg)
end

@inline function getindex!(cache,a::AppliedArray,i...)
  cf, cg = cache
  fi = getitems!(cf,a.f,i...)
  gi = getindex!(cg,a.g,i...)
  r = apply_functor(gi,fi...)
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
  EvaluatedArray(f,a...)
end

# We need an operation tree in terms of evaluated arrays as much
# as possible in order to allow caching of intermediate results
function evaluate_array_of_functors(f::AppliedArray,a::AbstractArray...)
  ffx = [ evaluate_array_of_functors(ffi,a...) for ffi in f.f ]
  evaluate_array_of_functors(f.g,ffx...)
end

struct EvaluatedArray{T,N,I,F,G} <: AbstractArray{T,N}
  g::G
  f::F
  size::NTuple{N,Int}
  function EvaluatedArray(g::AbstractArray,f::AbstractArray...)
    G = typeof(g)
    F = typeof(f)
    gi = testitem(g)
    fi = testitems(f...)
    vi = evaluate_functor(gi,fi...)
    T = typeof(vi)
    N, size, I = _prepare_shape(g,f...)
    new{T,N,I,F,G}(g,f,size)
  end
end

function uses_hash(::Type{<:EvaluatedArray})
  Val(true)
end

function array_cache(hash::Dict,a::EvaluatedArray)
    id = objectid(a)
    if haskey(hash,id)
      cache = hash[id]
    else
      cache = _array_cache(hash,a)
      hash[id] = cache
    end
    cache
end

function _array_cache(hash,a::EvaluatedArray)
  cg = array_cache(hash,a.g)
  gi = testitem(a.g)
  fi = testitems(a.f...)
  cf = array_caches(hash,a.f...)
  cgi = functor_cache(gi,fi...)
  ai = evaluate_functor!(cgi,gi,fi...)
  i = -testitem(eachindex(a))
  e = Evaluation((i,),ai)
  c = (cg, cgi, cf)
  (c,e)
end

function getindex!(cache,a::EvaluatedArray,i::Integer...)
  _cached_getindex!(cache,a,i)
end

function getindex!(cache,a::EvaluatedArray,i::CartesianIndex)
  _cached_getindex!(cache,a,Tuple(i))
end

function _cached_getindex!(cache,a::EvaluatedArray,i::Tuple)
  c, e = cache
  v = e.fx
  if e.x != i
    v = _getindex!(c,a,i...)
    e.x = i
    e.fx = v
  end
   v
end

function _getindex!(cache,a::EvaluatedArray,i...)
  cg, cgi, cf = cache
  gi = getindex!(cg,a.g,i...)
  fi = getitems!(cf,a.f,i...)
  vi = evaluate_functor!(cgi,gi,fi...)
  vi
end

function Base.getindex(a::EvaluatedArray,i...)
  ca = array_cache(a)
  getindex!(ca,a,i...)
end

function Base.IndexStyle(
  ::Type{EvaluatedArray{T,N,I,F,G}}) where {T,N,I,F,G}
  I
end

Base.size(a::EvaluatedArray) = a.size

# TODO Particular implementations for Fill
# TODO Implement Compressed
# TODO Think about iteration and sub-iteration

end # module
