module FieldsBenchs

include("MockFieldsBenchs.jl")

include("ConstantFieldsBenchs.jl")

include("FieldApplyBenchs.jl")

include("FieldArraysBenchs.jl")

include("LincombBenchs.jl")

include("ComposeBenchs.jl")

end # module
