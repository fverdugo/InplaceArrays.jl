module ReferenceFEsTests

using Test

@testset "Dofs" begin include("DofsTests.jl") end

@testset "MockDofs" begin include("MockDofsTests.jl") end

@testset "LagrangianDofBases" begin include("LagrangianDofBasesTests.jl") end

@testset "Polytopes" begin include("PolytopesTests.jl") end

@testset "ExtrusionPolytopes" begin include("ExtrusionPolytopesTests.jl") end

end # module
