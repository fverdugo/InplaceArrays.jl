
struct MockField{T,D} <: Field
  v::T
  function MockField{D}(v::Number) where {T,D}
    new{typeof(v),D}(v)
  end
end

function field_cache(f::MockField,x)
  nx = length(x)
  c = zeros(typeof(f.v),nx)
  CachedArray(c)
end

function evaluate_field!(c,f::MockField,x)
  nx = length(x)
  setsize!(c,(nx,))
  for i in eachindex(x)
    @inbounds xi = x[i]
    @inbounds c[i] = f.v*xi[1]
  end
  c
end

function field_gradient(f::MockField{T,D}) where {T,D}
  E = eltype(T)
  P = Point{D,E}
  _p = zero(mutable(P))
  _p[1] = one(E)
  p = Point(_p)
  vg = outer(p,f.v)
  MockField{D}(vg)
end

struct MockBasis{V,D} <: Field
  v::V
  ndofs::Int
  function MockBasis{D}(v::Number,ndofs::Int) where D
    new{typeof(v),D}(v,ndofs)
  end
end

function field_cache(f::MockBasis,x)
  np = length(x)
  s = (np, f.ndofs)
  c = zeros(typeof(f.v),s)
  CachedArray(c)
end

function evaluate_field!(v,f::MockBasis,x)
  np = length(x)
  s = (np, f.ndofs)
  setsize!(v,s)
  for i in 1:np
    @inbounds xi = x[i]
    for j in 1:f.ndofs
      @inbounds v[i,j] = f.v*xi[1]
    end
  end
  v
end

function field_gradient(f::MockBasis{T,D}) where {T,D}
  E = eltype(T)
  P = Point{D,E}
  _p = zero(mutable(P))
  _p[1] = one(E)
  p = Point(_p)
  vg = outer(p,f.v)
  MockBasis{D}(vg,f.ndofs)
end
