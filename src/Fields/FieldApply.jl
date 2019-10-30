
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
@inline function apply_kernel_to_field(k,f...)
  AppliedField(k,f...)
end

"""
    kernel_gradient(k::Kernel,f::Field...)

Returns a field representing the gradient of the field obtained with

    apply_kernel_to_field(k,f...)
"""
function kernel_gradient(k,f...)
  @abstractmethod
end

kernel_gradient(k::BCasted{typeof(+)},a) = field_gradient(a)

kernel_gradient(k::BCasted{typeof(-)},a) = apply_kernel_to_field(k,field_gradient(a))

for op in (:+,:-)
  @eval begin
    function kernel_gradient(k::BCasted{typeof($op)},f...)
      apply_kernel_to_field(k,field_gradients(f...)...)
    end
  end
end

# Arithmetic operations on fields

# TODO: test these ones
for op in (:+,:-)
  @eval begin
    function ($op)(a::Field)
      apply_kernel_to_field(bcast($op),a)
    end
  end
end

for op in (:+,:-,:*)
  @eval begin
    function ($op)(a::Field,b::Field)
      apply_kernel_to_field(bcast($op),a,b)
    end
  end
end

# Result of applying a kernel to the value of some fields

struct AppliedField{K,F} <: Field
  k::K
  f::F
  @inline function AppliedField(k,f...)
    new{typeof(k),typeof(f)}(k,f)
  end
end

function field_return_type(f::AppliedField,x)
  Ts = field_return_types(f.f,x)
  kernel_return_type(f.k, testvalues(Ts...)...)
end

function field_cache(f::AppliedField,x)
  cf = field_caches(f.f,x)
  fx = evaluate_fields!(cf,f.f,x)
  ck = kernel_cache(f.k,fx...)
  (ck,cf)
end

@inline function evaluate_field!(cache,f::AppliedField,x)
  ck, cf = cache
  fx = evaluate_fields!(cf,f.f,x)
  apply_kernel!(ck,f.k,fx...)
end

function field_gradient(f::AppliedField)
  kernel_gradient(f.k,f.f...)
end

