module Functors

using Test

using InplaceArrays.CachedArrays

export functor_cache
export functor_caches
export evaluate_functor!
export evaluate_functors!
export evaluate_functor
export test_functor
export bcast
export apply_functor

# Define Functor interface

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
is built with the [`functor_cache`](@ref) using arguments of the same type as in `x...`
In general, the returned value `y` can share some part of its state with the `cache` object.
If the result of two or more invocations of this function need to be accessed simultaneously
(e.g., in multi-threading), create and use various `cache` objects (e.g., one cache
per thread).
"""
function evaluate_functor! end

"""
    evaluate_functor(f,x...)

Equivalent to
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

function test_functor(f,x,y,cmp=(==))
  z = evaluate_functor(f,x...)
  @test cmp(z,y)
end

# Get the cache of several functors at once

function functor_caches(fs::Tuple,x...)
  _functor_caches(x,fs...)
end

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

@inline function evaluate_functors!(cfs,f::Tuple,x...)
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

@inline functor_cache(f::Function,args...) = nothing

@inline evaluate_functor!(::Nothing,f::Function,args...) = f(args...)

@inline functor_cache(f::Number,args...) = nothing

@inline evaluate_functor!(::Nothing,f::Number,args...) = f

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

julia> x = rand(2,3)
2×3 Array{Float64,2}:
 0.829692     0.300516  0.159187
 0.000128039  0.693663  0.854646

julia> y = 2
2

julia> evaluate_functor(op,x,y)
2×3 CachedArray{Float64,2,Array{Float64,2}}:
 1.65938      0.601031  0.318374
 0.000256078  1.38733   1.70929 
```
"""
bcast(f::Function) = BCasted(f)

function functor_cache(f::BCasted,x...)
  r = broadcast(f.f,x...)
  CachedArray(r)
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

@inline function _sizes(a,x...)
  (size(a), _sizes(x...)...)
end

@inline function _sizes(a)
  (size(a),)
end

struct Applied{G,F<:Tuple}
  g::G
  f::F
  function Applied(g,f...)
    new{typeof(g),typeof(f)}(g,f)
  end
end

"""
    c = apply_functor(g,f...)

Returns an object `c` representing the "composition" of functor `g` with several
functors `f...`. The resulting object `c` is such that
```julia
evaluate_functor(c,x...)
```
is equivalent to

```julia
fx = evaluate_functors(f,x...)
evaluate_functor(g,fx...)
```
"""
apply_functor(g,f...) = Applied(g,f...)

function functor_cache(f::Applied,x...)
  cfs = functor_caches(f.f,x...)
  fxs = evaluate_functors!(cfs,f.f,x...)
  cg = functor_cache(f.g,fxs...)
  (cg,cfs)
end

@inline function evaluate_functor!(cache,f::Applied,x...)
  cg, cfs = cache
  fxs = evaluate_functors!(cfs,f.f,x...)
  y = evaluate_functor!(cg,f.g,fxs...)
  y
end

end # module
