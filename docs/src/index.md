```@meta
DocTestSetup = quote
    using InplaceArrays
end
```

# InplaceArrays.jl

Documentation for InplaceArrays.jl

## The Functor interface

Often, it is needed to implement types that need some scratch data (e.g.,
pre-allocating the output) to perform
some operation. The question is, *where to store this data?* There are three
main answers to this question: 1) store the data in the type as part of its
state, 2) allocate the scratch data each time the operation is performed, and 3)
the user allocates and passes the scratch data when needed. Clearly, 1) it is
not save if several calls to the operation are using the same scratch data
(e.g., multi-threading). 2) is save, but it can be inefficient if the operation
is performed at low granularity. 3) is both save and efficient, but requires
some extra work by the user.

In Gridap, we adopt the 3rd option. In order to unify the interfaces of objects
using this approach, we introduce the *Functor interface*. Any type is
referred to as a *Functor* if it implements the following interface. We rely in
duck typing.

```@docs
InplaceArrays.Functors.evaluate_functor!
InplaceArrays.Functors.functor_cache
```


## Default implementations

We provide some default implementations of this interface so that `Function`,
`Number`, and `AbstractArray` objects behave like functors.

### Examples

Calling the `+` function via the functor interface.
```jldoctests
julia> cache = functor_cache(+,0,0)

julia> evaluate_functor!(cache,+,1,2)
3

julia> r = evaluate_functor!(cache,+,-1,10)
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

The [`evaluate_functor`](@ref) function can be used in order to evaluate a functor without explicitly building a cache object.
```@docs
InplaceArrays.Functors.evaluate_functor
```

## Broadcasting

```@docs
bcast
```

## Composition

```@docs
apply_functor
```




