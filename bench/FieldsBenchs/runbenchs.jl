module FieldsBenchs

include("MockFieldsBenchs.jl")

include("ConstantFieldsBenchs.jl")

include("FieldApplyBenchs.jl")

include("FieldArraysBenchs.jl")

include("ComposeBenchs.jl")

include("LincombBenchs.jl")

end # module
