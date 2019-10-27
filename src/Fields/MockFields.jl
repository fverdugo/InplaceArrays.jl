
struct MockField{D,T} <: Field{T}
  v::T
  function MockField{D}(v::T) where {D,T}
    new{D,T}(v)
  end
end

field_cache(f::MockField,x::Point) = nothing

evaluate!(::Nothing,f::MockField,x::Point) = f.v*x[1]

function gradient(f::MockField{D,T}) where {D,T}
  E = eltype(T)
  P = Point{D,E}
  _p = zero(mutable(P))
  _p[1] = one(E)
  p = Point(_p)
  vg = outer(p,f.v)
  MockField{D}(vg)
end

struct MockBasis{D,V} <: Field{Vector{V}}
  v::V
  ndofs::Int
  function MockBasis{D}(v::V,ndofs::Int) where {D,V}
    new{D,V}(v,ndofs)
  end
end

function field_cache(f::MockBasis{D,T},x::Point) where {D,T}
  zeros(T,f.ndofs)
end

function evaluate!(v,f::MockBasis,x::Point)
  for j in 1:f.ndofs
    @inbounds v[j] = f.v*x[1]
  end
  v
end

function gradient(f::MockBasis{D,T}) where {D,T}
  E = eltype(T)
  P = Point{D,E}
  _p = zero(mutable(P))
  _p[1] = one(E)
  p = Point(_p)
  vg = outer(p,f.v)
  MockBasis{D}(vg,f.ndofs)
end
