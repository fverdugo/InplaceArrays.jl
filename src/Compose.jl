module Compose

using InplaceArrays

export compose

import InplaceArrays: evaluate_functor!
import InplaceArrays: functor_cache
import InplaceArrays: functor_return_type
import InplaceArrays: evaluate!
import InplaceArrays: new_cache
import InplaceArrays: return_type
import InplaceArrays: gradient
import InplaceArrays: array_cache
import InplaceArrays: getindex!
import InplaceArrays: evaluate_array_of_functors
import Base: size
import Base: getindex
import Base: ndims
import Base: IndexStyle
import InplaceArrays.CellFields: evaltype
import InplaceArrays: valuetype

struct ComposeKernel{T,F}
  f::F
  @inline function ComposeKernel(::Type{T},f::Function) where {T,F}
    new{T,typeof(f)}(f)
  end
end

valuetype(::Type{ComposeKernel{T,F}}) where {T,F} = T

@inline function evaluate_functor!(cache,f::ComposeKernel,x)
  n = length(x)
  setsize!(cache,(n,))
  _kernel!(cache,f.f,x)
  cache
end

@inline function _kernel!(r,f,x)
  for i in eachindex(x)
    r[i] = f(x[i])
  end
end

function functor_cache(f::ComposeKernel{T},x) where {T}
  npoin = length(x)
  CachedArray(zeros(T,npoin))
end

function functor_return_type(f::ComposeKernel{T},x) where {T}
  CachedArray{T,1,Array{T,1}}
end

struct ComposedField{D,T,G,F} <: Field{D,T}
  k::ComposeKernel{T,G}
  f::F
  @inline function ComposedField(::Type{T},g::Function,f::Field{D}) where {T,D}
    k = ComposeKernel(T,g)
    G = typeof(g)
    F = typeof(f)
    new{D,T,G,F}(k,f)
  end
end

function return_type(f::ComposedField)
  F = return_type(f.f)
  functor_return_type(f.k,F)
end

@inline function evaluate!(cache,f::ComposedField,x)
  cf, ck = cache
  fx = evaluate!(cf,f.f,x)
  evaluate_functor!(ck,f.k,fx)
end

function new_cache(f::ComposedField)
  B = return_type(f.f)
  ck = functor_cache(f.k,testvalue(B))
  cf = new_cache(f.f)
  (cf, ck)
end

function gradient(f::ComposedField)
  g = gradient(f.k.f)
  T = gradtype(f)
  ComposedField(T,g,f.f)
end

function compose(::Type{G},g::Function,f::CellField) where {G}
  a = ComposedArray(G,g,f.array)
  CellValue(f,a)
end

struct ComposedArray{T,N,F,K} <:AbstractArray{T,N}
  f::F
  k::K
  function ComposedArray(::Type{G},g::Function,f::AbstractArray) where {G,D}
    k = ComposeKernel(G,g)
    K = typeof(k)
    F = typeof(f)
    fi = testitem(f)
    T = typeof(ComposedField(G,g,fi))
    N = ndims(f)
    new{T,N,F,K}(f,k)
  end
end

size(a::ComposedArray) = size(a.f)

IndexStyle(::Type{ComposedArray{T,N,F,K}}) where {T,N,F,K} = IndexStyle(F)

# TODO New AbstractInplaceArray that implements this for all cases
function getindex(a::ComposedArray,i::Integer...)
  cache = array_cache(a)
  getindex!(cache,a,i...)
end

@inline function getindex!(ca,a::ComposedArray,i...)
  fi = getindex!(ca,a.f,i...)
  T = valuetype(a.k)
  ComposedField(T,a.k.f,fi)
end

function array_cache(a::ComposedArray)
  array_cache(a.f)
end

function gradient(a::ComposedArray)
  g = gradient(a.k.f)
  ai = testitem(a)
  T = gradtype(ai)
  ComposedArray(T,g,a.f)
end

function evaluate_array_of_functors(a::ComposedArray,x::AbstractArray)
  fx = evaluate_array_of_functors(a.f,x)
  evaluate_array_of_functors(a.k,fx)
end

end # module
