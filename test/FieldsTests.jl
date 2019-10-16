module FieldTests

using Test
using TensorValues
using InplaceArrays.CachedArrays
using InplaceArrays
import InplaceArrays: ∇
import InplaceArrays: new_cache
import InplaceArrays: evaluate!
import InplaceArrays: gradient

using ..MockFields

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
@test isa(functor_apply(-,f),Field)
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
