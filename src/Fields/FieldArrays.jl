
"""
    evaluate(a::AbstractArray{<:Field},x::AbstractArray)

The result is numerically equivalent to 

    map(evaluate,a,x)
"""
function evaluate(a::AbstractArray{<:Field},x::AbstractArray)
  apply(a,x)
end

"""
    gradient(a::AbstractArray{<:Field},x::AbstractArray)

Numerically equivalent to 

    map(gradient,a)
"""
function gradient(a::AbstractArray{<:Field})
  map(gradient,a)
end

function evaluate(a::Fill{<:AppliedField},x::AbstractArray)
  ai = a.value
  fx = apply_all(ai.f,x)
  apply(ai.k,fx...)
end

gradient(a::Fill) = Fill(gradient(a.value),a.axes)

#TODO implement also gradient for compressed

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
  for i in length(a)
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
    apply_to_field(k,f::AbstractArray...)

Numerically equivalent to

    map( (x...) -> apply_kernel_to_field(k,x...), f )
"""
function apply_to_field(k,f::AbstractArray...)
  v = Valued(k)
  apply(v,f...)
end

struct Valued{K}
  k::K
  Valued(k) = new{typeof(k)}(k)
end

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

@inline function apply_kernel!(cache,k::Valued,x::FieldNumberOrArray...)
  apply_kernel_to_field(k.k,x...)
end

function kernel_cache(k::Valued,x::FieldNumberOrArray...)
  nothing
end

function kernel_return_type(k::Valued,x::FieldNumberOrArray...)
  typeof(apply_kernel(k,x...))
end


