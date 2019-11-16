module LagrangianRefFEsTests

using Test
using InplaceArrays.TensorValues
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

dofs = LagrangianDofBasis(VectorValue{3,Float64},TET,1)
@test dofs.nodes == Point{3,Float64}[(0,0,0), (1,0,0), (0,1,0), (0,0,1)]
@test dofs.node_and_comp_to_dof == VectorValue{3,Int}[(1,5,9), (2,6,10), (3,7,11), (4,8,12)]

dofs = LagrangianDofBasis(Float64,WEDGE,(2,2,2))
@test dofs.nodes == Point{3,Float64}[
  (0.0, 0.0, 0.0), (1.0, 0.0, 0.0), (0.0, 1.0, 0.0),
  (0.0, 0.0, 1.0), (1.0, 0.0, 1.0), (0.0, 1.0, 1.0),
  (0.0, 0.0, 0.5), (1.0, 0.0, 0.5), (0.0, 1.0, 0.5),
  (0.5, 0.0, 0.0), (0.5, 0.0, 1.0), (0.0, 0.5, 0.0),
  (0.5, 0.5, 0.0), (0.0, 0.5, 1.0), (0.5, 0.5, 1.0),
  (0.5, 0.0, 0.5), (0.0, 0.5, 0.5), (0.5, 0.5, 0.5)]

dofs = LagrangianDofBasis(Float64,PYRAMID,1)

end # module
