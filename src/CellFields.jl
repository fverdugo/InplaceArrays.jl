module CellFields

using Test
import InplaceArrays: evaluate
using TensorValues

using InplaceArrays

using FillArrays
using InplaceArrays.Arrays: AppliedArray
import InplaceArrays: gradient

export CellFieldLike
export CellField
export CellBasis
export CellPoints
export test_cell_field_like
export test_cell_field
export test_cell_basis
export test_cell_field_like_with_gradient
export test_cell_field_with_gradient
export test_cell_basis_with_gradient

import InplaceArrays: apply

import InplaceArrays: evaluate


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

const CellFieldLikeOrData = CellValue{T} where T<:Union{Number,AbstractArray,FieldLike}

function apply(f,cvs::CellFieldLikeOrData...)
  arrs = getarrays(cvs...)
  r = apply_array_of_functors(f,arrs...)
  CellValue(r)
end

function apply(f,cv::CellFieldLike)
  arr = cv.array
  r = apply_array_of_functors(f,arr)
  CellValue(cv,r)
end

function gradient(a::AppliedArray)
  ∇g = gradient(a.g)
  AppliedArray(∇g,a.f...)
end

end # module
