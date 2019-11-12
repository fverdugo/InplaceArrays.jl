module PolytopesTests

using Test
using LinearAlgebra
using InplaceArrays.Helpers
using InplaceArrays.TensorValues
using InplaceArrays.Arrays
using InplaceArrays.Fields


include("../../src/ReferenceFEs/Polytopes.jl")

@test num_faces(VERTEX) == 1
@test num_dims(VERTEX) == 0

p = Polytope(HEX_AXIS, HEX_AXIS)

r = Point{2,Float64}[(1.0, 0.0), (1.0, 0.0), (0.0, 1.0), (0.0, 1.0)]
@test edge_tangents(Point{2,Float64},p) == r

@test num_faces(p) == 9
@test num_dims(p) == 2

p = Polytope(TET_AXIS, TET_AXIS, TET_AXIS)

@test num_faces(p) == 15
@test num_dims(p) == 3

x = Point{3,Float64}[(0.0, 0.0, 0.0), (1.0, 0.0, 0.0), (0.0, 1.0, 0.0), (0.0, 0.0, 1.0)]
@test vertex_coordinates(Point{3,Float64},p) == x

end # module
