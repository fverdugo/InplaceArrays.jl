#module Fields

# TODO move to TensorValues
using StaticArrays
using TensorValues
export mutable
mutable(::Type{MultiValue{S,T,N,L}}) where {S,T,N,L} = MArray{S,T,N,L}

using Test
using TensorValues

"""
    const Point{D,T} = VectorValue{D,T}

Type representing a point of D dimensions with coordinates of type T
"""
const Point{D,T} = VectorValue{D,T}

# Definition of the interface

abstract type FieldLike{D,T,N} end

const Field = FieldLike{D,T,1} where {D,T}

const Basis = FieldLike{D,T,2} where {D,T}

"""
    evaluate!(cache,f::FieldLike,x::AbstractVector{<:Point}) -> AbstractArray

For `Fields` it returns an instance of `AbstractVector` and for `Basis` 
and an instance of `AbstractMatrix`.
"""
function evaluate! end

"""
    new_cache(f::FieldLike)
"""
function new_cache end

"""
    gradient(f::FieldLike) -> FieldLike
"""
function gradient end

# Testers

function test_fieldlike(
  f::FieldLike{D,T,N},x::AbstractVector{<:Point},v::AbstractVector,cmp=(==)) where {D,T,N}
  w = evaluate(f,x)
  @test ndims(w) == N
  @test T == eltype(w)
  @test cmp(w,v)
  @test D == pointdim(f)
  @test T == valuetype(f)
end

function test_field(f::Field,x,v)
  test_fieldlike(f,x,v)
end

function test_basis(f::Basis,x,v)
  test_fieldlike(f,x,v)
end

# info getters

function evaluate(f::FieldLike,x::AbstractVector{<:Point})
  cache = new_cache(f)
  v = evaluate!(cache,f,x)
  v
end

"""
    valuetype(::Type) -> DataType
"""
valuetype(::Type{<:FieldLike{D,T}}) where {D,T} = T

valuetype(f::T) where T<:FieldLike = valuetype(T)

"""
    pointdim(::Type) -> Int
"""
pointdim(::Type{<:FieldLike{D}}) where D = D

pointdim(f::T) where T<:FieldLike = pointdim(T)


"""
    num_dofs(b::Basis) -> Int
"""
function num_dofs end



"""
    gradtype(::Type) -> DataType
"""
function gradtype(::Type{T},::Val{D}) where {T,D}
  P = Point{D,Int16}
  p = zero(P)
  v = zero(T)
  g = outer(p,v)
  typeof(g)
end

function gradtype(::Type{F}) where F<:FieldLike
  T = valuetype(F)
  D = pointdim(F)
  gradtype(T,Val(D))
end

gradtype(f::T) where T<:FieldLike = gradtype(T)


#end # module
