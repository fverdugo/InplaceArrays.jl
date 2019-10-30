
function field_cache(v::Number,x)
  nx = length(x)
  c = zeros(typeof(v),nx)
  CachedArray(c)
end

function evaluate_field!(c,v::Number,x)
  nx = length(x)
  setsize!(c,(nx,))
  for i in eachindex(x)
    @inbounds c[i] = v
  end
  c
end

function field_gradient(v::Number)
  T = typeof(v)
  E = eltype(T)
  zero(E)
end


