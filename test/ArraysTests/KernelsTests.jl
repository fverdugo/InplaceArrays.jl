module KernelsTests

using Test
using InplaceArrays.Arrays

test_kernel(+,(3,2),5)

@test kernel_return_types((+,/),1,1) == (Int,Float64)

f = bcast(+)
a = rand(3,2)
b = 3
c = a .+ b
test_kernel(f,(a,b),c)

test_kernel(1,(),1)
test_kernel(1,(1,),1)

test_kernel([1,2],(),[1,2])
test_kernel([1,2],(1,),[1,2])

end # module
