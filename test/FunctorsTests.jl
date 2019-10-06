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
c = .-( (a.*b) , (a.+b))
test_functor(f,(a,b),c)

@show typeof(f)



#end # module
