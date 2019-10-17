module Arrays

using Test
using InplaceArrays
using FillArrays

export test_array
export test_array_of_functors
export evaluate_array_of_functors
export evaluate_array_of_functors
export apply_array_of_functors
export apply_arrays_of_functors
export array_cache
export array_caches
export array_of_functors_cache
export getindex!
export getitems!
export testitem
export testitems
export uses_hash

using InplaceArrays.Functors: _split

"""
    testitem(a::AbstractArray)

Returns an arbitrary instance of `eltype(a)`. The default returned value is the first entry
in the array if `length(a)>0` and `testvalue(eltype(a))` if `length(a)==0`
See the [`testvalue`](@ref) function.

This function is useful to determine the type resulting from applying a given function
to the items in the array without calling the `Base._return_type` function.

# Examples

```jldoctests
julia> a = collect(1:0)
0-element Array{Int64,1}

julia> ai = testitem(a) # Safely works with empty arrays
0

julia> typeof(sqrt(ai))
Float64
```
"""
function testitem end

function testitem(a::AbstractArray{T}) where T
  if length(a) >0
    first(a)
  else
    testvalue(T)
  end::T
end

function testitem(a::Fill)
  a.value
end

"""
    testitems(b::AbstractArray...) -> Tuple

Returns a tuple with the result of `testitem` applied to each of the
arrays in `b`.
"""
function testitems(a::AbstractArray,b::AbstractArray...)
  va = testitem(a)
  vb = testitems(b...)
  (va,vb...)
end

function testitems(a::AbstractArray)
  va = testitem(a)
  (va,)
end

"""
    array_cache(a::AbstractArray)

Returns a cache object to be used in the [`getindex!`](@ref) function.
It defaults to 

    array_cache(a::T) where T = nothing

for types `T` such that `uses_hash(T) == Val(false)`, and 

    function array_cache(a::T) where T
      hash = Dict{UInt,Any}()
      array_cache(hash,a)
    end

for types `T` such that `uses_hash(T) == Val(true)`, see the [`uses_hash`](@ref) function. In the later case, the
type `T` should implement the following signature:

    array_cache(hash::Dict,a::AbstractArray)

where we pass a dictionary (i.e., a hash table) in the first argument. This hash table can be used to test
if the object `a` has already build a cache and re-use it as follows

    id = objectid(a)
    if haskey(hash,id)
      cache = hash[id] # Reuse cache
    else
      cache = ... # Build a new cache depending on your needs
      hash[id] = cache # Register the cache in the hash table
    end

This mechanism is needed, e.g., to re-use intermediate results in complex lazy operation trees.
In multi-threading computations, a different hash table per thread has to be used in order
to avoid race conditions.
"""
function array_cache end

function array_cache(hash,a::T) where T
  if uses_hash(T) == Val(true)
    error("array_cache(::Dict,::$T) not defined")
  end
  array_cache(a)
end

function array_cache(a::T) where T
  _default_array_cache(a,uses_hash(T))
end

function _default_array_cache(a,::Val{false})
  nothing
end

function _default_array_cache(a,::Val{true})
  hash = Dict{UInt,Any}()
  array_cache(hash,a)
end

"""
    uses_hash(::Type{T}) where T <:AbstractArray

This function is used to specify if the type `T` uses the
hash-based mechanism to reuse caches.  It should return
either `Val(true)` or `Val(false)`. It defaults to

    uses_hash(::Type{<:AbstractArray}) = Val(false)

Once this function is defined for the type `T` it can also
be called on instances of `T`.

# Examples

```jldoctests
julia> uses_hash(Matrix{Float64})
Val{false}()

julia> a = ones(2,3)
2×3 Array{Float64,2}:
 1.0  1.0  1.0
 1.0  1.0  1.0

julia> uses_hash(a)
Val{false}()

```
"""
function uses_hash end

uses_hash(::Type{<:AbstractArray}) = Val(false)

uses_hash(::T) where T = uses_hash(T)

