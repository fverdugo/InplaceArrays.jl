#module FunctorsTests

include("../src/Functors.jl")

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

@show typeof(f)

#end # module
