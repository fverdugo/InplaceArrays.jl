"""
    const Point{D,T} = VectorValue{D,T}

Type representing a point of D dimensions with coordinates of type T
"""
const Point{D,T} = VectorValue{D,T}

"""
    abstract type Field <: Kernel

Abstract type representing physical fields, bases of fields, and other related objects. 

The following functions need to be overloaded:

- [`evaluate_field!(cache,f,x)`](@ref)
- [`field_cache(f,x)`](@ref)

The following functions can be also provided optionally

- [`field_gradient(f)`](@ref)
- [`field_return_type(f,x)`](@ref)

The interface can be tested with

- [`test_field`](@ref)

Most of the functionality implemented in terms of this interface relies in duck typing (this is why all functions in the interface
have the word "field").  Thus, it is not strictly needed to work with types
that inherit from `Field`. This is specially useful in order to accommodate
existing types into this framework without the need to implement a wrapper type that inherits from `Field`. For instance, a default implementation is available for numbers, which behave like "constant" fields.  However, we recommend that new types inherit from `Field`.

"""
abstract type Field <: Kernel end
#TODO not sure if we need Field{D,T}
# Even if we adopt this, T will be a number for a field
# and a vector for a basis
# The advantage is that we could dispatch on field or basis
# The disadvantage is that implementing concrete types resulting
# from operation trees is more difficult
# TODO valuetype and field_return_type kind of duplicated, even though
# the last one allows to dispatch for vectorized and non-vectorized versions
# Any decision here has consequences in AppliedField
# EDIT:
# V needed to dispatch by either number or AbstractArray
# D needed in order to define gradients
# V first to facilitate dispatching
# EDIT: If we adopt the vectorized version, type params are not needed


"""
    field_cache(f,x)

Returns the cache object needed to evaluate field `f` at the vector of points `x`.
"""
function field_cache(f,x)
  @abstractmethod
end

"""
    evaluate!(cache,f::Field,x)

Returns an array, the length of the first axis is `length(x)`.
"""
function evaluate_field!(cache,f,x)
  @abstractmethod
end

"""
    field_gradient(f) -> Field

Returns another field that represents the gradient of the given one
"""
function field_gradient(f)
  @abstractmethod
end

# Default return type

"""
    field_return_type(f,x)

Computes the type obtained when evaluating field `f` at point `x`.
"""
function field_return_type(f,x)
  typeof(evaluate_field(f,x))
end

# Implement kernel interface (no duck typing here)

function kernel_return_type(f::Field,x)
  field_return_type(f,x)
end

function kernel_cache(f::Field,x)
  field_cache(f,x)
end

@inline function apply_kernel!(cache,f::Field,x)
  evaluate_field!(cache,f,x)
end

# Testers

"""
    test_field(
      f,
      x::AbstractVector{<:Point},
      v::AbstractArray,cmp=(==);
      grad=nothing)

Function used to test the field interface.
"""
function test_field(
  f,
  x::AbstractVector{<:Point},
  v::AbstractArray,cmp=(==);
  grad=nothing)

  w = evaluate_field(f,x)

  np, = size(w)
  @test length(x) == np
  @test cmp(w,v)
  @test typeof(w) == field_return_type(f,x)

  cf = field_cache(f,x)
  r = evaluate_field!(cf,f,x)
  @test cmp(r,v)

  _x = vcat(x,x)
  _v = vcat(v,v)
  _w = evaluate_field!(cf,f,_x)
  @test cmp(_w,_v)

  if isa(f,Field)
    test_kernel(f,(x,),v,cmp)
  end

  if grad != nothing
    g = field_gradient(f)
    test_field(g,x,grad,cmp)
  end

end

# Some API

"""
    evaluate(f::Field,x)

Equivalent to 

    cache = field_cache(f,x)
    evaluate!(cache,f,x)
"""
function evaluate(f::Field,x)
  cache = field_cache(f,x)
  evaluate!(cache,f,x)
end

"""
"""
@inline function evaluate!(cache,f::Field,x)
  evaluate_field!(cache,f,x)
end

"""
"""
function evaluate_field(f,x)
  c = field_cache(f,x)
  evaluate_field!(c,f,x)
end

"""
    gradient(f::Field)

Like [`field_gradient(f)`](@ref) but only for types `<:Field`.
"""
function gradient(f::Field)
  field_gradient(f)
end

"""
   const ∇ = gradient

A fancy alias for the `gradient` function.
"""
const ∇ = gradient

"""
"""
function field_return_types(f::Tuple,x)
  _field_return_types(x,f...)
end

function _field_return_types(x,a,b...)
  Ta = field_return_type(a,x)
  Tb = field_return_types(b,x)
  (Ta,Tb...)
end

function _field_return_types(x,a)
  Ta = field_return_type(a,x)
  (Ta,)
end

"""
"""
function field_caches(f::Tuple,x)
  _field_caches(x,f...)
end

function _field_caches(x,a,b...)
  ca = field_cache(a,x)
  cb = field_caches(b,x)
  (ca,cb...)
end

function _field_caches(x,a)
  ca = field_cache(a,x)
  (ca,)
end

"""
"""
function evaluate_fields(f::Tuple,x)
  cf = field_caches(f,x)
  evaluate_fields!(cf,f,x)
end

"""
"""
@inline function evaluate_fields!(cf::Tuple,f::Tuple,x)
  _evaluate_fields!(cf,x,f...)
end

function _evaluate_fields!(c,x,a,b...)
  ca, cb = _split(c...)
  ax = evaluate_field!(ca,a,x)
  bx = evaluate_fields!(cb,b,x)
  (ax,bx...)
end

function _evaluate_fields!(c,x,a)
  ca, = c
  ax = evaluate_field!(ca,a,x)
  (ax,)
end

@inline function _split(a,b...)
  (a,b)
end

"""
"""
function field_gradients(a,b...)
  ga = field_gradient(a)
  gb = field_gradients(b...)
  (ga,gb...)
end

function field_gradients(a)
  ga = field_gradient(a)
  (ga,)
end

"""
"""
function evaluate_all(f::Tuple,x)
  _evaluate_all(x,f...)
end

function _evaluate_all(x,a,b...)
  ax = evaluate(a,x)
  bx = evaluate_all(b,x)
  (ax, bx...)
end

function _evaluate_all(x,a)
  ax = evaluate(a,x)
  (ax,)
end

"""
"""
function gradient_all(a,b...)
  ga = gradient(a)
  gb = gradient_all(b...)
  (ga,gb...)
end

"""
"""
function gradient_all(a)
  ga = gradient(a)
  (ga,)
end

