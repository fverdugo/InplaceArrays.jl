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
export field_return_type
export gradient
export ∇
export Field
export test_field
export valuetype

import InplaceArrays.Arrays: kernel_cache
import InplaceArrays.Arrays: apply_kernel!
import InplaceArrays.Arrays: kernel_return_type

include("Interface.jl")

include("MockFields.jl")

#include("Apply.jl")

end # module
