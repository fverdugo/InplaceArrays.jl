"""

The exported names are
$(EXPORTS)
"""
module ReferenceFEs

using Test
using DocStringExtensions
using InplaceArrays.Helpers
using InplaceArrays.TensorValues
using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.Polynomials

import InplaceArrays.Arrays: kernel_cache
import InplaceArrays.Arrays: apply_kernel!
import InplaceArrays.Arrays: kernel_return_type
import InplaceArrays.Fields: evaluate

export Dof
export evaluate_dof!
export evaluate_dof
export dof_cache
export dof_return_type
export test_dof
export evaluate_dof_array

export LagrangianDofBasis

include("Dofs.jl")

include("MockDofs.jl")

include("LagrangianDofBases.jl")

end # module
