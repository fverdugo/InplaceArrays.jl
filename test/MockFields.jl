include("../src/Fields.jl")
module MockFields

using Test
using TensorValues
using InplaceArrays.CachedArrays
using InplaceArrays


#import InplaceArrays: ∇
#import InplaceArrays: new_cache
#import InplaceArrays: evaluate!
#import InplaceArrays: gradient
#import InplaceArrays: return_type

using ..Fields
import ..Fields: ∇
import ..Fields: new_cache
import ..Fields: evaluate!
import ..Fields: gradient
import ..Fields: return_type

export MockField

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
  D = pointdim(f)
  P = Point{D,Int16}
  _p = zero(mutable(P))
  _p[1] = Int16(1)
  p = Point(_p)
  vg = outer(p,f.v)
  MockField(D,vg)
end

end # module
