module ApplyTests

using Test
using InplaceArrays.Arrays
using InplaceArrays.Fields
using FillArrays
using TensorValues

using InplaceArrays.Fields: MockField, MockBasis

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
gx = apply_kernel(k,fx)
∇gx = apply_kernel(k,∇fx)
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


end # module
