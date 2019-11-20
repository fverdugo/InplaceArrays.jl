module ReferenceFEInterfacesTests

using Test
using InplaceArrays.Fields
using InplaceArrays.Polynomials
using InplaceArrays.ReferenceFEs

D = 2
T = Float64
order = 1
prebasis = MonomialBasis{D}(T,order)

polytope = QUAD
x = vertex_coordinates(polytope)
dofs = LagrangianDofBasis(T,x)

facedofids = [[1],[2],[3],[4],Int[],Int[],Int[],Int[],Int[]]

reffe = GenericRefFE(polytope,prebasis,dofs,facedofids)
test_reference_fe(reffe)

shapefuns = get_shapefuns(reffe)

@test evaluate(shapefuns,x) == [1.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0; 0.0 0.0 1.0 0.0; 0.0 0.0 0.0 1.0]

end # module
