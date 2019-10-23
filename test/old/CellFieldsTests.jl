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

cf2 = apply(bcast(-),cf)

np = 4
p = Point(1,2)
x = fill(p,np)
cx = CellValue(x,l)

fun(x) = 4*x
∇fun(x) = VectorValue(4.0,4.0)
∇(::typeof(fun)) = ∇fun

cg = apply(bcast(fun),cf)
agx = fill(fill(fun(v),np),l)
a∇gx = fill(fill(∇fun(v),np),l)
cgx = evaluate(cg,cx)
test_cell_value(cgx,agx)
c∇g = gradient(cg)
@test c∇g === gradient(cg)
@test c∇g === gradient(cg)
c∇gx = evaluate(c∇g,cx)
test_cell_value(c∇gx,a∇gx)
test_cell_field_like_with_gradient_no_array(cg,cx,agx,a∇gx)

cg = cf - cf
agx = fill(fill(0.0,np),l)
a∇gx = fill(fill(VectorValue(0.0,0.0),np),l)
cgx = evaluate(cg,cx)
c∇g = gradient(cg)
@test c∇g === gradient(cg)
@test c∇g === gradient(cg)
c∇gx = evaluate(c∇g,cx)
test_cell_value(c∇gx,a∇gx)
test_cell_field_like_with_gradient_no_array(cg,cx,agx,a∇gx)

fun(x,y) = x - y
cv = CellValue(fill(v,np),l)
cg = apply(bcast(fun),cf,cv)
agx = fill(fill(0.0,np),l)
test_cell_field_like_no_array(cg,cx,agx)

fun(x,y,z) = x - z
cv = CellValue(fill(v,np),l)
cg = apply(bcast(fun),cv,cv,cf)
agx = fill(fill(0.0,np),l)
test_cell_field_like_no_array(cg,cx,agx)

ca = cf
cb = ca + ca
cd = ca - cb
cdx = evaluate(cd,cx)
c∇d = gradient(cd)
cdx = evaluate(c∇d,cx)

end # module
