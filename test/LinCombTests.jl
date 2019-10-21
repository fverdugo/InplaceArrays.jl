include("../src/LinComb.jl")
module LinCombTests

using InplaceArrays

using ..LinComb: LinCombKernel


npoin = 4
ndofs = 8
b = rand(ndofs,npoin)
v = rand(ndofs)
r = (v'*b)'

f = LinCombKernel()

test_functor(f,(b,v),r,≈)



end # module
