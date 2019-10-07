module Runtests

using Test

@time @testset "FunctorsTests" begin include("FunctorsTests.jl") end

@time @testset "ArraysTests" begin include("ArraysTests.jl") end

@testset "Benchmarks" begin include("../bench/runbenchs.jl") end

end # module

