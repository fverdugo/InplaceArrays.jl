module ArraysTests

using Test
using InplaceArrays

a = rand(3,2,4)
test_inplace_array(a,a)

a = CartesianIndices(a)
test_inplace_array(a,a)

a = rand(12)
c = data_array_apply(-,a)
test_inplace_array(c,-a)

a = rand(12)
b = rand(12)
c = data_array_apply(-,a,b)
test_inplace_array(c,a.-b)

a = rand(0)
b = rand(0)
c = data_array_apply(-,a,b)
test_inplace_array(c,a.-b)

a = fill(rand(2,3),12)
b = rand(12)
c = data_array_apply(bcast(-),a,b)
test_inplace_array(c,[ai.-bi for (ai,bi) in zip(a,b)])

a = fill(rand(2,3),0)
b = rand(0)
c = data_array_apply(bcast(-),a,b)
test_inplace_array(c,[ai.-bi for (ai,bi) in zip(a,b)])

end # module
