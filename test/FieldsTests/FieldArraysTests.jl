module FieldArraysTests

using Test
using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.Fields: MockField, MockBasis
using InplaceArrays.Fields: Valued
using FillArrays
using TensorValues # TODO

np = 4
p = Point(1,2)
x = fill(p,np)

v = 3.0
d = 2
f = MockField{d}(v)
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

w = 2.0
aw = fill(w,l)
ag = apply_to_field(elem(+),af,aw)
gx = fill(v+w,np)
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

k = Valued(elem(-))

np = 4
p = Point(1,2)
x = fill(p,np)
v = 3.0
d = 2
f = MockField{d}(v)
fx = evaluate(f,x)
∇fx = evaluate(∇(f),x)

test_kernel(k,(1,2),-1)
test_kernel(k,(f,2),apply_kernel_to_field(elem(-),f,2))
test_kernel(k,(2,f),apply_kernel_to_field(elem(-),2,f))
test_kernel(k,(f,f),apply_kernel_to_field(elem(-),f,f))

g = apply_kernel(k,f,1)
test_field(g,x,fx.-1,grad=∇fx)

g = apply_kernel(k,1,f)
test_field(g,x,1 .- fx,grad=-∇fx)

g = apply_kernel(k,f,f)
test_field(g,x,fx .- fx,grad=∇fx.-∇fx)

l = 10
af = Fill(f,l)
ax = fill(x,l)

ag = apply_to_field(elem(-),af)
agx = evaluate(ag,ax)
gx = fill(-v,np)
∇gx = fill(VectorValue(-v,0.0),np)
agx = fill(gx,l)
a∇gx = fill(∇gx,l)
test_array_of_fields(ag,ax,agx,grad=a∇gx)

ag = apply_to_field(elem(-),ax)
@test isa(testitem(testitem(ag)),Point)

np = 4
p = Point(1,2)
x = fill(p,np)
v = 2.0
d = 2
ndof = 8
wi = 3.0
w = fill(wi,ndof)
ri = fill(v+wi,ndof)
r = fill(v+wi,ndof,np)
f = MockBasis{d}(v,ndof)
g = apply_kernel_to_field(elem(+),f,w)
test_field(g,[p,],reshape(ri,(ndof,1)))
test_field(g,x,r)

np = 4
p = Point(1,2)
x = fill(p,np)
v = 2.0
d = 2
ndof = 8
wi = 3.0
w = fill(wi,ndof)
ri = fill(v+wi,ndof)
r = fill(v+wi,ndof,np)
f = MockBasis{d}(v,ndof)
∇fx = evaluate(∇(f),x)
af = Fill(f,l)
ax = fill(x,l)
aw = fill(w,l)
ag = apply_to_field(elem(+),af,aw)
agx = fill(r,l)
a∇gx = fill(∇fx,l)
test_array_of_fields(ag,ax,agx,grad=a∇gx)

end # module
