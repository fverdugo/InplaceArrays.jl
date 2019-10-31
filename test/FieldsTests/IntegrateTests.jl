module IntegrateTests

using Test
using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.Fields: OtherMockBasis, MockBasis, MockField
using FillArrays
using TensorValues # TODO

p1 = Point(2,2)
p2 = Point(4,2)
p3 = Point(1,3)
p4 = Point(5,2)
x = [p1,p2,p3,p4]
np = length(x)

d = 2
v = 3.0
ndof = 8
i = MockField{d}(v)

c = fill(1.0,ndof)
f = OtherMockBasis{d}(ndof)
ϕ = lincomb(f,c)
ri = 5.0
r = MockBasis{d}(ri,ndof)
j = ∇(ϕ)
w = fill(1/np,np)
b = attachmap(r,ϕ)

@show integrate(i,x,w,j)

@show integrate(b,x,w,j)

end # module
