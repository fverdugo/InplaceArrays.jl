module LinComb

using InplaceArrays
using TensorValues

import InplaceArrays: evaluate_functor!
import InplaceArrays: functor_cache
import InplaceArrays: functor_return_type

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

#function evaluate!(cache,f::LinCombField,x)
#  cb, ck = cache
#  bx = evaluate!(cb,f.b,x)
#  v = f.v
#  evaluate_functor!(ck,f.k,bx,v)
#end
#
#function gradient(f::LinCombField)
#  g = gradient(f.b)
#  v = f.v
#  LinCombField(g,v)
#end
#
#function getindex!(cache,a::LinCombArray,i...)
#  cb, cv = cache
#  bi = getindex!(cb,a.b,i...)
#  vi = getindex!(cv,a,v,i...)
#  LinCombField(bi,vi)
#end
#
#function evaluate_array_of_functors()
#end
#
#function lincomb(b::CellBasis,v::CellArray)
#end

end # module
