module FunctorsTests

using Test

abstract type Functor end

"""
evaluate!(t,f::Functor,s,cache)
"""
function evaluate! end

"""
Version of evaluate! that allocates memory
"""
function evaluate(f::Functor,s)
  cache = new_cache(f)
  t = new_value(f)
  prepare_value!(t,f,s)
  r = evaluate!(t,f,s,cache)
  r
end

"""
new_cache(f::Functor)::Any
"""
function new_cache end

"""
new_value(::Functor)
"""
function new_value end

"""
prepare_value!(t,f,s)
"""
function prepare_value! end

function test_functor(f::Functor,t,s,cmp=(==))
  r = evaluate(f,s)
  @test cmp(r,t)
end

struct MockFunctor{T,N} <: Functor
  shape::NTuple{N,Int}
end

function MockFunctor(::Type{T},shape::Vararg{Integer,N}) where {T,N}
  MockFunctor{T,N}(shape)
end

new_cache(::MockFunctor) = nothing

function new_value(f::MockFunctor{T,N}) where {T,N}
  Array{T,N}(undef,f.shape)
end

prepare_value!(t,f::MockFunctor,s) = nothing

function evaluate!(t,f::MockFunctor,s,cache)
  for i in eachindex(s)
    t[i] = 2*s[i]
  end
  t
end

f = MockFunctor(Float64,3,5)
s = rand(3,5)
t = 2*s
test_functor(f,t,s)

end # module
