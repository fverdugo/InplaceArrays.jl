module Runtests

using Test
using InplaceArrays

a = collect(1:10)
b = InplaceArray(a)
test_inplace_array(b,a)

b[3] = -1
@test a[3] == -1
test_inplace_array(b,a)

a = rand(3,2,4)
b = InplaceArray(a)
test_inplace_array(b,a)

a = CartesianIndices(a)
b = InplaceArray(a)
test_inplace_array(b,a)

end # module

