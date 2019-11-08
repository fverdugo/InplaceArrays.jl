module ReferenceFEsTests

using Test

@testset "Dofs" begin include("DofsTests.jl") end

@testset "MockDofs" begin include("MockDofsTests.jl") end

@testset "LagrangianDofBases" begin include("LagrangianDofBasesTests.jl") end

end # module
