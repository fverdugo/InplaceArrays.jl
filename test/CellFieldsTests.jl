module CellFieldsTests

using Test
using TensorValues
using InplaceArrays
using ..MockFields
import InplaceArrays: ∇

np = 4
v = 3.0
d = 2
f = MockField(d,v)
fx = fill(v,np)
∇fx = fill(VectorValue(v,0.0),np)

l = 10
cf = CellValue(f,l)
afx = fill(fx,l)
a∇fx = fill(∇fx,l)

g = gradient(cf)
g2 = gradient(cf)
@test g === g2
g2 = gradient(cf)
@test objectid(g) == objectid(g2)

np = 4
p = Point(1,2)
x = fill(p,np)
cx = CellValue(x,l)

test_cell_field_with_gradient(cf,cx,afx,a∇fx)

using InplaceArrays.Functors: BCasted
using InplaceArrays.Functors: TypedBCasted
using InplaceArrays.Functors: TypedFunction

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

valuetype(::Type{<:CellNumber{T}}) where {T} = T

valuetype(::Type{<:CellArray{T,N}}) where {T,N} = T

valuetype(::Type{<:CellFieldLike{D,T,N}}) where {D,T,N} = T

pointdim(::Type{<:CellFieldLike{D,T,N}}) where {D,T,N} = D

ndims(::Type{<:CellArray{T,N}}) where {T,N} = N

ndims(ca::CellArray{T,N}) where {T,N} = N

ndims(::Type{<:CellFieldLike{D,T,N}}) where {D,T,N} = N

ndims(ca::CellFieldLike{D,T,N}) where {D,T,N} = N

# Rethink valuetype celltype ...
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

np = 4
v = 3.0
d = 2
f = MockField(d,v)
fx = fill(v,np)
∇fx = fill(VectorValue(v,0.0),np)

l = 10
cf = CellValue(f,l)
afx = fill(fx,l)
a∇fx = fill(∇fx,l)

cf2 = apply(bcast(-),cf)

np = 4
p = Point(1,2)
x = fill(p,np)
cx = CellValue(x,l)

fun(x) = 4*x
∇fun(x) = VectorValue(4.0,4.0)
∇(::typeof(fun)) = ∇fun

cg = apply(bcast(fun),cf)
agx = fill(fill(fun(v),np),l)
a∇gx = fill(fill(∇fun(v),np),l)
cgx = evaluate(cg,cx)
test_cell_value(cgx,agx)
c∇g = gradient(cg)
@test c∇g === gradient(cg)
@test c∇g === gradient(cg)
c∇gx = evaluate(c∇g,cx)
test_cell_value(c∇gx,a∇gx)
test_cell_field_like_with_gradient_no_array(cg,cx,agx,a∇gx)

cg = cf - cf
agx = fill(fill(0.0,np),l)
a∇gx = fill(fill(VectorValue(0.0,0.0),np),l)
cgx = evaluate(cg,cx)
c∇g = gradient(cg)
@test c∇g === gradient(cg)
@test c∇g === gradient(cg)
c∇gx = evaluate(c∇g,cx)
test_cell_value(c∇gx,a∇gx)
test_cell_field_like_with_gradient_no_array(cg,cx,agx,a∇gx)

#test_cell_field_with_gradient(cg,cx,agx,a∇gx)


end # module
