module Runtests

using Test

@time @testset "FunctorsTests" begin include("FunctorsTests.jl") end

@testset "Benchmarks" begin include("../bench/runbenchs.jl") end

end # module

