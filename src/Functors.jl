module Functors

using Test

export functor_cache
export evaluate_functor!
export evaluate_functor
export test_functor
export bcast
export apply_functor

# Define Functor interface

"""
`cache = functor_cache(f,x...)`
"""
function functor_cache end

"""
`y = evaluate_functor!(cache,f,x...)`
"""
function evaluate_functor! end

"""
Like `evaluate_functor!` but without passing the cache.
A cache will be created internally
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


# Include some well-known types in this interface

@inline functor_cache(f::Function,args...) = nothing

@inline evaluate_functor!(::Nothing,f::Function,args...) = f(args...)

@inline functor_cache(f::Number,args...) = nothing

@inline evaluate_functor!(::Nothing,f::Number,args...) = f

@inline functor_cache(f::AbstractArray,args...) = nothing

@inline evaluate_functor!(::Nothing,f::AbstractArray,args...) = f

# Some particular cases

"""
A functor acting as the broadcast of a given function
"""
struct BCasted{F<:Function}
  f::F
end

bcast(f::Function) = BCasted(f)

function functor_cache(f::BCasted,x...)
  broadcast(f.f,x...)
end

@inline function evaluate_functor!(cache,f::BCasted,x...)
  r = _prepare_cache(cache,x...)
  broadcast!(f.f,r,x...)
  r
end

@inline function _prepare_cache(c,x...)
  s = _sizes(x...)
  bs = Base.Broadcast.broadcast_shape(s...)
  r = c
  if bs != size(c)
    error("Size of inputs has changed. Function not prepared yet")
  end
  r
end

@inline function _sizes(a,x...)
  (size(a), _sizes(x...)...)
end

@inline function _sizes(a)
  (size(a),)
end

struct Composed{G,F}
  g::G
  f::F
end

apply_functor(g,f) = Composed(g,f)

function functor_cache(f::Composed,x...)
  hash = Dict{UInt64,Any}()
  _functor_cache(hash,f,x...)
end

function _functor_cache(hash::Dict,f::Composed,x...)
  cf = _functor_cache_f1(hash,f.f,x...)
  fx = _evaluate_functor_fs1!(cf,f.f,x)
  cg = functor_cache(f.g,fx)
  (cg,cf)
end

@inline function evaluate_functor!(cache,f::Composed,x...)
  cg, cf = cache
  fx = _evaluate_functor_fs1!(cf,f.f,x)
  gfx = evaluate_functor!(cg,f.g,fx)
  gfx
end

struct Applied{G,F<:Tuple}
  g::G
  f::F
  function Applied(g,f...)
    new{typeof(g),typeof(f)}(g,f)
  end
end

apply_functor(g,f...) = Applied(g,f...)

function functor_cache(f::Applied,x...)
  hash = Dict{UInt64,Any}()
  _functor_cache(hash,f,x...)
end

function _functor_cache(hash::Dict,f::Applied,x...)
  cfs = _functor_caches(hash,x,f.f...)
  fxs = _evaluate_functor_fs!(cfs,x,f.f...)
  cg = functor_cache(f.g,fxs...)
  (cg,cfs)
end

function _functor_cache(hash::Dict,f,x...)
  functor_cache(f,x...)
end

@inline function evaluate_functor!(cache,f::Applied,x...)
  cg, cfs = cache
  fxs = _evaluate_functor_fs!(cfs,x,f.f...)
  y = evaluate_functor!(cg,f.g,fxs...)
  y
end

function _functor_caches(hash,x,f1,f...)
  cf1 = _functor_cache_f1(hash,f1,x...)
  csf = _functor_caches(hash,x,f...)
  (cf1, csf...)
end

function _functor_cache_f1(hash,f1,x...)
  i = objectid(f1)
  if ! haskey(hash,i)
    c = _functor_cache(hash,f1,x...)
    fx = evaluate_functor!(c,f1,x...)
    e = Evaluation(x,fx)
    cf1 = (e,c)
    hash[i] = cf1
  end
  hash[i]
end

function _functor_caches(hash,x,f1)
  cf1 = _functor_cache_f1(hash,f1,x...)
  (cf1,)
end

@inline function _evaluate_functor_fs!(cfs,x,f1,f...)
  cf1, cf = _split(cfs...)
  f1x = _evaluate_functor_fs1!(cf1,f1,x)
  fx = _evaluate_functor_fs!(cf,x,f...)
  (f1x,fx...)
end

@inline function _evaluate_functor_fs!(cfs,x,f1)
  cf1, = cfs
  f1x = _evaluate_functor_fs1!(cf1,f1,x)
  (f1x,)
end

@inline function _evaluate_functor_fs1!(cf1,f1,x)
  e, c = cf1
  f1x = e.fx
  if !(e.x === x)
    f1x = evaluate_functor!(c,f1,x...)
    e.x = x
    e.fx = f1x
  #  println("Not reusing")
  #else
  #  println("Reusing")
  end
  f1x
end

@inline function _split(a,b...)
  (a,b)
end

mutable struct Evaluation{X,F}
  x::X
  fx::F
  function Evaluation(x::X,fx::F) where {X,F}
    new{X,F}(x,fx)
  end
end

end # module
