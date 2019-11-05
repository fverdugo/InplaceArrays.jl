"""
The exported names are:

$(EXPORTS)
"""
module Polynomials

using DocStringExtensions
using InplaceArrays.Helpers
using InplaceArrays.Arrays
using InplaceArrays.TensorValues
using InplaceArrays.Fields

import InplaceArrays.Fields: evaluate_field!
import InplaceArrays.Fields: field_cache
import InplaceArrays.Fields: field_gradient

export MonomialBasis

include("MonomialBases.jl")

end # module
