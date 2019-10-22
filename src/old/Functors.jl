module Functors

using Test

using InplaceArrays
using InplaceArrays.CachedArrays

export typedfun
export functor_cache
export functor_caches
export evaluate_functors!
export evaluate_functor!
export evaluate_functor
export test_functor
export bcast
export functor_return_type
export functor_return_types

# Define Functor interface

"""
    functor_return_type(f,Ts::DataType...)

Returns the type of the result of calling functor `f` with
arguments of the types in `Ts`.
"""
function functor_return_type end

function functor_return_types(f::Tuple,Ts...)
  _functor_return_types(Ts,f...)
end

function _functor_return_types(Ts,a,b...)
  Ta = functor_return_type(a,Ts...)
  Tb = functor_return_types(b,Ts...)
  (Ta,Tb...)
end

function _functor_return_types(Ts,a)
  Ta = functor_return_type(a,Ts...)
  (Ta,)
end

"""
    cache = functor_cache(f,x...)

Returns the `cache` needed to evaluate functor `f` with arguments
of the same type as the objects in `x...`.
"""
function functor_cache end

"""
    y = evaluate_functor!(cache,f,x...)

Evaluates the functor `f` at the arguments `x...` using
the scratch data provided in the given `cache` object. The `cache` object
is built with the [`functor_cache`](@ref) function using arguments of the same type as in `x...`
In general, the returned value `y` can share some part of its state with the `cache` object.
If the result of two or more invocations of this function need to be accessed simultaneously
(e.g., in multi-threading), create and use various `cache` objects (e.g., one cache
per thread).
"""
function evaluate_functor! end

"""
    evaluate_functor(f,x...)

Evaluate the fuctor `f` at the arguments `x...` by creating a temporary cache
internally. This functions is equivalent to
```jl
cache = functor_cache(f,x...)
evaluate_functor!(cache,f,x...)
```
"""
function evaluate_functor(f,x...)
  cache = functor_cache(f,x...)
  y = evaluate_functor!(cache,f,x...)
  y
end

"""
    test_functor(f,x,y,cmp::Function=(==))

Function used to test if the functor `f` has been
implemented correctly. `f` is a functor object, `x` is the input
of the functor, and `y` is the expected result. Function `cmp` is used to compare
the computed result with the expected one. The checks are done with the `@test`
macro.
"""
function test_functor(f,x,y,cmp=(==))
  z = evaluate_functor(f,x...)
  @test cmp(z,y)
  Ts = map(typeof,x)
  @test typeof(z) == functor_return_type(f,Ts...)
  cache = functor_cache(f,x...)
  z = evaluate_functor!(cache,f,x...)
  @test cmp(z,y)
  z = evaluate_functor!(cache,f,x...)
  @test cmp(z,y)
end

# Get the cache of several functors at once

"""
    functor_caches(fs::Tuple,x...) -> Tuple

Returns a tuple with the cache corresponding to each functor in `fs`
for the arguments `x...`.
"""
function functor_caches(fs::Tuple,x...)
  _functor_caches(x,fs...)
end
# TODO replace x by the types of x? It is more consistent with
# the functor_return_type

function _functor_caches(x::Tuple,a,b...)
  ca = functor_cache(a,x...)
  cb = functor_caches(b,x...)
  (ca,cb...)
end

function _functor_caches(x::Tuple,a)
  ca = functor_cache(a,x...)
  (ca,)
end

# Evaluate several functors at once

"""
    evaluate_functors!(caches::Tuple,fs::Tuple,x...) -> Tuple

Evaluates the functors in the tuple `fs` at the arguments `x...`
by using the corresponding cache objects in the tuple `caches`.
The result is also a tuple containing the result for each functor in `fs`.
"""
@inline function evaluate_functors!(cfs::Tuple,f::Tuple,x...)
  _evaluate_functors!(cfs,x,f...)
end

@inline function _evaluate_functors!(cfs,x,f1,f...)
  cf1, cf = _split(cfs...)
  f1x = evaluate_functor!(cf1,f1,x...)
  fx = evaluate_functors!(cf,f,x...)
  (f1x,fx...)
end

@inline function _evaluate_functors!(cfs,x,f1)
  cf1, = cfs
  f1x = evaluate_functor!(cf1,f1,x...)
  (f1x,)
end

@inline function _split(a,b...)
  (a,b)
end

# Include some well-known types in this interface

functor_return_type(f::Function,Ts...) = return_type(f,Ts...)

@inline functor_cache(f::Function,args...) = nothing

@inline evaluate_functor!(::Nothing,f::Function,args...) = f(args...)

functor_return_type(a::Number,Ts...) = typeof(a)

@inline functor_cache(f::Number,args...) = nothing

@inline evaluate_functor!(::Nothing,f::Number,args...) = f

functor_return_type(a::AbstractArray,Ts...) = typeof(a)

@inline functor_cache(f::AbstractArray,args...) = nothing

@inline evaluate_functor!(::Nothing,f::AbstractArray,args...) = f

# Some particular cases

struct BCasted{F<:Function}
  f::F
end

"""
    bcast(f::Function)

Returns a functor object that represents the "boradcasted" version of the given
function `f`.

# Examples

```jldoctests
julia> op = bcast(*)
InplaceArrays.Functors.BCasted{typeof(*)}(*)

julia> x = ones(2,3)
2×3 Array{Float64,2}:
 1.0  1.0  1.0
 1.0  1.0  1.0

julia> y = 2
2

julia> evaluate_functor(op,x,y)
2×3 CachedArray{Float64,2,Array{Float64,2}}:
 2.0  2.0  2.0
 2.0  2.0  2.0
```
"""
bcast(f::Function) = BCasted(f)

function functor_return_type(f::BCasted,Ts...)
  T = return_type_broadcast(f.f,Ts...)
  c = CachedArray(testvalue(T))
  typeof(c)
end

function functor_cache(f::BCasted,x...)
  Ts = map(typeof,x)
  args = testargs_broadcast(f.f,Ts...)
  r = broadcast(f.f,args...)
  cache = CachedArray(r)
   _prepare_cache(cache,x...)
end

@inline function evaluate_functor!(cache,f::BCasted,x...)
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

# TODO typed versions perhaps not needed
typedfun(::Type{T},f::Function) where T = TypedFunction(T,f)

struct TypedFunction{T,F}
  f::F
  function TypedFunction(::Type{T},f::Function) where T
    new{T,typeof(f)}(f)
  end
end

functor_return_type(f::TypedFunction{T},Ts...) where T = T

functor_cache(f::TypedFunction,x...) = nothing

function evaluate_functor!(::Nothing,f::TypedFunction{T},x...) where T
  r::T = f.f(x...)
  r
end

bcast(::Type{T},N::Int,f::Function) where T = TypedBCasted(T,N,f)

struct TypedBCasted{T,N,F}
  b::BCasted{F}
  function TypedBCasted(::Type{T},N::Int,f::Function) where T
    new{T,N,typeof(f)}(bcast(f))
  end
end

function functor_return_type(f::TypedBCasted{T,N},Ts...) where {T,N}
  CachedArray{T,N,Array{T,N}}
end

function functor_cache(f::TypedBCasted{T,N},x...) where {T,N}
  cache = CachedArray(T,N)
   _prepare_cache(cache,x...)
end

@inline function evaluate_functor!(cache,f::TypedBCasted,x...)
  evaluate_functor!(cache,f.b,x...)
end

end # module
