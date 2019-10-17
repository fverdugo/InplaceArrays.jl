module Runtests

using Test

@time @testset "CachedArraysTests" begin include("CachedArraysTests.jl") end

@time @testset "FunctorsTests" begin include("FunctorsTests.jl") end

@time @testset "ArraysTests" begin include("ArraysTests.jl") end

@time @testset "CellValuesTests" begin include("CellValuesTests.jl") end

include("MockFields.jl")

@time @testset "FieldsTests" begin include("FieldsTests.jl") end

@time @testset "CellFieldsTests" begin include("CellFieldsTests.jl") end

@testset "Benchmarks" begin include("../bench/runbenchs.jl") end

end # module

