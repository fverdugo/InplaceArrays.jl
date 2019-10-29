
"""
    evaluate(a::AbstractArray{<:Field},x::AbstractArray)

Evaluates the fields in the array `a` at the locations provided in the array `x`
(which can be an array of points or an array of vectors of points).

The result is numerically equivalent to 

    map(evaluate,a,x)
"""
function evaluate(a::AbstractArray{<:Field},x::AbstractArray)
  apply(a,x)
end

function evaluate(
  a::AppliedArray{<:Field,N,F,<:Fill} where {N,F},x::AbstractArray)
  evaluate(a.g.value,x,a.f...)
end

function evaluate(k::Kernel,x::AbstractArray,f...)
  a = apply(k,f...)
  apply(a,x)
end

"""
    gradient(a::AbstractArray{<:Field})

Returns an array containing the gradients of the fields in the array `a`.
Numerically equivalent to 

    map(gradient,a)
"""
function gradient(a::AbstractArray{<:Field})
  k = Grad()
  apply(k,a)
end

function gradient(
  a::AppliedArray{<:Field,N,F,<:Fill} where {N,F})
  gradient(a.g.value,a.f...)
end

function gradient(k::Kernel,f::AbstractArray{<:FieldNumberOrArray}...)
  a = apply(k,f...)
  g = Grad()
  apply(g,a)
end

struct Grad <: Kernel end

@inline apply_kernel!(::Nothing,k::Grad,x::Field) = gradient(x)

function evaluate(a::Fill{<:AppliedField},x::AbstractArray)
  ai = a.value
  fx = apply_all(ai.f,x)
  apply(ai.k,fx...)
end

#TODO, perhaps not needed since apply func will take care.
gradient(a::Fill) = Fill(gradient(a.value),a.axes)

#TODO implement also gradient for compressed
#EDIT, perhaps not needed since apply func will take care.

"""
    field_cache(a::AbstractArray{<:Field},x::AbstractArray) -> Tuple

Returns the caches needed to perform the following iteration

    ca, cfi, cx = field_cache(a,x)

    for i in length(a)
      fi = getindex!(ca,a,i)
      xi = getindex!(cx,x,i)
      fxi = evaluate!(cfi,fi,xi)
    end
"""
function field_cache(a::AbstractArray{<:Field},x::AbstractArray)
  ca = array_cache(a)
  fi = testitem(a)
  xi = testitem(x)
  cfi = field_cache(fi,xi)
  cx = array_cache(x)
  (ca,cfi,cx)
end

"""
    function test_array_of_fields(
      a::AbstractArray{<:Field},
      x::AbstractArray,
      v::AbstractArray,
      cmp::Function=(==);
      grad = nothing)

Function to test an array of fields.
"""
function test_array_of_fields(
  a::AbstractArray{<:Field},
  x::AbstractArray,
  v::AbstractArray,
  cmp::Function=(==);
  grad = nothing)
  
  ax = evaluate(a,x)
  test_array(ax,v,cmp)

  ca, cfi, cx = field_cache(a,x)

  t = true
  for i in 1:length(a)
    fi = getindex!(ca,a,i)
    xi = getindex!(cx,x,i)
    fxi = evaluate!(cfi,fi,xi)
    vi = v[i]
    ti = cmp(fxi,vi)
    t = t && ti
  end
  @test t

  if grad != nothing
    g = gradient(a)
    test_array_of_fields(g,x,grad,cmp)
  end

end

"""
    apply_to_field(k::Kernel,f::AbstractArray...)

Returns an array of fields numerically equivalent to

    map( (x...) -> apply_kernel_to_field(k,x...), f )
"""
function apply_to_field(
  k::Kernel,f::AbstractArray{<:FieldNumberOrArray{D}}...) where D
  g = _to_arrays_of_fields(Val{D}(),f...)
  fi = testitems(g...)
  v = Valued(k,fi...)
  apply(v,g...)
end

function apply_to_field(
  k::Kernel,f::AbstractArray{<:NumberOrArray}...)
  @unreachable "At least one argument needs to be an array of fields"
end

function _to_arrays_of_fields(d::Val,a,b...)
  f = _to_array_of_fields(d,a)
  g = _to_arrays_of_fields(d,b...)
  (f,g...)
end

function _to_arrays_of_fields(d::Val,a)
  f = _to_array_of_fields(d,a)
  (f,)
end

_to_array_of_fields(::Val,a::AbstractArray{<:Field}) = a

function _to_array_of_fields(
  ::Val{D},a::AbstractArray{<:NumberOrArray}) where D
  k = ToField{D}()
  apply(k,a)
end

struct Valued{T,K} <: Kernel
  k::K
  function Valued(k,f...)
    g = apply_kernel_to_field(k,f...)
    T = valuetype(g)
    new{T,typeof(k)}(k)
  end
end

#TODO NumberOrArray versions needed??
@inline function apply_kernel!(cache,k::Valued,x::NumberOrArray...)
  b = k.k
  apply_kernel!(cache,b,x...)
end

function kernel_cache(k::Valued,x::NumberOrArray...)
  b = k.k
  kernel_cache(b,x...)
end

function kernel_return_type(k::Valued,x::NumberOrArray...)
  b = k.k
  kernel_return_type(b,x...)
end

@inline function apply_kernel!(cache,k::Valued{T},x::FieldNumberOrArray...) where T
  apply_kernel_to_field(T,k.k,x...)
end

#function kernel_cache(k::Valued,x::FieldNumberOrArray...)
#  nothing
#end

#function kernel_return_type(k::Valued,x::FieldNumberOrArray...)
#  typeof(apply_kernel(k,x...))
#end


