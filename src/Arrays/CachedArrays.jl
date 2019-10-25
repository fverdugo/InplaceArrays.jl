
"""
$(TYPEDEF)

Type providing a re-sizable array that only allocates memory
when the underlying buffer needs to grow.

The size of a `CachedArray` is changed via the [`setsize!`](@ref) function.

A `CachedArray` can be build with the constructors
- [`CachedArray(a::AbstractArray)`](@ref)
- [`CachedArray(T,N)`](@ref)

```jldoctests
using InplaceArrays.Arrays
# Create an empty CachedArray
a = CachedArray(Float64,2)
# Resize to new shape (2,3)
setsize!(a,(2,3))
size(a)
# output
(2, 3)
```
"""
mutable struct CachedArray{T,N,A<:AbstractArray{T,N}} <: AbstractArray{T,N}
  array::A
  size::NTuple{N,Int}
end

"""
    const CachedMatrix{T,A} = CachedArray{T,2,A}
"""
const CachedMatrix{T,A} = CachedArray{T,2,A}

"""
    const CachedVector{T,A} = CachedArray{T,1,A}
"""
const CachedVector{T,A} = CachedArray{T,1,A}


"""
$(SIGNATURES)
"""
CachedArray(a::AbstractArray) = CachedArray(a,size(a))

"""
$(SIGNATURES)
"""
CachedVector(a::AbstractVector) = CachedArray(a,size(a))

"""
$(SIGNATURES)
"""
CachedMatrix(a::AbstractMatrix) = CachedArray(a,size(a))

"""
$(SIGNATURES)
"""
function CachedArray(T,N)
  s = tuple([0 for i in 1:N]...)
  a = Array{T,N}(undef,s)
  CachedArray(a)
end

"""
$(SIGNATURES)
"""
function CachedVector(T)
  CachedArray(T,1)
end

"""
$(SIGNATURES)
"""
function CachedMatrix(T)
  CachedArray(T,2)
end

size(self::CachedArray) = self.size

"""
$(SIGNATURES)

Changes the size of the `CachedArray` `a` to the size described the the tuple
`s`.

!!! warning
    After calling `setsize!`, the array can store uninitialized values.
"""
function setsize!(a::CachedArray{T,N},s::NTuple{N,Int}) where {T,N}
  if s <= size(a.array)
    a.size = s
  else
    a.array = similar(a.array,T,s...)
    a.size = s
  end
end

@propagate_inbounds function getindex(self::CachedArray, kj::Integer)
    self.array[kj]
end

@propagate_inbounds function getindex(self::CachedArray{T,N}, kj::Vararg{Integer,N}) where {T,N}
    self.array[kj...]
end

@propagate_inbounds function setindex!(B::CachedArray, v, kj::Integer)
    B.array[kj] = v
    v
end

@propagate_inbounds function setindex!(B::CachedArray{T,N}, v, kj::Vararg{Integer,N}) where {T,N}
    B.array[kj...] = v
    v
end

function similar(::Type{CachedArray{T,N,A}},s::Tuple{Vararg{Int}}) where {T,N,A}
  a = similar(A,s)
  CachedArray(a)
end

