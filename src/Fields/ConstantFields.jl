
struct ConstantField{V,D} <: Field{V,D}
  value::V
  @inline function ConstantField{D}(value::V) where {V<:NumberOrArray,D}
    new{V,D}(value)
  end
end

field_return_type(f::ConstantField,x::Point) = valuetype(f)

field_cache(f::ConstantField,x::Point) = nothing

@inline evaluate!(cache,f::ConstantField,x::Point) = f.value

function gradient(f::ConstantField{T,D}) where {T<:Number,D}
  p = zero(Point{D,T})
  v = zero(T)
  g = outer(p,v)
  ConstantField{D}(g)
end

function gradient(f::ConstantField{V,D}) where {V<:AbstractArray,D}
  T = eltype(V)
  p = zero(Point{D,T})
  v = zero(T)
  gi = outer(p,v)
  g = similar(f.value,typeof(gi))
  for i in eachindex(g)
    @inbounds g[i] = gi
  end
  ConstantField{D}(g)
end

function gradient(f::AbstractArray{<:ConstantField})
  fi = testitem(f)
  gi = gradient(fi)
  Fill(gi,size(f))
end

struct ToField{D} end

kernel_cache(::ToField,::NumberOrArray) = nothing

function kernel_return_type(k::ToField,x::NumberOrArray)
  typeof(apply_kernel(k,x))
end

function apply_kernel!(::Nothing,::ToField{D},x::NumberOrArray) where D
  ConstantField{D}(x)
end




