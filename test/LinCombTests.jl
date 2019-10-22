module LinCombTests

using Test
using InplaceArrays

using InplaceArrays.LinComb: LinCombKernel
using InplaceArrays.LinComb: LinCombField
using ..MockFields


npoin = 4
ndofs = 8
b = rand(ndofs,npoin)
v = rand(ndofs)
r = (v'*b)'

f = LinCombKernel()
test_functor(f,(b,v),r,≈)

w = VectorValue(1.0,2.0)
b = fill(w,ndofs,npoin)
v = rand(ndofs)
r = (v'*b)'
test_functor(f,(b,v),r,≈)

w = VectorValue(1.0,2.0)
b = rand(ndofs,npoin)
v = fill(w,ndofs)
r = (v'*b)'
test_functor(f,(b,v),r,≈)

w = VectorValue(1.0,2.0)
b = fill(w,ndofs,npoin)
v = fill(w,ndofs)
r = reshape(sum(outer.(b,reshape(v,(ndofs,1))),dims=1),(npoin,))
test_functor(f,(b,v),r,≈)

d = 2
v = 4.0
b = MockBasis(d,v,ndofs)
v = fill(w,ndofs)
f = LinCombField(b,v)

np = 4
p = Point(1,2)
x = fill(p,np)
bx = evaluate(b,x)
∇bx = evaluate(∇(b),x)
r = reshape(sum(outer.(bx,reshape(v,(ndofs,1))),dims=1),(npoin,))
∇r = reshape(sum(outer.(∇bx,reshape(v,(ndofs,1))),dims=1),(npoin,))
test_field_with_gradient(f,x,r,∇r,≈)

l = 10
cb = CellValue(b,l)
cv = CellValue(v,l)
cx = CellValue(x,l)
cf = lincomb(cb,cv)
cfx = evaluate(cf,cx)

r = reshape(sum(outer.(bx,reshape(v,(ndofs,1))),dims=1),(npoin,))
∇r = reshape(sum(outer.(∇bx,reshape(v,(ndofs,1))),dims=1),(npoin,))
afx = fill(r,l)
a∇fx = fill(∇r,l)
test_cell_field_with_gradient(cf,cx,afx,a∇fx,≈)
c∇f = gradient(cf)
@test c∇f === gradient(cf)
@test c∇f === gradient(cf)

af = cf.array
cache = array_cache(af)
for i in eachindex(af)
  f = getindex!(cache,af,i)
  @test evaluate(f,x) ≈ r
  ∇f = gradient(f)
  @test evaluate(∇f,x) ≈ ∇r
end


end # module
