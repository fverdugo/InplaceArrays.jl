
"""
    const Point{D,T} = VectorValue{D,T}

Type representing a point of D dimensions with coordinates of type T
"""
const Point{D,T} = VectorValue{D,T}

# Definition of the interface

"""
$(TYPEDEF)

Abstract type representing either a field ( for `N==1`) or a basis of fields
(for `N==2`) of value `T`, evaluable at points with `D` components.

The following functions need to be overloaded for derived types:

- [`evaluate!(cache,f::FieldLike,x)`](@ref)
- [`field_cache(f::FieldLike)`](@ref)
- [`num_dofs(f::Basis)`](@ref)

The following functions can optionally be also provided

- [`gradient(f::FieldLike)`](@ref)

The interface can be tested with these functions

- [`test_field`](@ref)
- [`test_basis`](@ref)

"""
abstract type FieldLike{D,T,N} end

"""
    const Field = FieldLike{D,T,1} where {D,T}
"""
const Field = FieldLike{D,T,1} where {D,T}

"""
    const Basis = FieldLike{D,T,2} where {D,T}
"""
const Basis = FieldLike{D,T,2} where {D,T}

"""
    evaluate!(cache,f::FieldLike,x) -> AbstractArray

For `Fields` it returns an instance of `AbstractVector` and for `Basis` 
and an instance of `AbstractMatrix`.
"""
function evaluate!(cache,f::FieldLike,x)
  @abstractmethod
end

"""
    field_cache(f::FieldLike)
"""
function field_cache(f::FieldLike)
  @abstractmethod
end

"""
    gradient(f::FieldLike)
"""
function gradient(f::FieldLike)
  @abstractmethod
end

"""
   const ∇ = gradient
"""
const ∇ = gradient

# Implement the kernel interface

function kernel_return_type(f::FieldLike,x)
  typeof(evaluate(f,x))
end

function kernel_cache(f::FieldLike,x)
  field_cache(f)
end

function apply_kernel!(cache,f::FieldLike,x)
  evaluate!(cache,f,x)
end

# Testers

"""
    test_field_like(
      f::FieldLike{D,T,N},
      x::AbstractVector{<:Point},
      v::AbstractArray,cmp=(==);
      grad=nothing) where {D,T,N}
"""
function test_field_like(
  f::FieldLike{D,T,N},
  x::AbstractVector{<:Point},
  v::AbstractArray,cmp=(==);
  grad=nothing) where {D,T,N}

  w = evaluate(f,x)
  @test ndims(w) == N
  @test T == eltype(w)
  @test cmp(w,v)
  @test D == pointdim(f)
  @test T == valuetype(f)
  test_kernel(f,(x,),v,cmp)

  if grad != nothing
    g = gradient(f)
    test_field_like(g,x,grad,cmp)
  end

end

"""
"""
function test_field(f::Field, args...; kwargs...)
  test_field_like(f, args...; kwargs...)
end

"""
"""
function test_basis(f::Basis, args...; kwargs...)
  test_field_like(f, args...; kwargs...)
  x, = args
  v = evaluate(f,x)
  ndofs, npoin = size(v)
  @test ndofs == num_dofs(f)
end

# Some API

"""
    evaluate(f::FieldLike,x::AbstractVector{<:Point})
"""
function evaluate(f::FieldLike,x::AbstractVector{<:Point})
  cache = field_cache(f)
  v = evaluate!(cache,f,x)
  v
end

"""
    valuetype(::Type) -> DataType
"""
valuetype(::Type{<:FieldLike{D,T}}) where {D,T} = T

valuetype(f::T) where T = valuetype(T)

"""
    pointdim(::Type) -> Int
"""
pointdim(::Type{<:FieldLike{D}}) where D = D

pointdim(f::T) where T = pointdim(T)


"""
    num_dofs(b::Basis) -> Int
"""
function num_dofs(::Basis)
  @abstractmethod
end

length(b::Basis) = num_dofs(b)

"""
    gradtype(::Type) -> DataType
"""
function gradtype(::Type{F}) where F<:FieldLike{D,T} where {D,T}
  E = eltype(T)
  P = Point{D,E}
  p = zero(P)
  v = zero(T)
  g = outer(p,v)
  typeof(g)
end

gradtype(f::T) where T = gradtype(T)

