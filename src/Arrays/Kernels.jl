# Define kernel interface

"""
$(SIGNATURES)

Returns the type of the result of calling kernel `f` with
arguments of the types of the objects `x`.
"""
function kernel_return_type(f,x...)
  @abstractmethod
end

"""
$(SIGNATURES)

Returns the `cache` needed to apply kernel `f` with arguments
of the same type as the objects in `x...`.
"""
function kernel_cache(f,x...)
  @abstractmethod
end

"""
$(SIGNATURES)

applies the kernel `f` at the arguments `x...` using
the scratch data provided in the given `cache` object. The `cache` object
is built with the [`kernel_cache`](@ref) function using arguments of the same type as in `x...`
In general, the returned value `y` can share some part of its state with the `cache` object.
If the result of two or more invocations of this function need to be accessed simultaneously
(e.g., in multi-threading), create and use various `cache` objects (e.g., one cache
per thread).
"""
function apply_kernel!(cache,f,x...)
  @abstractmethod
end

# Testing the interface

"""
$(SIGNATURES)

Function used to test if the kernel `f` has been
implemented correctly. `f` is a kernel object, `x` is the input
of the kernel, and `y` is the expected result. Function `cmp` is used to compare
the computed result with the expected one. The checks are done with the `@test`
macro.
"""
function test_kernel(f,x,y,cmp=(==))
  z = apply_kernel(f,x...)
  @test cmp(z,y)
  @test typeof(z) == kernel_return_type(f,x...)
  cache = kernel_cache(f,x...)
  z = apply_kernel!(cache,f,x...)
  @test cmp(z,y)
  z = apply_kernel!(cache,f,x...)
  @test cmp(z,y)
end


# Functions on kernel objects

"""
    apply_kernel(f,x...)

apply the fuctor `f` at the arguments `x...` by creating a temporary cache
internally. This functions is equivalent to
```jl
cache = kernel_cache(f,x...)
apply_kernel!(cache,f,x...)
```
"""
function apply_kernel(f,x...)
  cache = kernel_cache(f,x...)
  y = apply_kernel!(cache,f,x...)
  y
end

# Work with several kernels at once

"""
    kernel_caches(fs::Tuple,x...) -> Tuple

Returns a tuple with the cache corresponding to each kernel in `fs`
for the arguments `x...`.
"""
function kernel_caches(fs::Tuple,x...)
  _kernel_caches(x,fs...)
end

function _kernel_caches(x::Tuple,a,b...)
  ca = kernel_cache(a,x...)
  cb = kernel_caches(b,x...)
  (ca,cb...)
end

function _kernel_caches(x::Tuple,a)
  ca = kernel_cache(a,x...)
  (ca,)
end

"""
    apply_kernels!(caches::Tuple,fs::Tuple,x...) -> Tuple

Applies the kernels in the tuple `fs` at the arguments `x...`
by using the corresponding cache objects in the tuple `caches`.
The result is also a tuple containing the result for each kernel in `fs`.
"""
@inline function apply_kernels!(cfs::Tuple,f::Tuple,x...)
  _apply_kernels!(cfs,x,f...)
end

@inline function _apply_kernels!(cfs,x,f1,f...)
  cf1, cf = _split(cfs...)
  f1x = apply_kernel!(cf1,f1,x...)
  fx = apply_kernels!(cf,f,x...)
  (f1x,fx...)
end

@inline function _apply_kernels!(cfs,x,f1)
  cf1, = cfs
  f1x = apply_kernel!(cf1,f1,x...)
  (f1x,)
end

@inline function _split(a,b...)
  (a,b)
end

"""
$(SIGNATURES)
"""
function kernel_return_types(f::Tuple,Ts...)
  _kernel_return_types(Ts,f...)
end

function _kernel_return_types(x,a,b...)
  Ta = kernel_return_type(a,x...)
  Tb = kernel_return_types(b,x...)
  (Ta,Tb...)
end

function _kernel_return_types(x,a)
  Ta = kernel_return_type(a,x...)
  (Ta,)
end

# Include some well-known types in this interface

function kernel_return_type(f::Function,x...)
  Ts = map(typeof,x)
  return_type(f,Ts...)
end

@inline kernel_cache(f::Function,args...) = nothing

@inline apply_kernel!(::Nothing,f::Function,args...) = f(args...)

kernel_return_type(a::Number,x...) = typeof(a)

@inline kernel_cache(f::Number,args...) = nothing

@inline apply_kernel!(::Nothing,f::Number,args...) = f

kernel_return_type(a::AbstractArray,x...) = typeof(a)

@inline kernel_cache(f::AbstractArray,args...) = nothing

@inline apply_kernel!(::Nothing,f::AbstractArray,args...) = f

# Some particular cases

struct BCasted{F<:Function}
  f::F
end

"""
    bcast(f::Function)

Returns a kernel object that represents the "boradcasted" version of the given
function `f`.
"""
bcast(f::Function) = BCasted(f)

function kernel_return_type(f::BCasted,x...)
  Ts = map(typeof,x)
  T = return_type_broadcast(f.f,Ts...)
  c = CachedArray(testvalue(T))
  typeof(c)
end

function kernel_cache(f::BCasted,x...)
  Ts = map(typeof,x)
  args = testargs_broadcast(f.f,Ts...)
  r = broadcast(f.f,args...)
  cache = CachedArray(r)
   _prepare_cache(cache,x...)
end

@inline function apply_kernel!(cache,f::BCasted,x...)
  r = _prepare_cache(cache,x...)
  broadcast!(f.f,r,x...)
  r
end

@inline function _prepare_cache(c,x...)
  s = _sizes(x...)
  bs = Base.Broadcast.broadcast_shape(s...)
  if bs != size(c)
    setsize!(c,bs)
  end
  c
end

# TODO use map
@inline function _sizes(a,x...)
  (size(a), _sizes(x...)...)
end

@inline function _sizes(a)
  (size(a),)
end

