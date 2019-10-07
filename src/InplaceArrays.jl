module InplaceArrays

using Test

export new_cache
export evaluate!
export evaluate
export test_functor
export bcast
export compose
export apply

include("Functors.jl")

end # module
