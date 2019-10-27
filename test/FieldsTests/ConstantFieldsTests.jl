module ConstantFieldsTests

using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.Fields: ConstantField
using InplaceArrays.Fields: ToField
using TensorValues # TODO

d = 2
v = 3.0
f = ConstantField{d}(v)
xi = Point(2,1)
np = 4
x = fill(xi,np)
fx = fill(v,np)
∇fx = fill(zero(outer(xi,v)),np)
test_field(f,x,fx,grad=∇fx)

d = 2
ndofs = 8
vi = 2.0
v = fill(vi,ndofs)
f = ConstantField{d}(v)
xi = Point(2,1)
np = 4
x = fill(xi,np)
fx = fill(vi,ndofs,np)
∇fx = fill(zero(outer(xi,vi)),ndofs,np)
test_field(f,x,fx,grad=∇fx)

l = 10
fi = 3.0
ndofs = 8
f = fill(fi,ndofs)
af = fill(f,l)
k = ToField{d}()
ag = apply(k, af)
xi = Point(2,1)
∇fi = zero(outer(xi,fi))
np = 4
x = fill(xi,np)
ax = fill(x,l)
agx = fill(fill(fi,ndofs,np),l)
a∇gx = fill(fill(∇fi,ndofs,np),l)
test_array_of_fields(ag,ax,agx,grad=a∇gx)

end # module