function array_of_functors_cache(a::AbstractArray,x...)
  xi = testitems(x...)
  cx = array_caches(x...)
  ai = testitem(a)
  cai = functor_cache(ai,xi...)
  ca = array_cache(a)
  (ca, cai, cx)
end

"""
    getindex!(cache,a::AbstractArray,i...)

Returns the item of the array `a` associated with index `i`
by (possibly) using the scratch data passed in the `cache` object.

It defaults to

    getindex!(cache,a::AbstractArray,i...) = a[i...]

The `cache` object is constructed with the [`array_cache`](@ref) function.

# Examples

```jldocstests
julia> a = collect(1:4)
4-element Array{Int64,1}:
 1
 2
 3
 4

julia> cache = array_cache(a)

julia> getindex!(cache,a,2)
2

julia> getindex!(cache,a,4)
4
```
In this example, using the extended interface provides little benefit,
but for new array types that need scratch data, efficient implementations
of `getindex!` can make a performance difference by avoiding 
low granularity allocations.
"""
function getindex! end

getindex!(cache,a::AbstractArray,i...) = a[i...]

# Test the interface

function test_array(
  a::AbstractArray{T,N}, b::AbstractArray{S,N},cmp=(==)) where {T,S,N}
  @test cmp(a,b)
  cache = array_cache(a)
  t = true
  for i in eachindex(a)
    bi = b[i]
    ai = getindex!(cache,a,i)
    t = t && cmp(bi,ai)
  end
  @test t
  t = true
  for i in eachindex(a)
    ai = getindex!(cache,a,i)
    t = t && (typeof(ai) == eltype(a))
    t = t && (typeof(ai) == T)
  end
  @test t
  @test IndexStyle(a) == IndexStyle(b)
  true
end

function test_array_of_functors(
  a::AbstractArray, x::Tuple, r::AbstractArray, cmp=(==) )
  ca, cai, cx = array_of_functors_cache(a,x...)
  t = true
  for i in eachindex(a)
    ai = getindex!(ca,a,i)
    xi = getitems!(cx,x,i...)
    vi = evaluate_functor!(cai,ai,xi...)
    t = t && cmp(vi,r[i])
  end
  @test t
  v = evaluate_array_of_functors(a,x...)
  test_array(v,r,cmp)
end

# Work with several arrays at once

@inline function getitems!(cf::Tuple,a::Tuple{Vararg{<:AbstractArray}},i...)
  _getitems!(cf,i,a...)
end

@inline function _getitems!(c,i,a,b...)
  ca,cb = _split(c...)
  ai = getindex!(ca,a,i...)
  bi = getitems!(cb,b,i...)
  (ai,bi...)
end

@inline function _getitems!(c,i,a)
  ca, = c
  ai = getindex!(ca,a,i...)
  (ai,)
end

function array_caches(a::AbstractArray,b::AbstractArray...)
  hash = Dict{UInt,Any}()
  array_caches(hash,a,b...)
end

function array_caches(hash::Dict,a::AbstractArray,b::AbstractArray...)
  ca = array_cache(hash,a)
  cb = array_caches(hash,b...)
  (ca,cb...)
end

function array_caches(hash::Dict,a::AbstractArray)
  ca = array_cache(hash,a)
  (ca,)
end


