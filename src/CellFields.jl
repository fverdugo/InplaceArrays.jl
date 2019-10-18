module CellFields

using Test
using TensorValues
using InplaceArrays.Functors: BCasted
using InplaceArrays
using FillArrays

export CellFieldLike
export CellField
export CellBasis
export CellPoints
export CellFieldLikeOrData
export test_cell_field_like
export test_cell_field_like_no_array
export test_cell_field
export test_cell_basis
export test_cell_field_like_with_gradient
export test_cell_field_like_with_gradient_no_array
export test_cell_field_with_gradient
export test_cell_basis_with_gradient
export GradStyle
export ApplyToGradStyle
export ApplyGradStyle

import Base: getproperty
import Base: ndims
import Base: +, -
import InplaceArrays: valuetype
import InplaceArrays: pointdim
import InplaceArrays: gradtype
import InplaceArrays: GradStyle
import InplaceArrays: evaluate
import InplaceArrays: gradient
import InplaceArrays: apply

const CellFieldLike = CellValue{V} where V<:FieldLike{D,T,N} where {D,T,N}
const CellField = CellFieldLike{D,T,1} where {D,T}
const CellBasis = CellFieldLike{D,T,2} where {D,T}

const CellPoints = CellValue{A} where A<:AbstractVector{P} where P<:Point{D,T} where {D,T}

function evaluate(cf::CellFieldLike,x::CellPoints)
  r = evaluate_array_of_functors(cf.array,x.array)
  CellValue(x,r)
end

gradient(a::Fill) = Fill(gradient(a.value),a.axes)

#TODO implement also gradient for compressed

function gradient(cf::CellFieldLike)
  a = gradient(cf.array)
  CellValue(cf,a)
end

function test_cell_field_like(cf::CellFieldLike,cx::CellPoints,v::AbstractArray,cmp=(==))
  cfx = evaluate(cf,cx)
  test_cell_value(cfx,v,cmp)
  test_array_of_functors(cf.array,(cx.array,),v,cmp)
end

function test_cell_field_like_with_gradient(
  cf::CellFieldLike,cx::CellPoints,v::AbstractArray,g::AbstractArray,cmp=(==))
  test_cell_field_like(cf,cx,v,cmp)
  c∇f = gradient(cf)
  test_cell_field_like(c∇f,cx,g,cmp)
end

function test_cell_field(cf::CellField,x::CellPoints,v::AbstractArray,cmp=(==))
  test_cell_field_like(cf,x,v)
end

function test_cell_field_with_gradient(
  cf::CellField,x::CellPoints,v::AbstractArray,g::AbstractArray,cmp=(==))
  test_cell_field_like_with_gradient(cf,x,v,g)
end

function test_cell_basis(cf::CellBasis,x::CellPoints,v::AbstractArray,cmp=(==))
  test_cell_field_like(cf,x,v)
end

function test_cell_basis_with_gradient(
  cf::CellBasis,x::CellPoints,v::AbstractArray,g::AbstractArray,cmp=(==))
  test_cell_field_like_with_gradient(cf,x,v,g)
end

function CellValue(a::AbstractArray{<:FieldLike})
  CellFieldLikeWithCachedGrad(a)
end

# TODO wrap a cell field instead of an array
# use getarray instead of array in the CellValue interace
mutable struct CellFieldLikeWithCachedGrad{V} <: CellValue{V}
  array::AbstractArray{V}
  gradient
  function CellFieldLikeWithCachedGrad(
    array::AbstractArray{<:FieldLike{D,T,N}}) where {D,T,N}
    V = eltype(array)
    new{V}(array,nothing)
  end
end

function gradient(cf::CellFieldLikeWithCachedGrad)
  if cf.gradient === nothing
    a = gradient(cf.array)
    cf.gradient = CellValue(a)
  end
  cf.gradient
end

const FieldLikeOrData = Union{FieldLike,Number,AbstractArray}
const CellFieldLikeOrData = CellValue{T} where T<: FieldLikeOrData

abstract type GradStyle end
struct ApplyToGradStyle <: GradStyle end
struct ApplyGradStyle <: GradStyle end

valuetype(::Type{<:CellNumber{T}}) where {T} = T

valuetype(::Type{<:CellArray{T,N}}) where {T,N} = T

valuetype(::Type{<:CellFieldLike{D,T,N}}) where {D,T,N} = T

pointdim(::Type{<:CellFieldLike{D,T,N}}) where {D,T,N} = D

ndims(::Type{<:CellArray{T,N}}) where {T,N} = N

