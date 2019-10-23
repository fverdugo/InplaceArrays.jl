"""
This module defines the interface for physical fields and  basis of
physical fields. It also provides some helpers to work with fields and basis.

The exported names are:

$(EXPORTS)
"""
module Fields

using InplaceArrays.Helpers
using InplaceArrays.Arrays

using Test
using DocStringExtensions
using TensorValues

export Point
export evaluate
export evaluate!
export field_cache
export gradient
export ∇
export num_dofs
export FieldLike
export Field
export Basis
export num_dofs
export test_field_like
export test_field
export test_basis
export valuetype
export pointdim
export gradtype

import InplaceArrays.Arrays: kernel_cache
import InplaceArrays.Arrays: apply_kernel!
import InplaceArrays.Arrays: kernel_return_type
import Base: length

include("Interface.jl")

include("MockFields.jl")

end # module
