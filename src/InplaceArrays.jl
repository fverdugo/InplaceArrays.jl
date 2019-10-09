module InplaceArrays

using Reexport

export InplaceArray
export getindex!

include("CachedArrays.jl")
@reexport using InplaceArrays.CachedArrays

include("Functors.jl")
@reexport using InplaceArrays.Functors

include("Arrays.jl")
@reexport using InplaceArrays.Arrays

end # module
