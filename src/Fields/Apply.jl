
# Extending Kernels to work with fields

FieldNumberOrArray = Union{Field,Number,AbstractArray}

# Elem

# Unary

function kernel_return_type(k::Elem,a::Field)
  typeof(apply_kernel(k,a))
end

function kernel_cache(k::Elem,a::Field)
  nothing
end

@inline function apply_kernel!(c,k::Elem,a::Field)
  AppliedField(k,a)
end

gradient(k::Elem{typeof(+)},a::Field) = gradient(a)

gradient(k::Elem{typeof(-)},a::Field) = apply_kernel(k,gradient(a))

# Binary

function kernel_return_type(k::Elem,a::FieldNumberOrArray,b::FieldNumberOrArray)
  typeof(apply_kernel(k,a,b))
end

function kernel_cache(k::Elem,a::FieldNumberOrArray,b::FieldNumberOrArray)
  nothing
end

@inline function apply_kernel!(c,k::Elem,a::FieldNumberOrArray,b::FieldNumberOrArray)
  AppliedField(k,a,b)
end

for op in (:+,:-)
  @evel begin
    function gradient(k::Elem{typeof($op)},a::FieldNumberOrArray,b::FieldNumberOrArray)
      apply_kernel(k,gradient(a),gradient(b))
    end
  end
end

# Result of applying a kernel to the value of some fields

struct AppliedField{K,F,T} <: Field{T}
  k::K
  f::F
  @inline function AppliedField(k,f...)
    Ts = map(valuetype,f)
    vs = map(testvalue,Ts)
    T = kernel_return_type(k,vs...)
    new{typeof(k),typeof(f),T}(k,f)
  end
end

function field_return_type(f::AppliedField,x::Point)
  Ts = kernel_return_types(f.f,x)
  kernel_return_type(f.k, map(testvalue,Ts)...)
end

function field_cache(f::AppliedField,x::Point)
  cf = kernel_caches(f.f,x)
  fx = apply_kernels!(cf,f.f,x)
  ck = kernel_cache(f.k,fx...)
  (ck,cf)
end

@inline function evaluate!(cache,f::AppliedField,x::Point)
  ck, cf = cache
  fx = apply_kernels!(cf,f.f,x)
  apply_kernel!(ck,f.k,fx...)
end

function gradient(f::AppliedField)
  gradient(f.k,f.f...)
end

gradient(a::T) where T<:Number = zero(T)

function gradient(a::AbstractArray{T}) where T
  z = similar(a)
  zi = zero(T)
  for i in eachindex(z)
    z[i] = zi
  end
  z
end