ndims(ca::CellArray{T,N}) where {T,N} = N

ndims(::Type{<:CellFieldLike{D,T,N}}) where {D,T,N} = N

ndims(ca::CellFieldLike{D,T,N}) where {D,T,N} = N

# TODO Rethink valuetype celltype ...
celltype(::Type{<:CellValue{T}}) where T = T

celltype(cv::T) where T <: CellValue = celltype(T)

evaltype(::Type{T}) where T <: CellData = celltype(T)

evaltype(cd::T) where T <:CellData = evaltype(T)

# Perhaps include in the abstract interface ?? or compute a more precise one?
function evaltype(::Type{T}) where T <: CellFieldLike
  S  = valuetype(T)
  N = ndims(T)
  Array{S,N}
end

evaltype(cd::T) where T <:CellFieldLike = evaltype(T)

struct AppliedFieldLike{D,T,N} <: FieldLike{D,T,N} end

#TODO mutable
mutable struct AppliedCellFieldLike{D,T,N} <: CellValue{AppliedFieldLike{D,T,N}}
  g
  f
  gradstyle
  grad
  function AppliedCellFieldLike(s::GradStyle,g,f::CellFieldLikeOrData...)
    T = _find_T(g,f...)
    N = _find_N(f...)
    D = _find_D(f...)
    new{D,T,N}(g,f,s,nothing)
  end
end

function _find_T(g,f...)
  Ts = map(evaltype,f)
  Tr = functor_return_type(g,Ts...)
  eltype(Tr)
end

function _find_D(f...)
  D = -1
  for fi in f
    if isa(fi,CellField)
      if D == -1
      D = pointdim(fi)
      else
        @assert D == pointdim(fi) "Not compatible pointdim"
      end
    end
  end
  @assert D !=-1 "At least one CellField needs to be provided"
  D
end

function _find_N(f...)
  N = -1
  for fi in f
    if isa(fi,CellField) || isa(fi,CellArray)
      if N == -1
      N = ndims(fi)
      else
        @assert N == ndims(fi) "Not compatible ndims"
      end
    end
  end
  @assert N !=-1 "At least one CellField needs to be provided"
  N
end

function getproperty(cf::AppliedCellFieldLike,name::Symbol)
  if name === :array
    error("CellFields resulting from `apply` have no underlying array for performance reasons")
  else
    return getfield(cf,name)
  end
end

function evaluate(cf::AppliedCellFieldLike,x::CellPoints)
  fx = [ evaluate(fi,x) for fi in cf.f]
  apply(cf.g,fx...)
end

function evaluate(cd::CellData,x::CellPoints)
  cd
end

function gradient(cf::AppliedCellFieldLike)
  if cf.grad === nothing
    cf.grad = _gradient(cf,cf.gradstyle)
  end
  cf.grad
end

function _gradient(cf,::ApplyGradStyle)
  g = gradient(cf.g)
  AppliedCellFieldLike(cf.gradstyle,g,cf.f...)
end

function _gradient(cf,::ApplyToGradStyle)
  f = map(gradient,cf.f)
  g = cf.g
  AppliedCellFieldLike(cf.gradstyle,g,f...)
end

function apply(g,f::CellFieldLikeOrData...)
  s = ApplyGradStyle()
  apply(s,g,f...)
end

function apply(s::GradStyle,g,f::CellFieldLikeOrData...)
  @assert any( isa(fi,CellFieldLike) for fi in f ) "At leas one `CellField` has to be provieded"
  AppliedCellFieldLike(s,g,f...)
end

for op in (:+,:-)
  @eval begin
    function ($op)(a::CellFieldLike)
      s = ApplyToGradStyle()
      apply(s,bcast($op),a)
    end
    function ($op)(a::CellFieldLike,b::CellFieldLike)
      s = ApplyToGradStyle()
      apply(s,bcast($op),a,b)
    end
  end
end

function test_cell_field_like_no_array(
  cf::CellFieldLike{D},cx::CellPoints{D},v::AbstractArray,cmp=(==)) where D
  cfx = evaluate(cf,cx)
  test_cell_value(cfx,v,cmp)
end

function test_cell_field_like_with_gradient_no_array(
  cf::CellFieldLike{D},cx::CellPoints{D},
  v::AbstractArray,g::AbstractArray,cmp=(==)) where D

  test_cell_field_like_no_array(cf,cx,v,cmp)
  cg = gradient(cf)
  test_cell_field_like_no_array(cg,cx,g,cmp)
end

gradient(f::BCasted) = bcast(gradient(f.f))

end # module
