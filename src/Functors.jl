module Functors

using Test

export functor_cache
export functor_caches
export evaluate_functor!
export evaluate_functors!
export evaluate_functor
export test_functor
export bcast
export apply_functor
export apply_meta_functor

# Define Functor interface

#TODO remove hash from Functor interface
# we don't need to expose hash in the Functor interface. In fact, we will only
# cach at the array level since we can efficiently compare indices. In general,
# one cannot efficienlty compare arbitrary functor arguments.
"""
`cache = functor_cache(hash::Dict,f,x...)`
"""
function functor_cache end

function functor_cache(f,x...)
  @assert ! isa(f,Dict)
  hash = Dict{UInt,Any}()
  functor_cache(hash,f,x...)
end

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

# Get the cache of several functors at once

function functor_caches(hash::Dict,fs::Tuple,x...)
  _functor_caches(hash,x,fs...)
end

function _functor_caches(hash::Dict,x::Tuple,a,b...)
  ca = functor_cache(hash,a,x...)
  cb = functor_caches(hash,b,x...)
  (ca,cb...)
end

function _functor_caches(hash::Dict,x::Tuple,a)
  ca = functor_cache(hash,a,x...)
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

@inline functor_cache(hash::Dict,f::Function,args...) = nothing

@inline evaluate_functor!(::Nothing,f::Function,args...) = f(args...)

@inline functor_cache(hash::Dict,f::Number,args...) = nothing

@inline evaluate_functor!(::Nothing,f::Number,args...) = f

@inline functor_cache(hash::Dict,f::AbstractArray,args...) = nothing

@inline evaluate_functor!(::Nothing,f::AbstractArray,args...) = f

# Some particular cases

"""
A functor acting as the broadcast of a given function
"""
struct BCasted{F<:Function}
  f::F
end

bcast(f::Function) = BCasted(f)

function functor_cache(hash::Dict,f::BCasted,x...)
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

##Perhaps not needed
#struct Composed{G,F}
#  g::G
#  f::F
#end
#
#apply_functor(g,f) = Composed(g,f)
#
#function functor_cache(hash::Dict,f::Composed,x...)
#  cf = functor_cache(hash,f.f,x...)
#  fx = evaluate_functor!(cf,f.f,x...)
#  cg = functor_cache(hash,f.g,fx)
#  (cg,cf)
#end
#
#@inline function evaluate_functor!(cache,f::Composed,x...)
#  cg, cf = cache
#  fx = evaluate_functor!(cf,f.f,x...)
#  gfx = evaluate_functor!(cg,f.g,fx)
#  gfx
#end

struct Applied{G,F<:Tuple}
  g::G
  f::F
  function Applied(g,f...)
    new{typeof(g),typeof(f)}(g,f)
  end
end

apply_functor(g,f...) = Applied(g,f...)

function functor_cache(hash::Dict,f::Applied,x...)
  cfs = functor_caches(hash,f.f,x...)
  fxs = evaluate_functors!(cfs,f.f,x...)
  cg = functor_cache(hash,f.g,fxs...)
  (cg,cfs)
end

@inline function evaluate_functor!(cache,f::Applied,x...)
  cg, cfs = cache
  fxs = evaluate_functors!(cfs,f.f,x...)
  y = evaluate_functor!(cg,f.g,fxs...)
  y
end

# Perhaps not needed
"""
a(x) = [m(x)](f(x)...)
"""
apply_meta_functor(m,f...) = Meta(m,f...)

struct Meta{M,F<:Tuple}
  m::M
  f::F
  function Meta(m::M,f...) where M
    new{M,typeof(f)}(m,f)
  end
end

function functor_cache(hash::Dict,a::Meta,x...)
  cm = functor_cache(hash,a.m,x...)
  g = evaluate_functor!(cm,a.m,x...)
  cf = functor_caches(hash,a.f,x...)
  fx = evaluate_functors!(cf,a.f,x...)
  cg = functor_cache(hash,g,fx...)
  (cm,cf,cg)
end

@inline function evaluate_functor!(cache,a::Meta,x...)
  cm, cf, cg = cache
  g = evaluate_functor!(cm,a.m,x...)
  fx = evaluate_functors!(cf,a.f,x...)
  r = evaluate_functor!(cg,g,fx...)
  r
end

end # module
