
struct MockField{T,D} <: Field{T,D}
  v::T
  function MockField{D}(v::T) where {T,D}
    new{T,D}(v)
  end
end

field_cache(f::MockField,x::Point) = nothing

evaluate!(::Nothing,f::MockField,x::Point) = f.v*x[1]

function gradient(f::MockField{T,D}) where {T,D}
  E = eltype(T)
  P = Point{D,E}
  _p = zero(mutable(P))
  _p[1] = one(E)
  p = Point(_p)
  vg = outer(p,f.v)
  MockField{D}(vg)
end

struct MockBasis{V,D} <: Field{Vector{V},D}
  v::V
  ndofs::Int
  function MockBasis{D}(v::V,ndofs::Int) where {V,D}
    new{V,D}(v,ndofs)
  end
end

function field_cache(f::MockBasis{T,D},x::Point) where {T,D}
  zeros(T,f.ndofs)
end

function evaluate!(v,f::MockBasis,x::Point)
  for j in 1:f.ndofs
    @inbounds v[j] = f.v*x[1]
  end
  v
end

function gradient(f::MockBasis{T,D}) where {T,D}
  E = eltype(T)
  P = Point{D,E}
  _p = zero(mutable(P))
  _p[1] = one(E)
  p = Point(_p)
  vg = outer(p,f.v)
  MockBasis{D}(vg,f.ndofs)
end
