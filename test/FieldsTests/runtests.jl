module FieldsTests

using Test

@testset "MockFields" begin include("MockFieldsTests.jl") end

@testset "Interface" begin include("InterfaceTests.jl") end

end # module
