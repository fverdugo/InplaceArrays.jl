module InplaceArrays

using Reexport

@reexport using TensorValues

include("CachedArrays.jl")
@reexport using InplaceArrays.CachedArrays

include("Inference.jl")
@reexport using InplaceArrays.Inference

include("Functors.jl")
@reexport using InplaceArrays.Functors

include("Arrays.jl")
@reexport using InplaceArrays.Arrays

include("CellValues.jl")
@reexport using InplaceArrays.CellValues

include("Fields.jl")
@reexport using InplaceArrays.Fields

include("CellFields.jl")
@reexport using InplaceArrays.CellFields

include("LinComb.jl")
@reexport using InplaceArrays.LinComb

include("Compose.jl")
@reexport using InplaceArrays.Compose

end # module
