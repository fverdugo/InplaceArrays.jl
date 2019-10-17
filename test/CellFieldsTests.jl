module CellFieldsTests

using Test
using TensorValues
using InplaceArrays
using ..MockFields
import InplaceArrays: ∇

np = 4
v = 3.0
d = 2
f = MockField(d,v)
fx = fill(v,np)
∇fx = fill(VectorValue(v,0.0),np)

l = 10
cf = CellValue(f,l)
afx = fill(fx,l)
a∇fx = fill(∇fx,l)

g = gradient(cf)
g2 = gradient(cf)
@test g === g2
g2 = gradient(cf)
@test objectid(g) == objectid(g2)

np = 4
p = Point(1,2)
x = fill(p,np)
cx = CellValue(x,l)

test_cell_field_with_gradient(cf,cx,afx,a∇fx)

fun(x) = 4*x
∇fun(x) = VectorValue(4.0,4.0)
∇(::typeof(fun)) = ∇fun

#TODO
#cg = apply(bcast(fun),cf)
#agx = fill(fill(fun(v),np),l)
#a∇gx = fill(fill(∇fun(v),np),l)
#test_cell_field_with_gradient(cg,cx,agx,a∇gx)


end # module
