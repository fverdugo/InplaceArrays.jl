module ArraysTests

using Test
using InplaceArrays

a = rand(3,2,4)
test_inplace_array(a,a)

a = CartesianIndices(a)
test_inplace_array(a,a)

a = rand(12)
c = evaluate_functor_elemwise(-,a)
test_inplace_array(c,-a)

a = rand(12)
b = rand(12)
c = evaluate_functor_elemwise(-,a,b)
test_inplace_array(c,a.-b)

a = rand(0)
b = rand(0)
c = evaluate_functor_elemwise(-,a,b)
test_inplace_array(c,a.-b)

a = fill(rand(2,3),12)
b = rand(12)
c = evaluate_functor_elemwise(bcast(-),a,b)
test_inplace_array(c,[ai.-bi for (ai,bi) in zip(a,b)])

a = fill(rand(2,3),0)
b = rand(0)
c = evaluate_functor_elemwise(bcast(-),a,b)
test_inplace_array(c,[ai.-bi for (ai,bi) in zip(a,b)])

a = fill(rand(2,3),12)
b = rand(12)
c = evaluate_functor_elemwise(bcast(-),a,b)
d = evaluate_functor_elemwise(bcast(+),a,c)
e = evaluate_functor_elemwise(bcast(*),d,c)
test_inplace_array(e,[((ai.-bi).+ai).*(ai.-bi) for (ai,bi) in zip(a,b)])

a = fill(rand(Int,2,3),12)
b = fill(rand(Int,1,3),12)
c = array_caches(a,b)
i = 1
v = getitems!(c,(a,b),i)
@test c == (nothing,nothing)
@test v == (a[i],b[i])

a = fill(rand(Int,2,3),12)
b = fill(rand(Int,1,3),12)
ai = testitem(a)
@test ai == a[1]
ai, bi = testitems(a,b)
@test ai == a[1]
@test bi == b[1]

a = fill(rand(Int,2,3),0)
b = fill(1,0)
ai = testitem(a)
@test ai == Array{Int,2}(undef,0,0)
ai, bi = testitems(a,b)
@test ai == Array{Int,2}(undef,0,0)
@test bi == zero(Int)

a = fill(+,10)
b = fill(-,10)
c = apply_functor_elemwise(*,a,b)
d = fill(apply_functor(*,+,-),10)
test_inplace_array(c,d)
x = rand(10)
y = rand(10)
r = [(xi+yi)*(xi-yi) for (xi,yi) in zip(x,y)]
test_inplace_array_of_functors(c,(x,y),r)

a = fill(bcast(+),10)
b = fill(bcast(-),10)
c = apply_functor_elemwise(bcast(*),a,b)
d = fill(apply_functor(bcast(*),bcast(+),bcast(-)),10)
test_inplace_array(c,d)
x = [rand(2,3) for i in 1:10]
y = [rand(1,3) for i in 1:10]
r = [(xi.+yi).*(xi.-yi) for (xi,yi) in zip(x,y)]
test_inplace_array_of_functors(c,(x,y),r)

a = fill(+,10)
x = rand(10)
y = rand(10)
v = evaluate_array_of_functors(a,x,y)
r = [(xi+yi) for (xi,yi) in zip(x,y)]
test_inplace_array(v,r)

a = fill(bcast(+),10)
x = [rand(2,3) for i in 1:10]
y = [rand(1,3) for i in 1:10]
v = evaluate_array_of_functors(a,x,y)
r = [(xi.+yi) for (xi,yi) in zip(x,y)]
test_inplace_array(v,r)

end # module
