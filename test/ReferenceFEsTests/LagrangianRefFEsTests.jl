module LagrangianRefFEsTests

using Test
using InplaceArrays.Fields
using InplaceArrays.Polynomials
using InplaceArrays.ReferenceFEs

indexbase = 1

orders = (2,3)
b = MonomialBasis(Float64,QUAD,orders)
r = [(0,0), (1,0), (2,0), (0,1), (1,1), (2,1), (0,2), (1,2), (2,2), (0,3), (1,3), (2,3)]
@test [Tuple(t) .- indexbase for t in b.terms] == r

orders = (1,1,2)
b = MonomialBasis(Float64,WEDGE,orders)
r = [(0,0,0), (1,0,0), (0,1,0), (0,0,1), (1,0,1), (0,1,1), (0,0,2), (1,0,2), (0,1,2)]
@test [Tuple(t) .- indexbase for t in b.terms] == r

orders = (1,1,1)
b = MonomialBasis(Float64,PYRAMID,orders)
r = [(0,0,0), (1,0,0), (0,1,0), (1,1, 0), (0,0,1)]
@test [Tuple(t) .- indexbase for t in b.terms] == r

orders = (1,1,1)
b = MonomialBasis(Float64,TET,orders)
r = [(0,0,0), (1,0,0), (0,1,0), (0,0,1)]
@test [Tuple(t) .- indexbase for t in b.terms] == r

orders = (2,2)
extrusion = Tuple(QUAD.extrusion.array)

using InplaceArrays.ReferenceFEs: _polytope_nodes

@show _polytope_nodes(TET,1)

@show _polytope_nodes(WEDGE,(1,1,3))

end # module