"""
    evaluate_array_of_functors(f,a::AbstractArray...)

Returns a (lazy) array representing the evaluation of the
given functor `f` to the entries of the input arrays `a`.
The returned array `r` is such that `r[i] == evaluate_functor(f,a[1][i],a[2][i],...)`
Items in the resulting array `r` can be memory-efficiently recovered by using the [`getindex!`](@ref)
function. Note that this function returns a lazy object. The operations are not performed until
an entry of the array is retrieved. By applying this function to the result `r` again
(possibly with another functor) we create a lazy operation tree. The underlying implementation
is able to reuse intermediate results in this operation tree.

# Examples

```jldoctests
julia> a = collect(1:5)
5-element Array{Int64,1}:
 1
 2
 3
 4
 5

julia> b = collect(6:10)
5-element Array{Int64,1}:
  6
  7
  8
  9
 10

julia> c = evaluate_array_of_functors(+,a,b)
5-element InplaceArrays.Arrays.EvaluatedArray{Int64,1,Tuple{Array{Int64,1},Array{Int64,1}},FillArrays.Fill{typeof(+),1,Tuple{Base.OneTo{Int64}}}}:
  7
  9
 11
 13
 15

julia> d = evaluate_array_of_functors(*,c,c)
5-element InplaceArrays.Arrays.EvaluatedArray{Int64,1,Tuple{InplaceArrays.Arrays.EvaluatedArray{Int64,1,Tuple{Array{Int64,1},Array{Int64,1}},FillArrays.Fill{typeof(+),1,Tuple{Base.OneTo{Int64}}}},InplaceArrays.Arrays.EvaluatedArray{Int64,1,Tuple{Array{Int64,1},Array{Int64,1}},FillArrays.Fill{typeof(+),1,Tuple{Base.OneTo{Int64}}}}},FillArrays.Fill{typeof(*),1,Tuple{Base.OneTo{Int64}}}}:
  49
  81
 121
 169
 225
```
"""
function evaluate_array_of_functors(f,a::AbstractArray...)
  s = common_size(a...)
  EvaluatedArray(Fill(f,s...),a...)
end

function _prepare_shape(a...)
  s = common_size(a...)
  N = length(s)
  (N,s)
end

function common_size(a::AbstractArray...)
  a1, = a
  c = all([size(a1) == size(ai) for ai in a])
  if !c
    error("Array sizes $(map(size,a)) are not compatible.")
  end
  s = size(a1)
  s
end

#TODO not sure what to do with shape and index-style
function common_index_style(::Type{<:Tuple})
  IndexLinear()
end

mutable struct Evaluation{X,F}
  x::X
  fx::F
  function Evaluation(x::X,fx::F) where {X,F}
    new{X,F}(x,fx)
  end
end

"""
    apply_array_of_functors(g,f::AbstractArray...)
"""
function apply_array_of_functors(g,f::AbstractArray...)
  s = common_size(f...)
  apply_arrays_of_functors(Fill(g,s...),f...)
end

"""
    apply_arrays_of_functors(g::AbstractArray,f::AbstractArray...)
"""
function apply_arrays_of_functors(g::AbstractArray,f::AbstractArray...)
  AppliedArray(g,f...)
end

struct AppliedArray{T,N,G,F<:Tuple} <:AbstractArray{T,N}
  size::NTuple{N,Int}
  g::G
  f::F
  function AppliedArray(g::AbstractArray,f::AbstractArray...)
    gi = testitem(g)
    fi = testitems(f...)
    vi = apply_functor(gi,fi...)
    T = typeof(vi) # TODO this assumes concrete types in g and f
    N, s = _prepare_shape(g,f...)
    G = typeof(g)
    F = typeof(f)
    new{T,N,G,F}(s,g,f)
  end
end

function testitem(a::AppliedArray)
  fi = testitems(a.f...)
  gi = testitem(a.g)
  r = apply_functor(gi,fi...)
  r
end

function uses_hash(::Type{<:AppliedArray})
  Val(true)
end

function array_cache(hash::Dict,a::AppliedArray)
  cf = array_caches(hash,a.f...)
  cg = array_cache(hash,a.g)
  (cf,cg)
end

@inline function getindex!(cache,a::AppliedArray,i...)
  cf, cg = cache
  fi = getitems!(cf,a.f,i...)
  gi = getindex!(cg,a.g,i...)
  r = apply_functor(gi,fi...)
  r
end

function Base.getindex(a::AppliedArray,i...)
  cache = array_cache(a)
  getindex!(cache,a,i...)
end

Base.size(a::AppliedArray) = a.size

function Base.IndexStyle(
  ::Type{AppliedArray{T,N,G,F}}) where {T,N,G,F}
  common_index_style(F)
