
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
