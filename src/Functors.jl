
# Define Functor interface

"""
`cache = new_cache(f,x...)`
"""
function new_cache end

"""
`y = evaluate!(cache,f,x...)`
"""
function evaluate! end

"""
Like `evaluate!` but without passing the cache.
A cache will be created internally
"""
function evaluate(f,x...)
  cache = new_cache(f,x...)
  y = evaluate!(cache,f,x...)
  y
end

function test_functor(f,x,y,cmp=(==))
  z = evaluate(f,x...)
  @test cmp(z,y)
end


# Include some well-known types in this interface

@inline new_cache(f::Function,args...) = nothing

@inline evaluate!(::Nothing,f::Function,args...) = f(args...)

@inline new_cache(f::Number,args...) = nothing

@inline evaluate!(::Nothing,f::Number,args...) = f

@inline new_cache(f::AbstractArray,args...) = nothing

@inline evaluate!(::Nothing,f::AbstractArray,args...) = f

# Some particular cases

"""
A functor acting as the broadcast of a given function
"""
struct BCasted{F<:Function}
  f::F
end

bcast(f::Function) = BCasted(f)

function new_cache(f::BCasted,x...)
  broadcast(f.f,x...)
end

@inline function evaluate!(cache,f::BCasted,x...)
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

compose(g,f) = Composed(g,f)

apply(g,f) = compose(g,f)

function new_cache(f::Composed,x...)
  hash = Dict{UInt64,Any}()
  _new_cache(hash,f,x...)
end

function _new_cache(hash::Dict,f::Composed,x...)
  cf = _new_cache_f1(hash,f.f,x...)
  fx = _evaluate_fs1!(cf,f.f,x)
  cg = new_cache(f.g,fx)
  (cg,cf)
end

@inline function evaluate!(cache,f::Composed,x...)
  cg, cf = cache
  fx = _evaluate_fs1!(cf,f.f,x)
  gfx = evaluate!(cg,f.g,fx)
  gfx
end

struct Applied{G,F<:Tuple}
  g::G
  f::F
  function Applied(g,f...)
    new{typeof(g),typeof(f)}(g,f)
  end
end

apply(g,f...) = Applied(g,f...)

function new_cache(f::Applied,x...)
  hash = Dict{UInt64,Any}()
  _new_cache(hash,f,x...)
end

function _new_cache(hash::Dict,f::Applied,x...)
  cfs = _new_caches(hash,x,f.f...)
  fxs = _evaluate_fs!(cfs,x,f.f...)
  cg = new_cache(f.g,fxs...)
  (cg,cfs)
end

function _new_cache(hash::Dict,f,x...)
  new_cache(f,x...)
end

@inline function evaluate!(cache,f::Applied,x...)
  cg, cfs = cache
  fxs = _evaluate_fs!(cfs,x,f.f...)
  y = evaluate!(cg,f.g,fxs...)
  y
end

function _new_caches(hash,x,f1,f...)
  cf1 = _new_cache_f1(hash,f1,x...)
  csf = _new_caches(hash,x,f...)
  (cf1, csf...)
end

function _new_cache_f1(hash,f1,x...)
  i = objectid(f1)
  if ! haskey(hash,i)
    c = _new_cache(hash,f1,x...)
    fx = evaluate!(c,f1,x...)
    e = Evaluation(x,fx)
    cf1 = (e,c)
    hash[i] = cf1
  end
  hash[i]
end

function _new_caches(hash,x,f1)
  cf1 = _new_cache_f1(hash,f1,x...)
  (cf1,)
end

@inline function _evaluate_fs!(cfs,x,f1,f...)
  cf1, cf = _split(cfs...)
  f1x = _evaluate_fs1!(cf1,f1,x)
  fx = _evaluate_fs!(cf,x,f...)
  (f1x,fx...)
end

@inline function _evaluate_fs!(cfs,x,f1)
  cf1, = cfs
  f1x = _evaluate_fs1!(cf1,f1,x)
  (f1x,)
end

@inline function _evaluate_fs1!(cf1,f1,x)
  e, c = cf1
  f1x = e.fx[]
  if !(e.x[] === x)
    f1x = evaluate!(c,f1,x...)
    e.x[] = x
    e.fx[] = f1x
  end
  f1x
end

@inline function _split(a,b...)
  (a,b)
end

struct Evaluation{X,F}
  x::Ref{X}
  fx::Ref{F}
  function Evaluation(x::X,fx::F) where {X,F}
    new{X,F}(Ref(x),Ref(fx))
  end
end
