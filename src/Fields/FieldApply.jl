
const FieldNumberOrArray = Union{Field,Number,AbstractArray}

"""
    apply_kernel_to_field(k,f...) -> Field

Returns a field obtained by applying the kernel `k` to the 
values of the fields in `f`. That is, the returned field evaluated at
a point `x` provides the value obtained by applying kernel `k` to the
values of the fields `f` at point `x`.

# Examples

    #TODO

In order to be able to call the [`gradient`](@ref) function of the
resulting field, one needs to define the gradient operator
associated with the underlying kernel. This is done by adding a new method
to the `gradient` function as detailed below.
"""
function apply_kernel_to_field(k,f::FieldNumberOrArray...)
  AppliedField(k,f...)
end

function apply_kernel_to_field(k,f::NumberOrArray...)
  apply_kernel(k,f...)
end

"""
    gradient(k,f...)
"""
function gradient(k,f...)
end

#TODO also for broad cast?

gradient(k::Elem{typeof(+)},a::Field) = gradient(a)

gradient(k::Elem{typeof(-)},a::Field) = apply_kernel_to_field(k,gradient(a))

for op in (:+,:-)
  @eval begin
    function gradient(k::Elem{typeof($op)},a::FieldNumberOrArray,b::FieldNumberOrArray)
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

#function gradient(a::AbstractArray{T}) where T <:Number
#  z = similar(a)
#  zi = zero(T)
#  for i in eachindex(z)
#    z[i] = zi
#  end
#  z
#end

function gradient(a::AbstractArray{<:Number})
  T = eltype(a)
  Fill(zero(T),size(a))
end


