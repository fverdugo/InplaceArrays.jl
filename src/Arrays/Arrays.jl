"""
This module provides:
- an extension of the `AbstractArray` interface in order to properly deal with mutable caches
- a collection of concrete implementations of `AbstractArray`.

The exported names in this module are:

$(EXPORTS)
"""
module Arrays

using InplaceArrays.Inference
using DocStringExtensions
using Test
using FillArrays
using Base: @propagate_inbounds

export array_cache
export getindex!
export testitem
export uses_hash
export test_array
export CachedArray
export CachedMatrix
export CachedVector
export setsize!

import Base: size
import Base: getindex, setindex!
import Base: similar

include("Interface.jl")

include("CachedArrays.jl")

end # module
