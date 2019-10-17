module FunctorsTests

using Test
using InplaceArrays

f = bcast(Int,2,+)
a = rand(Int,3,2)
b = 3
c = a .+ b
test_functor(f,(a,b),c)

test_functor(typedfun(Int,+),(3,2),5)

test_functor(typedfun(Float64,+),(3,2),5.0)

test_functor(+,(3,2),5)

@test functor_return_types((+,/),Int,Int) == (Int,Float64)

f = bcast(+)
a = rand(3,2)
b = 3
c = a .+ b
test_functor(f,(a,b),c)

f = apply_functor(-,+)
a = 2
b = 3
c = -5
test_functor(f,(a,b),c)

f = apply_functor(bcast(-),bcast(+))
a = rand(3,2)
b = 3
c = .-( a .+ b)
test_functor(f,(a,b),c)

f = apply_functor(*,-,+)
a = 2
b = 3
c = (a-b) * (a+b)
test_functor(f,(a,b),c)

f = apply_functor(bcast(-),bcast(*),bcast(+))
a = rand(3,2)
b = 3
c = rand(1,2)
d = .-( (a.*b.*c) , (a.+b.+c))
test_functor(f,(a,b,c),d)

a = 2
f = apply_functor(+,-,a)
b = 3
c = 5
d = (b-c) + a
test_functor(f,(b,c),d)

a = rand(2,3)
f = apply_functor(bcast(+),bcast(-),a)
b = 3
c = rand(1,3)
d = (b.-c) .+ a
test_functor(f,(b,c),d)

a = rand(2,3)
b = 4
f = apply_functor(bcast(-),a,b)
d = a .- b
test_functor(f,(),d)

C = bcast(+)
D = rand(2,3)
B = apply_functor(bcast(-),C,D)
A = apply_functor(bcast(*),B,C)
x = rand(2,3)
y = 3
c = (x .+ y)
b = c .- D
a = b .* c
test_functor(A,(x,y),a)
cache = functor_cache(A,x,y)
r = evaluate_functor!(cache,A,x,y)
@test a == r
x = rand(2,3)
y = -2
c = (x .+ y)
b = c .- D
a = b .* c
r = evaluate_functor!(cache,A,x,y)
@test a == r

end # module
