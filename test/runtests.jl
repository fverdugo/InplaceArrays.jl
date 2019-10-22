module RunTests

using Test

@time @testset "Helpers" begin include("HelpersTests/runtests.jl") end

end # module
