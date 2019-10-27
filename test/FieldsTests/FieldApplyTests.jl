module ApplyTests

using Test
using InplaceArrays.Arrays
using InplaceArrays.Fields
using FillArrays
using TensorValues

using InplaceArrays.Fields: MockField
using InplaceArrays.Fields: Valued

k = elem(-)

v = 3.0
d = 2
f = MockField{d}(v)
g = apply_kernel_to_field(k,f)

np = 4
p1 = Point(1,2)
p2 = Point(2,1)
p3 = Point(4,3)
p4 = Point(6,1)
x = [p1,p2,p3,p4]

fx = evaluate(f,x)
∇fx = evaluate(∇(f),x)
gx = apply_kernel_to_field(k,fx)
∇gx = apply_kernel_to_field(k,∇fx)
test_field(g,x,gx,grad=∇gx)

@test g == apply_kernel_to_field(k,f)

fi = 3.0
gi = 4.5
d = 2
f = MockField{d}(fi)
g = MockField{d}(gi)
h = apply_kernel_to_field(k,f,g)
hp1 = apply_kernel(k,evaluate(f,p1),evaluate(g,p1))
∇hp1 = apply_kernel(k,evaluate(∇(f),p1),evaluate(∇(g),p1))
test_field(h,[p1,],[hp1,],grad=[∇hp1,])

fi = 3.0
gi = 4.5
d = 2
f = MockField{d}(fi)
g = gi
h = apply_kernel_to_field(k,f,g)
hp1 = apply_kernel(k,evaluate(f,p1),gi)
∇hp1 = apply_kernel(k,evaluate(∇(f),p1),0.0)
test_field(h,[p1,],[hp1,],grad=[∇hp1,])

fi = 3.0
gi = 4.5
d = 2
f = MockField{d}(fi)
g = gi
h = apply_kernel_to_field(k,g,f)
hp1 = apply_kernel(k,gi,evaluate(f,p1))
∇hp1 = apply_kernel(k,0.0,evaluate(∇(f),p1))
test_field(h,[p1,],[hp1,],grad=[∇hp1,])

fi = 3.0
gi = [1,2,3]
d = 2
f = MockField{d}(fi)
g = MockField{d}(gi)
h = apply_kernel_to_field(k,f,g)
hp1 = apply_kernel(k,evaluate(f,p1),evaluate(g,p1))
hp1 = reshape(hp1,(3,1))
test_field(h,[p1,],hp1)

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


end # module
