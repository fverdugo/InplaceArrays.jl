
const FieldNumberOrArray = Union{Field{T,D} where T,Number,AbstractArray} where D

"""
    apply_kernel_to_field(k::Kernel,f...) -> Field

Returns a field obtained by applying the kernel `k` to the 
values of the fields in `f`. That is, the returned field evaluated at
a point `x` provides the value obtained by applying kernel `k` to the
values of the fields `f` at point `x`. Formally, the resulting field at a point
 `x` is defined as

    fx = [ evaluate(fi,x) for fi in f]
    apply_kernel(k,fx...)


if any of the inputs in `f` is a number or an array of numbers
instead of a field it will be treated
as a "constant field". That is a filed that evaluated at any point `x` returns always
the underlying number or array.


In order to be able to call the [`gradient`](@ref) function of the
resulting field, one needs to define the gradient operator
associated with the underlying kernel.
This is done by adding a new method [`gradient(k::Kernel,f::Field...)`](@ref) for each kernel type.
"""
@inline function apply_kernel_to_field(k::Kernel,f::FieldNumberOrArray{D}...) where D
  g = _to_fields(Val{D}(),f...)
  AppliedField(k,g...)
end

@inline function apply_kernel_to_field(k::Kernel,f::NumberOrArray...)
  @unreachable "At least one input must be a Field"
end

"""
"""
@inline function apply_kernel_to_field(
  ::Type{T}, k::Kernel, f::FieldNumberOrArray{D}...) where {T,D}
  g = _to_fields(Val{D}(),f...)
  AppliedField(T,k,g...)
end

#function _to_fields(f::FieldNumberOrArray{D}...) where D
#  _to_fields(Val{D}(),f...)
#end

@inline function _to_fields(d::Val,a,b...)
  f = _to_field(d,a)
  g = _to_fields(d,b...)
  (f,g...)
end

@inline function _to_fields(d::Val,a)
  f = _to_field(d,a)
  (f,)
end

@inline _to_field(::Val,a::Field) = a

@inline _to_field(::Val{D},a::NumberOrArray) where D = ConstantField{D}(a)

"""
    gradient(k::Kernel,f::Field...)

Returns a field representing the gradient of the field obtained with

    apply_kernel_to_field(k,f...)
"""
function gradient(k::Kernel,f::Field...)
  @abstractmethod
end

#TODO also for broad cast?

gradient(k::Elem{typeof(+)},a::Field) = gradient(a)

gradient(k::Elem{typeof(-)},a::Field) = apply_kernel_to_field(k,gradient(a))

for op in (:+,:-)
  @eval begin
    function gradient(k::Elem{typeof($op)},a::Field,b::Field)
      apply_kernel_to_field(k,gradient(a),gradient(b))
    end
  end
end

# Arithmetic operations on fields

# TODO: test these ones
for op in (:+,:-)
  @eval begin
    function ($op)(a::Field)
      apply_kernel_to_field(elem($op),a)
    end
  end
end

for op in (:+,:-,:*)
  @eval begin
    function ($op)(a::Field,b::Field)
      apply_kernel_to_field(elem($op),a,b)
    end
  end
end

# Result of applying a kernel to the value of some fields

struct AppliedField{K,F,T,D} <: Field{T,D}
  k::K
  f::F
  @inline function AppliedField(k,f::(Field{S,D} where S)...) where D
    Ts = map(valuetype,f)
    vs = testvalues(Ts...)
    T = kernel_return_type(k,vs...)
    new{typeof(k),typeof(f),T,D}(k,f)
  end
  @inline function AppliedField(::Type{T},k,f::(Field{S,D} where S)...) where {T,D}
    new{typeof(k),typeof(f),T,D}(k,f)
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

#gradient(a::T) where T<:Number = zero(T)

#function gradient(a::AbstractArray{T}) where T <:Number
#  z = similar(a)
#  zi = zero(T)
#  for i in eachindex(z)
#    z[i] = zi
#  end
#  z
#end

#function gradient(a::AbstractArray{<:Number})
#  T = eltype(a)
#  Fill(zero(T),size(a))
#end


