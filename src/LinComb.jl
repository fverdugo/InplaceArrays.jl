module LinComb

using InplaceArrays
using InplaceArrays.Arrays: common_size

export lincomb

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
import InplaceArrays.CellFields: evaltype

# Kernel for the linear combination

struct LinCombKernel end

function evaluate_functor!(cache,f::LinCombKernel,b,v)
  _chech_sizes(b,v)
  ndofs, npoin = size(b)
  setsize!(cache,(npoin,))
  T = eltype(cache)
  _kernel!(cache,b,v,zero(T))
  cache
end

function _kernel!(r,b,v,z)
  ndofs, npoin = size(b)
  for j in 1:npoin
    r[j] = z
    for i in 1:ndofs
      r[j] += outer(b[i,j],v[i])
    end
  end
end

function functor_cache(f::LinCombKernel,b,v)
  _chech_sizes(b,v)
  T = return_type(outer,eltype(b),eltype(v))
  ndofs, npoin = size(b)
  CachedArray(zeros(T,npoin))
end

function _chech_sizes(b,v)
  ndofs, npoin = size(b)
  @assert length(v) == ndofs "Dofs in b (=$ndofs) and v (=$(length(v))) must be the same."
end

function functor_return_type(f::LinCombKernel,Ab,Av)
  T = return_type(outer,eltype(Ab),eltype(Av))
  CachedArray{T,1,Array{T,1}}
end

struct LinCombField{D,T,B,V} <: Field{D,T}
  b::B
  v::V
  k::LinCombKernel
  function LinCombField(
    basis::Basis{D,Tb},vals::AbstractVector{Tv}) where {D,Tb,Tv}
    T = typeof(outer(zero(Tb),zero(Tv)))
    B = typeof(basis)
    V = typeof(vals)
    k = LinCombKernel()
    new{D,T,B,V}(basis,vals,k)
  end
end

function return_type(f::LinCombField)
  B = return_type(f.b)
  V = typeof(f.v)
  functor_return_type(f.k,B,V)
end

function new_cache(f::LinCombField)
  B = return_type(f.b)
  V = typeof(f.v)
  ck = functor_cache(f.k,testvalue(B),testvalue(V))
  cb = new_cache(f.b)
  (cb, ck)
end

function evaluate!(cache,f::LinCombField,x)
  cb, ck = cache
  bx = evaluate!(cb,f.b,x)
  v = f.v
  evaluate_functor!(ck,f.k,bx,v)
end

function gradient(f::LinCombField)
  g = gradient(f.b)
  v = f.v
  LinCombField(g,v)
end

function lincomb(b::CellBasis,v::CellArray)
  a = LinCombArray(b.array,v.array)
  CellValue(a)
end

function ndims(::Type{<:FieldLike{D,T,N}}) where  {D,T,N}
  N
end

# TODO This is not true, in general is a CachedArray
# TODO evaltype sounds like return_type but at type level
function evaltype(::Type{T}) where T <: FieldLike
  S = valuetype(T)
  N = ndims(T)
  Array{S,N}
end

struct LinCombArray{T,N,B,V} <: AbstractArray{T,N}
  b::B
  v::V
  k::LinCombKernel
  s
  function LinCombArray(b::AbstractArray,v::AbstractArray)
    k = LinCombKernel()
    Bi = eltype(b)
    Vi = eltype(v)
    D = pointdim(Bi)
    Bxi = evaltype(Bi)
    Tr = functor_return_type(k,Bxi,Vi)
    Ti = eltype(Tr)
    T = LinCombField{D,Ti,Bi,Vi}
    s = common_size(b,v)
    N = length(s)
    B = typeof(b)
    V = typeof(v)
    new{T,N,B,V}(b,v,k,s)
  end
end

size(a::LinCombArray) = a.s

# TODO New AbstractInplaceArray that implements this for all cases
function getindex(a::LinCombArray,i::Integer...)
  cache = array_cache(a)
  getindex!(cache,a,i...)
end

function array_cache(a::LinCombArray)
  cb = array_cache(a.b)
  cv = array_cache(a.v)
  (cb,cv)
end

function getindex!(cache,a::LinCombArray,i...)
  cb, cv = cache
  bi = getindex!(cb,a.b,i...)
  vi = getindex!(cv,a.v,i...)
  LinCombField(bi,vi)
end

function evaluate_array_of_functors(a::LinCombArray,x::AbstractArray)
  bx = evaluate_array_of_functors(a.b,x)
  evaluate_array_of_functors(a.k,bx,a.v)
end

function gradient(a::LinCombArray)
  g = gradient(a.b)
  LinCombArray(g,a.v)
end

end # module
