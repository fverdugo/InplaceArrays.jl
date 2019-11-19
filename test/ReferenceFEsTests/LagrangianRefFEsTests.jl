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

dofs = LagrangianDofBasis(VectorValue{2,Int},VERTEX,())
@test dofs.node_and_comp_to_dof == VectorValue{2,Int}[(1,2)]

b = MonomialBasis(VectorValue{2,Int},VERTEX,())
@test evaluate(b,Point{0,Int}[(),()]) == VectorValue{2,Int}[(1, 0) (0, 1); (1, 0) (0, 1)]

reffe = LagrangianRefFE(VectorValue{2,Int},VERTEX,())
@test reffe.facenodeids == [[1]]
@test reffe.data.facedofids == [[1,2]]
test_reference_fe(reffe)
@test ReferenceFE{0}(reffe,1) === reffe

reffe = LagrangianRefFE(VectorValue{2,Float64},SEGMENT,(2,))
@test reffe_face_dofids(reffe) == [[1, 4], [2, 5], [3, 6]]
test_reference_fe(reffe)

reffe = LagrangianRefFE(VectorValue{2,Float64},TRI,3)
@test reffe_face_dofids(reffe) == [[1, 11], [2, 12], [3, 13], [4, 5, 14, 15], [6, 7, 16, 17], [8, 9, 18, 19], [10, 20]]
test_reference_fe(reffe)

reffe = LagrangianRefFE(Float64,HEX,2)
test_reference_fe(reffe)

reffe = LagrangianRefFE(Float64,WEDGE,(1,1,2))
test_reference_fe(reffe)
refface = ReferenceFE{1}(reffe,3)
@test reffe_face_dofids(refface) == [[1], [2], [3]]
refface = ReferenceFE{1}(reffe,4)
@test reffe_face_dofids(refface) == [[1], [2], []]

orders = (4,)
reffe = LagrangianRefFE(VectorValue{2,Float64},SEGMENT,orders)
@test reffe.nodeperms == [[1, 2, 3], [3, 2, 1]]
@test reffe_dof_permutations(reffe) == [[1, 2, 3, 4, 5, 6], [3, 2, 1, 6, 5, 4]] 

orders = (2,3)
reffe = LagrangianRefFE(VectorValue{2,Float64},QUAD,orders)
@test reffe.nodeperms ==[[1, 2], [0, 0], [1, 2], [0, 0], [0, 0], [2, 1], [0, 0], [2, 1]] 
@test reffe_dof_permutations(reffe) == [
  [1, 2, 3, 4], [0, 0, 0, 0], [1, 2, 3, 4], [0, 0, 0, 0],
  [0, 0, 0, 0], [2, 1, 4, 3], [0, 0, 0, 0], [2, 1, 4, 3]]

end # module
