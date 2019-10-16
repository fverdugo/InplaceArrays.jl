module Inference

export testvalue
export testvalues
export testargs
export return_type
export return_type_broadcast

function return_type(f::Function,Ts...)
  args = testargs(f,Ts...)
  try
    typeof(f(args...))
  catch e
    if isa(e,DomainError)
      s = "Function $(nameof(f)) cannot be evaluated at $args, its not in the domain.\n"
      s *= " Define function `testargs(::typeof{$(nameof(f))},Ts...)`\n"
      s *= " which sould return an argument tuple in the function domain."
      error(s)
    else
      throw(e)
    end
  end

end

function return_type_broadcast(f::Function,Ts...)
  v = testvalues(Ts...)
  Ys = map(eltype,Ts)
  y = testargs(f,Ys...)
  args = (_new_arg(vi,yi) for (vi,yi) in zip(v,y))
  r = broadcast(f,args...)
  typeof(r)
end

function _new_arg(vi::AbstractArray,yi)
  dest = similar(vi)
  for i in eachindex(dest)
    dest[i] = yi
  end
  dest
end

_new_arg(vi,yi) = yi

testargs(f::Function,Ts...) = testvalues(Ts...)

"""
    testvalue(::Type{T}) where T

Returns an arbitrary instance of type `T`. It defaults to `zero(T)` for
non-array types and to an empty array for array types.
 This function is useful to determine the type returned by a
function without calling `Base._return_type`.

# Examples

```jldoctests
julia> a = testvalue(Int)
0

julia> b = testvalue(Float64)
0.0

julia> typeof(a + b)
Float64
```
"""
function testvalue end

testvalue(::Type{T}) where T = zero(T)

function testvalue(::Type{T}) where T<:AbstractArray{E,N} where {E,N}
   similar(T,fill(0,N)...)
end

function testvalues(a,b...)
  ta = testvalue(a)
  tb = testvalues(b...)
  (ta,tb...)
end

function testvalues(a)
  ta = testvalue(a)
  (ta,)
end

end # module
