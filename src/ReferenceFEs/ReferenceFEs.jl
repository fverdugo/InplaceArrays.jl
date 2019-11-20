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
import InplaceArrays.Polynomials: MonomialBasis

import Base: ==

export Polytope
export ExtrusionPolytope
export get_faces
export get_dimrange
export vertex_coordinates
export facet_normals
export facet_orientations
export edge_tangents
export vertex_permutations
export get_vtkid
export get_vtknodes
export num_dims
export num_vertices
export num_faces
export num_facets
export num_edges
export get_facedims
export get_offsets
export get_offset
export test_polytope
export VERTEX
export SEGMENT
export TRI
export QUAD
export TET
export HEX
export WEDGE
export PYRAMID
export HEX_AXIS
export TET_AXIS

export Dof
export evaluate_dof!
export evaluate_dof
export dof_cache
export dof_return_type
export test_dof
export evaluate_dof_array

export ReferenceFE
export GenericRefFE
export get_polytope
export get_prebasis
export get_dofs
export get_face_dofids
export get_dof_permutations
export get_shapefuns
export compute_shapefuns
export test_reference_fe

export LagrangianRefFE
export LagrangianDofBasis

export SerendipityRefFE

include("Polytopes.jl")

include("ExtrusionPolytopes.jl")

include("Dofs.jl")

include("MockDofs.jl")

include("LagrangianDofBases.jl")

include("ReferenceFEInterfaces.jl")

include("LagrangianRefFEs.jl")

include("SerendipityRefFEs.jl")

end # module
