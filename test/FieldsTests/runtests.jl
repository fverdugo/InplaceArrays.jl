module FieldsTests

using Test

@testset "MockFields" begin include("MockFieldsTests.jl") end

@testset "FieldInterface" begin include("FieldInterfaceTests.jl") end

@testset "FieldApply" begin include("FieldApplyTests.jl") end

@testset "FieldArrays" begin include("FieldArraysTests.jl") end

@testset "Compose" begin include("ComposeTests.jl") end

end # module
