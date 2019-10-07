module FunctorsTests

using InplaceArrays
using Test

test_functor(+,(3,2),5)

f = bcast(+)
a = rand(3,2)
b = 3
c = a .+ b
test_functor(f,(a,b),c)

f = apply(-,+)
@test apply(-,+) == compose(-,+)
a = 2
b = 3
c = -5
test_functor(f,(a,b),c)

f = apply(bcast(-),bcast(+))
a = rand(3,2)
b = 3
c = .-( a .+ b)
test_functor(f,(a,b),c)

f = apply(*,-,+)
a = 2
b = 3
c = (a-b) * (a+b)
test_functor(f,(a,b),c)

f = apply(bcast(-),bcast(*),bcast(+))
a = rand(3,2)
b = 3
c = rand(1,2)
d = .-( (a.*b.*c) , (a.+b.+c))
test_functor(f,(a,b,c),d)

a = 2
f = apply(+,-,a)
b = 3
c = 5
d = (b-c) + a
test_functor(f,(b,c),d)

a = rand(2,3)
f = apply(bcast(+),bcast(-),a)
b = 3
c = rand(1,3)
d = (b.-c) .+ a
test_functor(f,(b,c),d)

a = rand(2,3)
b = 4
f = apply(bcast(-),a,b)
d = a .- b
test_functor(f,(),d)

C = bcast(+)
D = rand(2,3)
B = apply(bcast(-),C,D)
A = apply(bcast(*),B,C)

x = rand(2,3)
y = 3
c = (x .+ y)
b = c .- D
a = b .* c
test_functor(A,(x,y),a)

end # module
