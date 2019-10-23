module RunBenchs

include("FunctorsBenchs.jl")

include("ArraysBenchs.jl")

include("../test/MockFields.jl")

include("LinCombBenchs.jl")

include("ComposeBenchs.jl")

end # module
