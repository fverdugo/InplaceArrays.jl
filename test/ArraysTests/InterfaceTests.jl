module InterfaceTests

using Test
using InplaceArrays.Arrays

a = rand(20,12)

test_array(a,a)
test_array(a,a,≈)

end # module
