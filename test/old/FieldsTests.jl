module FieldTests

using Test
using TensorValues
using InplaceArrays.CachedArrays
using InplaceArrays

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
test_field_with_gradient(f,x,fx,∇fx)

@test gradtype(f) == typeof(∇f.v)
@test gradtype(∇f) == MultiValue{Tuple{2,2},Float64,2,4}

np = 4
p = Point(1,2)
x = fill(p,np)
v = 3.0
d = 2
ndof = 4
b = MockBasis(d,v,ndof)
bx = fill(v,ndof,np)
∇bx = fill(VectorValue(v,0.0),ndof,np)
test_basis_with_gradient(b,x,bx,∇bx)

end # module
