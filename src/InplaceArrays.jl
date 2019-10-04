module InplaceArrays

using Test
using Base: @propagate_inbounds

export InplaceArray
export new_cache
export getindex!
export test_inplace_array

abstract type InplaceArray{T,N} <: AbstractArray{T,N} end

"""
new_cache(a::InplaceArray)::Any
"""
function new_cache end

"""
getindex!(cache,a::InplaceArray,i::Integer)
getindex!(cache,a::InplaceArray,I::Integer...)
"""
function getindex! end

function getindex!(cache,a::InplaceArray,I::CartesianIndex)
  getindex!(cache,a,Tuple(I)...) 
end

function test_inplace_array(
  a::InplaceArray{T,N}, b::AbstractArray{T,N},cmp=(==)) where {T,N}

  @test cmp(a,b)

  cache = new_cache(a)

  t = true
  for i in eachindex(a)
    bi = b[i]
    ai = getindex!(cache,a,i)
    t = t && cmp(bi,ai)
  end

  @test t

  @test IndexStyle(a) == IndexStyle(b)

  true
end

struct InplaceArrayFromArray{T,N,A<:AbstractArray} <: InplaceArray{T,N}
  array::A

  function InplaceArrayFromArray(array::AbstractArray{T,N}) where {T,N}
    A = typeof(array)
    new{T,N,A}(array)
  end

end

InplaceArray(a::AbstractArray) = InplaceArrayFromArray(a)

new_cache(::InplaceArrayFromArray) = nothing

function getindex!(::Nothing,a::InplaceArrayFromArray,I::Integer...)
  a.array[I...]
end

Base.size(a::InplaceArrayFromArray) = size(a.array)

@propagate_inbounds function Base.getindex(
  a::InplaceArrayFromArray,I::Integer...)
  a.array[I...]
end

@propagate_inbounds function Base.setindex!(
  a::InplaceArrayFromArray,v,I::Integer...)
  a.array[I...] = v
end

function Base.IndexStyle(
  ::Type{InplaceArrayFromArray{T,N,A}}) where {T,N,A}
  IndexStyle(A)
end

end # module
