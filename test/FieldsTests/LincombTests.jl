module LincombTests

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
v = 2.0
d = 2
ndof = 8
wi = 3.0
w = fill(wi,ndof)
ri = fill(v+wi,ndof)
r = fill(v+wi,ndof,np)
f = MockBasis{d}(v,ndof)
∇fx = evaluate(∇(f),x)

l = 10

af = Fill(f,l)
ax = fill(x,l)
aw = fill(w,l)
ag = lincomb(af,aw)
fp = evaluate(f,p)
∇fp = evaluate(∇(f),p)
gx = fill(dot(fp,w),np)
∇gx = fill(dot(∇fp,w),np)
agx = fill(gx,l)
a∇gx = fill(∇gx,l)
test_array_of_fields(ag,ax,agx,grad=a∇gx)

end #module
