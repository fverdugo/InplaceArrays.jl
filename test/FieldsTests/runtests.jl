module FieldsTests

using Test

@testset "MockFields" begin include("MockFieldsTests.jl") end

@testset "Interface" begin include("InterfaceTests.jl") end

@testset "FieldApply" begin include("ApplyTests.jl") end

@testset "FieldArrays" begin include("FieldArraysTests.jl") end

end # module
