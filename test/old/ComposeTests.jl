module ComposeTests

using Test
using InplaceArrays
using InplaceArrays.LinComb: LinCombField
using ..MockFields
using InplaceArrays.Compose: ComposeKernel
using InplaceArrays.Compose: ComposedField

import InplaceArrays: ∇

fun(x) = 2*x
function ∇fun(x)
  c = 2*one(eltype(x))
  TensorValue(c,c,c,c)
end
∇(::typeof(fun)) = ∇fun

T = VectorValue{2,Float64}
k = ComposeKernel(T,fun)

np = 4
xi = Point(3.0,4.0)
x = fill(xi,np)
r = fun.(x)
test_functor(k,(x,),r)

d = 2
v = 4.0
bi = 4.0
ndofs = 8
vi = VectorValue(1.0,2.0)
b = MockBasis(d,bi,ndofs)
v = fill(vi,ndofs)
f = LinCombField(b,v)
fx = evaluate(f,x)

T = valuetype(f)
g = ComposedField(T,fun,f)
gx = fun.(fx)
∇gx = ∇fun.(fx)
test_field_with_gradient(g,x,gx,∇gx,≈)

l = 10
cb = CellValue(b,l)
cv = CellValue(v,l)
cx = CellValue(x,l)
cf = lincomb(cb,cv)
cg = compose(T,fun,cf)
agx = fill(gx,l)
a∇gx = fill(∇gx,l)
test_cell_field_with_gradient(cg,cx,agx,a∇gx,≈)

c∇g = gradient(cg)
@test c∇g === gradient(cg)
@test c∇g === gradient(cg)

ag = cg.array
cache = array_cache(ag)
for i in eachindex(ag)
  g = getindex!(cache,ag,i)
  @test evaluate(g,x) ≈ gx
  ∇g = gradient(g)
  @test evaluate(∇g,x) ≈ ∇gx
end

end # module

