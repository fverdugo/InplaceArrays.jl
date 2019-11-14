"""

The exported names are
$(EXPORTS)
"""
module ReferenceFEs

using Test
using DocStringExtensions
using LinearAlgebra
using Combinatorics

using InplaceArrays.Helpers
using InplaceArrays.TensorValues
using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.Polynomials

import InplaceArrays.Arrays: kernel_cache
import InplaceArrays.Arrays: apply_kernel!
import InplaceArrays.Arrays: kernel_return_type
import InplaceArrays.Fields: evaluate

import Base: ==

export Polytope
export ExtrusionPolytope
export polytope_faces
export polytope_dimrange
export vertex_coordinates
export facet_normals
export facet_orientations
export edge_tangents
export vertex_permutations
export polytope_vtkid
export polytope_vtknodes
export num_dims
export num_faces
export num_facets
export num_edges
export polytope_facedims
export polytope_offsets
export polytope_offset
export test_polytope
export VERTEX
export SEGMENT
export TRI
export QUAD
export TET
export HEX
export HEX_AXIS
export TET_AXIS

export Dof
export evaluate_dof!
export evaluate_dof
export dof_cache
export dof_return_type
export test_dof
export evaluate_dof_array

export LagrangianDofBasis

include("Polytopes.jl")

include("ExtrusionPolytopes.jl")

include("Dofs.jl")

include("MockDofs.jl")

include("LagrangianDofBases.jl")

end # module
