module MonomialBasisTests

using Test
using InplaceArrays.TensorValues
using InplaceArrays.Fields
using InplaceArrays.Polynomials

order = 1
D = 2
b = MonomialBasis{2}(VectorValue{D,Float64},order)

xi = Point(2,3)
np = 2
x = fill(xi,np)

@show length(b.terms)

@show evaluate(b,x)

end # module
