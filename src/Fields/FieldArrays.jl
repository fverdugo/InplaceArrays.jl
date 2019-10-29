
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

"""
    gradient(a::AbstractArray{<:Field})

Returns an array containing the gradients of the fields in the array `a`.
Numerically equivalent to 

    map(gradient,a)
"""
function gradient(a::AbstractArray{<:Field})
  #s = "You are calling a very memory inefficient default"
  #s *= " implementation of gradient for array of fields"
  #@warn s
  #map(gradient,a)
  k = Grad()
  apply(k,a)
end
#TODO to get rid of this warning, each kernel needs to define the global
# version of the gradient

struct Grad <: Kernel end

## TODO a lot of kernels follow this pattern
#kernel_cache(::Grad,::Field) = nothing

#kernel_return_type(k::Grad,x::Field) = typeof(apply_kernel(k,x))

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
function apply_to_field(k::Kernel,f::AbstractArray...)
  fi = testitems(f...)
  v = Valued(k,fi...)
  apply(v,f...)
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

"""
    lincomb(a::AbstractArray{<:Field},b::AbstractArray)

Returns an array of field numerically equivalent to

    map(lincomb,a,b)
"""
function lincomb(a::AbstractArray{<:Field},b::AbstractArray)
  k = LinCom()
  apply_to_field(k,a,b)
end

