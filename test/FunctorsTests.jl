module FunctorsTests

using Test
using InplaceArrays
#include("../src/Functors.jl")

test_functor(+,(3,2),5)

f = bcast(+)
a = rand(3,2)
b = 3
c = a .+ b
test_functor(f,(a,b),c)

f = compose_functors(-,+)
a = 2
b = 3
c = -5
test_functor(f,(a,b),c)

f = compose_functors(bcast(-),bcast(+))
a = rand(3,2)
b = 3
c = .-( a .+ b)
test_functor(f,(a,b),c)

f = compose_functors(*,-,+)
a = 2
b = 3
c = (a-b) * (a+b)
test_functor(f,(a,b),c)

f = compose_functors(bcast(-),bcast(*),bcast(+))
a = rand(3,2)
b = 3
c = rand(1,2)
d = .-( (a.*b.*c) , (a.+b.+c))
test_functor(f,(a,b,c),d)

a = 2
f = compose_functors(+,-,a)
b = 3
c = 5
d = (b-c) + a
test_functor(f,(b,c),d)

a = rand(2,3)
f = compose_functors(bcast(+),bcast(-),a)
b = 3
c = rand(1,3)
d = (b.-c) .+ a
test_functor(f,(b,c),d)

a = rand(2,3)
b = 4
f = compose_functors(bcast(-),a,b)
d = a .- b
test_functor(f,(),d)

C = bcast(+)
D = rand(2,3)
B = compose_functors(bcast(-),C,D)
A = compose_functors(bcast(*),B,C)
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
