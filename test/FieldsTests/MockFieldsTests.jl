module MockFieldsTests

using InplaceArrays.Fields
using InplaceArrays.Fields: MockField, MockBasis
using TensorValues

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
test_field(f,x,fx,grad=∇fx)

ndof = 8
b = MockBasis(d,v,ndof)
bx = fill(v,ndof,np)
∇bx = fill(VectorValue(v,0.0),ndof,np)
test_field(b,x,bx,grad=∇bx)

end # module
