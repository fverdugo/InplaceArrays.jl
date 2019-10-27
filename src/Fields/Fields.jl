"""
This module defines the interface for physical fields and  basis of
physical fields. It also provides some helpers to work with fields and basis.

The exported names are:

$(EXPORTS)
"""
module Fields

using InplaceArrays.Helpers
using InplaceArrays.Inference
using InplaceArrays.Arrays
using InplaceArrays.Arrays: Elem
using InplaceArrays.Arrays: NumberOrArray
using InplaceArrays.Arrays: AppliedArray

using Test
using DocStringExtensions
using TensorValues #TODO integrate here
using FillArrays

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
export pointdim
export apply_kernel_to_field
export apply_to_field
export test_array_of_fields
export compose

import InplaceArrays.Arrays: kernel_cache
import InplaceArrays.Arrays: apply_kernel!
import InplaceArrays.Arrays: kernel_return_type
import Base: +, - , *

include("FieldInterface.jl")

include("MockFields.jl")

include("ConstantFields.jl")

include("FieldApply.jl")

include("FieldArrays.jl")

include("Compose.jl")

end # module
