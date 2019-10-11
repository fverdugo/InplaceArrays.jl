```@meta
DocTestSetup = quote
    using InplaceArrays
end
```

# InplaceArrays.jl

Documentation for InplaceArrays.jl

## The Functor interface

Often, it is needed to implement functions that need some scratch data (e.g.,
pre-allocating the output). The question is, *where to store this data?* There are three
main answers to this question: 1) store the data in the function object as part of its
state, 2) allocate the scratch data each time the operation is performed, and 3)
the user allocates and passes the scratch data when needed. Clearly, 1) it is
not save if several calls to the operation are using the same scratch data
(e.g., multi-threading). 2) is save, but it can be inefficient if the operation
is performed at low granularity. 3) is both save and efficient, but requires
some extra work by the user.

In Gridap, we adopt the 3rd option. In order to unify the interfaces of functions
using this approach, we introduce the *Functor interface*. Any type is
referred to as a *Functor* if it implements the following interface. We rely in
duck typing here. There is not an abstract type representing a functor.

```@docs
InplaceArrays.Functors.evaluate_functor!
InplaceArrays.Functors.functor_cache
```

## Default implementations

We provide some default (obvious) implementations of this interface so that `Function`,
`Number`, and `AbstractArray` objects behave like functors.

### Examples

Calling the `+` function via the functor interface.
```jldoctests
julia> cache = functor_cache(+,0,0)

julia> evaluate_functor!(cache,+,1,2)
3

julia> evaluate_functor!(cache,+,-1,10)
9
```

`Number` and `AbstractArray` objects behave like "constant" functors.

```jldoctests
julia> a = 2.0
2.0

julia> cache = functor_cache(a,0)

julia> evaluate_functor!(cache,a,1)
2.0

julia> evaluate_functor!(cache,a,2)
2.0

julia> evaluate_functor!(cache,a,3)
2.0
```

## Evaluating a functor without cache

```@docs
InplaceArrays.Functors.evaluate_functor
```

## Working with several functors at once
```@docs
evaluate_functors!
functor_caches
```

## Broadcasting

```@docs
bcast
```

## Composition

```@docs
compose_functors
```
## Extended AbstractArray interface

When implementing new array types, we encounter a similar problem than when implementing some functions
: It can be needed some scratch data (e.g., allocating the output),
when recovering an item from an array (typically if the array elements are mutable or non-isbits objects, e.g., for "lazy" array of arrays). Here, we adopt the same solution as for functors: the user provides the scratch data. However, the Julia array interface does not support this approach. When calling `a[i]`, in order to get the element with index `i` in array `a`, there is no extra argument for
the scratch data. In order to circumvent this problem, we add new methods to the `AbstractArray` interface of Julia. We provide default implementations to the new methods, so that any `AbstractArray` can be used with the extended interface. The most important among the new methods is [`getindex!`](@ref), which allows to recover an item in the array by passing some scratch data. The new mehtods are listed below.

```@docs
getindex!
array_cache
uses_hash
testitem
testvalue
```



