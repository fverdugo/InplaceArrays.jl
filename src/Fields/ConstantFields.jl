
struct ConstantField{V} <: Field{V}
  value::V
  @inline ConstantField(value::V) where V<:NumberOrArray = new{V}(value)
end

field_return_type(f::ConstantField,x::Point) = f.v

field_cache(f::ConstantField,x::Point) = nothing

@inline evaluate!(cache,f::ConstantField,x::Point) = f.v

function gradient(f::ConstantField{T}) where T<:Number
  ConstantField()
end

function gradient(f::AbstractArray{<:ConstantField})
  fi = testitem(f)
  gi = gradient(fi)
  Fill(gi,size(f))
end
