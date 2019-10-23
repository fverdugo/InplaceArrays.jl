module ArraysTests

using Test

@testset "Interfaces" begin include("InterfaceTests.jl") end

@testset "CachedArrays" begin include("CachedArraysTests.jl") end

@testset "Kernels" begin include("KernelsTests.jl") end

end # module
