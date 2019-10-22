module MockFields

using Test
using TensorValues
using InplaceArrays.CachedArrays
using InplaceArrays


import InplaceArrays: ∇
import InplaceArrays: new_cache
import InplaceArrays: evaluate!
import InplaceArrays: gradient
import InplaceArrays: return_type
import InplaceArrays: num_dofs

export MockField
export MockBasis

struct MockField{D,T} <: Field{D,T}
  v::T
  function MockField(d::Int,v::T) where T
    new{d,T}(v)
  end
end

function return_type(f::MockField)
  v = new_cache(f)
  typeof(v)
end

function new_cache(f::MockField)
  T = valuetype(f)
  v = CachedVector(T)
  v
end

function evaluate!(v,f::MockField,x)
  setsize!(v,(length(x),))
  for (i,xi) in enumerate(x)
    v[i] = f.v*xi[1]
  end
  v
end

function gradient(f::MockField)
  T = valuetype(f)
  E = eltype(T)
  D = pointdim(f)
  P = Point{D,E}
  _p = zero(mutable(P))
  _p[1] = one(E)
  p = Point(_p)
  vg = outer(p,f.v)
  MockField(D,vg)
end

struct MockBasis{D,T} <: Basis{D,T}
  v::T
  ndofs::Int
  function MockBasis(d::Int,v::T,ndofs::Int) where T
    new{d,T}(v,ndofs)
  end
end

num_dofs(b::MockBasis) = b.ndofs

function return_type(f::MockBasis)
  v = new_cache(f)
  typeof(v)
end

function evaluate!(v,f::MockBasis,x)
  setsize!(v,(f.ndofs,length(x)))
  for (i,xi) in enumerate(x)
    for j in 1:f.ndofs
      v[j,i] = f.v*xi[1]
    end
  end
  v
end

function new_cache(f::MockBasis)
  T = valuetype(f)
  v = CachedMatrix(T)
  v
end

# TODO remove all Int16 from all code
function gradient(f::MockBasis)
  T = valuetype(f)
  E = eltype(T)
  D = pointdim(f)
  P = Point{D,E}
  _p = zero(mutable(P))
  _p[1] = one(E)
  p = Point(_p)
  vg = outer(p,f.v)
  MockBasis(D,vg,f.ndofs)
end

end # module
