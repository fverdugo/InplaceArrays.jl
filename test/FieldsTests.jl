module FieldTests

using Test
using TensorValues
using InplaceArrays.CachedArrays
using InplaceArrays
import InplaceArrays: ∇
import InplaceArrays: new_cache
import InplaceArrays: evaluate!
import InplaceArrays: gradient

struct MockField{D,T} <: Field{D,T}
  v::T
  function MockField(d::Int,v::T) where T
    new{d,T}(v)
  end
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

np = 4
p = Point(1,2)
x = fill(p,np)

v = 3.0
d = 2
f = MockField(d,v)
fx = fill(v,np)
test_field(f,x,fx)

∇fx = fill(VectorValue(v,0.0),np)
∇f = gradient(f)
test_field(∇f,x,∇fx)

@test gradtype(f) == typeof(∇f.v)
@test gradtype(∇f) == MultiValue{Tuple{2,2},Float64,2,4}

np = 4
p = Point(1,2)
x = fill(p,np)
v = 3.0
d = 2
f = MockField(d,v)
g = apply(-,f)
gx = fill(-v,np)
∇gx = fill(-VectorValue(v,0.0),np)
test_field_with_gradient(g,x,gx,∇gx)

fun(x) = 4*x
∇fun(x) = VectorValue(4.0,4.0)
∇(::typeof(fun)) = ∇fun

np = 4
p = Point(1,2)
x = fill(p,np)
v = 3.0
d = 2
f = MockField(d,v)
g = apply(fun,f)
gx = fill(fun(v),np)
∇gx = fill(∇fun(v),np)
test_field_with_gradient(g,x,gx,∇gx)


end # module
