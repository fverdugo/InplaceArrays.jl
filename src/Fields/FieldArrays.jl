
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

function evaluate(a::AbstractArray,x::AbstractArray)
  k = Eval()
  apply(k,a,x)
end

struct Eval <: Kernel end

function kernel_cache(k::Eval,a,x)
  field_cache(a,x)
end

function apply_kernel!(cache,k::Eval,a,x)
  evaluate_field!(cache,a,x)
end

function kernel_return_type(k::Eval,a,x)
  field_return_type(a,x)
end

# Optimized version for arrays of fields obtained from a kernel
# and other arrays
function evaluate(
  a::AppliedArray{<:Field,N,F,<:Fill} where {N,F},x::AbstractArray)
  kernel_evaluate(a.g.value,x,a.f...)
end

"""
"""
function kernel_evaluate(k,x,f...)
  a = apply(k,f...)
  apply(a,x)
end

"""
    gradient(a::AbstractArray{<:Field})

Returns an array containing the gradients of the fields in the array `a`.
Numerically equivalent to 

    map(gradient,a)
"""
function gradient(a::AbstractArray)
  k = Grad()
  apply(k,a)
end

struct Grad <: Kernel end

@inline apply_kernel!(::Nothing,k::Grad,x) = field_gradient(x)

#function evaluate(a::Fill{<:AppliedField},x::AbstractArray)
#  ai = a.value
#  fx = apply_all(ai.f,x)
#  apply(ai.k,fx...)
#end
#
##TODO, perhaps not needed since apply func will take care.
#gradient(a::Fill) = Fill(gradient(a.value),a.axes)
#
##TODO implement also gradient for compressed
##EDIT, perhaps not needed since apply func will take care.

function gradient(
  a::AppliedArray{<:Field,N,F,<:Fill} where {N,F})
  apply_gradient(a.g.value,a.f...)
end

"""
"""
function apply_gradient(k,f...)
  a = apply(k,f...)
  g = Grad()
  apply(g,a)
end

"""
    field_array_cache(a::AbstractArray{<:Field},x::AbstractArray) -> Tuple

Returns the caches needed to perform the following iteration

    ca, cfi, cx = field_array_cache(a,x)

    for i in length(a)
      fi = getindex!(ca,a,i)
      xi = getindex!(cx,x,i)
      fxi = evaluate!(cfi,fi,xi)
    end
"""
function field_array_cache(a::AbstractArray,x::AbstractArray)
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
  a::AbstractArray,
  x::AbstractArray,
  v::AbstractArray,
  cmp::Function=(==);
  grad = nothing)
  
  ax = evaluate(a,x)
  test_array(ax,v,cmp)

  ca, cfi, cx = field_array_cache(a,x)

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
  k::Kernel,f::AbstractArray...)
  v = Valued(k)
  apply(v,f...)
end

struct Valued{K} <: Kernel
  k::K
  function Valued(k)
    new{typeof(k)}(k)
  end
end

@inline function apply_kernel!(cache,k::Valued,x...)
  apply_kernel_to_field(k.k,x...)
end

function kernel_evaluate(k::Valued,x,f...)
  fx = evaluate_all(f,x)
  a = apply(k.k,fx...)
end

for op in (:+,:-)
  @eval begin
    function apply_gradient(k::Valued{BCasted{typeof($op)}},f...)
      g = gradient_all(f...)
      apply(k,g...)
    end
  end
end