end

"""
    evaluate_array_of_functors(f::AbstractArray,a::AbstractArray...)

# Examples

```jldoctests
julia> g = [+,-,*,mod,max]
5-element Array{Function,1}:
 +  
 -  
 *  
 mod
 max

julia> x = collect(1:5)
5-element Array{Int64,1}:
 1
 2
 3
 4
 5

julia> y = collect(6:10)
5-element Array{Int64,1}:
  6
  7
  8
  9
 10

julia> evaluate_array_of_functors(g,x,y)
5-element InplaceArrays.Arrays.EvaluatedArray{Int64,1,Tuple{Array{Int64,1},Array{Int64,1}},Array{Function,1}}:
  7
 -5
 24
  4
 10
```
"""
function evaluate_array_of_functors(f::AbstractArray,a::AbstractArray...)
  EvaluatedArray(f,a...)
end

# We need an operation tree in terms of evaluated arrays as much
# in order to allow caching of intermediate results
function evaluate_array_of_functors(f::AppliedArray,a::AbstractArray...)
  ffx = [ evaluate_array_of_functors(ffi,a...) for ffi in f.f ]
  evaluate_array_of_functors(f.g,ffx...)
end

struct EvaluatedArray{T,N,F,G} <: AbstractArray{T,N}
  g::G
  f::F
  size::NTuple{N,Int}
  function EvaluatedArray(g::AbstractArray,f::AbstractArray...)
    G = typeof(g)
    F = typeof(f)
    gi = testitem(g) #Assumes that all functors return the same type
    Ts = map(eltype,f)
    T = functor_return_type(gi,Ts...)
    N, s = _prepare_shape(g,f...)
    new{T,N,F,G}(g,f,s)
  end
end

function uses_hash(::Type{<:EvaluatedArray})
  Val(true)
end

function array_cache(hash::Dict,a::EvaluatedArray)
    id = objectid(a)
    if haskey(hash,id)
      cache = hash[id]
    else
      cache = _array_cache(hash,a)
      hash[id] = cache
    end
    cache
end

function _array_cache(hash,a::EvaluatedArray)
  cg = array_cache(hash,a.g)
  gi = testitem(a.g)
  fi = testitems(a.f...)
  cf = array_caches(hash,a.f...)
  cgi = functor_cache(gi,fi...)
  ai = evaluate_functor!(cgi,gi,fi...)
  i = -testitem(eachindex(a))
  e = Evaluation((i,),ai)
  c = (cg, cgi, cf)
  (c,e)
end

function getindex!(cache,a::EvaluatedArray,i::Integer...)
  li = LinearIndices(a)
  getindex!(cache,a,li[i...])
end

function getindex!(cache,a::EvaluatedArray,i::Integer)
  _cached_getindex!(cache,a,(i,))
end

function getindex!(cache,a::EvaluatedArray,i::CartesianIndex)
  _cached_getindex!(cache,a,Tuple(i))
end

function _cached_getindex!(cache,a::EvaluatedArray,i::Tuple)
  c, e = cache
  v = e.fx
  if e.x != i
    v = _getindex!(c,a,i...)
    e.x = i
    e.fx = v
  end
   v
end

function _getindex!(cache,a::EvaluatedArray,i...)
  cg, cgi, cf = cache
  gi = getindex!(cg,a.g,i...)
  fi = getitems!(cf,a.f,i...)
  vi = evaluate_functor!(cgi,gi,fi...)
  vi
end

function Base.getindex(a::EvaluatedArray,i...)
  ca = array_cache(a)
  getindex!(ca,a,i...)
end

function Base.IndexStyle(
  ::Type{EvaluatedArray{T,N,F,G}}) where {T,N,F,G}
  common_index_style(F)
end

Base.size(a::EvaluatedArray) = a.size

# TODO Particular implementations for Fill
# TODO Implement Compressed
# TODO Think about iteration and sub-iteration

end # module
