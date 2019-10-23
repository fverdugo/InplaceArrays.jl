
"""
$(SIGNATURES)
"""
function apply(f,a::AbstractArray...)
  s = common_size(a...)
  apply(Fill(f,s...),a...)
end

"""
$(SIGNATURES)
"""
function apply(f::AbstractArray,a::AbstractArray...)
  AppliedArray(f,a...)
end

# Helpers

struct AppliedArray{T,N,F,G} <: AbstractArray{T,N}
  g::G
  f::F
  size::NTuple{N,Int}
  function AppliedArray(g::AbstractArray,f::AbstractArray...)
    G = typeof(g)
    F = typeof(f)
    gi = testitem(g) #Assumes that all kernels return the same type
    Ts = map(eltype,f)
    T = kernel_return_type(gi,Ts...)
    N, s = _prepare_shape(g,f...)
    new{T,N,F,G}(g,f,s)
  end
end

function uses_hash(::Type{<:AppliedArray})
  Val(true)
end

function array_cache(hash::Dict,a::AppliedArray)
    id = objectid(a)
    if haskey(hash,id)
      cache = hash[id]
    else
      cache = _array_cache(hash,a)
      hash[id] = cache
    end
    cache
end

function _array_cache(hash,a::AppliedArray)
  cg = array_cache(hash,a.g)
  gi = testitem(a.g)
  fi = testitems(a.f...)
  cf = array_caches(hash,a.f...)
  cgi = kernel_cache(gi,fi...)
  ai = apply_kernel!(cgi,gi,fi...)
  i = -testitem(eachindex(a))
  e = Evaluation((i,),ai)
  c = (cg, cgi, cf)
  (c,e)
end

function getindex!(cache,a::AppliedArray,i::Integer...)
  li = LinearIndices(a)
  getindex!(cache,a,li[i...])
end

function getindex!(cache,a::AppliedArray,i::Integer)
  _cached_getindex!(cache,a,(i,))
end

function getindex!(cache,a::AppliedArray,i::CartesianIndex)
  _cached_getindex!(cache,a,Tuple(i))
end

function _cached_getindex!(cache,a::AppliedArray,i::Tuple)
  c, e = cache
  v = e.fx
  if e.x != i
    v = _getindex!(c,a,i...)
    e.x = i
    e.fx = v
  end
   v
end

function _getindex!(cache,a::AppliedArray,i...)
  cg, cgi, cf = cache
  gi = getindex!(cg,a.g,i...)
  fi = getitems!(cf,a.f,i...)
  vi = apply_kernel!(cgi,gi,fi...)
  vi
end

function Base.getindex(a::AppliedArray,i...)
  ca = array_cache(a)
  getindex!(ca,a,i...)
end

function Base.IndexStyle(
  ::Type{AppliedArray{T,N,F,G}}) where {T,N,F,G}
  common_index_style(F)
end

Base.size(a::AppliedArray) = a.size

function _prepare_shape(a...)
  s = common_size(a...)
  N = length(s)
  (N,s)
end

function common_size(a::AbstractArray...)
  a1, = a
  c = all([size(a1) == size(ai) for ai in a])
  if !c
    error("Array sizes $(map(size,a)) are not compatible.")
  end
  s = size(a1)
  s
end

#TODO not sure what to do with shape and index-style
function common_index_style(::Type{<:Tuple})
  IndexLinear()
end

mutable struct Evaluation{X,F}
  x::X
  fx::F
  function Evaluation(x::X,fx::F) where {X,F}
    new{X,F}(x,fx)
  end
end

# TODO Particular implementations for Fill
# TODO Implement Compressed
# TODO Think about iteration and sub-iteration
