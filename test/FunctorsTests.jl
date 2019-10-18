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

end # module
