module FieldArraysTests

using Test
using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.Fields: MockField
using FillArrays
using TensorValues # TODO

np = 4
p = Point(1,2)
x = fill(p,np)

v = 3.0
d = 2
f = MockField(d,v)
fx = fill(v,np)
∇fx = fill(VectorValue(v,0.0),np)

l = 10
af = Fill(f,l)
ax = fill(x,l)
afx = fill(fx,l)
a∇fx = fill(∇fx,l)
test_array_of_fields(af,ax,afx,grad=a∇fx)

ag = apply_to_field(elem(+),af,af)
gx = fill(v+v,np)
∇gx = fill(VectorValue(v+v,0.0),np)
agx = fill(gx,l)
a∇gx = fill(∇gx,l)
test_array_of_fields(ag,ax,agx,grad=a∇gx)

ap = fill(p,l)
ag = apply_to_field(elem(+),af,ap)
gx = fill(v+p,np)
∇gx = fill(VectorValue(v,0.0),np)
agx = fill(gx,l)
a∇gx = fill(∇gx,l)

test_array_of_fields(ag,ax,agx,grad=a∇gx)

l = 10
af = Fill(f,l)
ax = Fill(x,l)
ag = apply_to_field(elem(+),af,af)
r1 = evaluate(ag,ax)
@test isa(r1,Fill)

end # module
