
# Extended AbstractArray interface

When implementing new array types, we encounter a similar problem than when implementing some functions:
It can be needed some scratch data (e.g., allocating the output),
when recovering an item from an array (typically if the array elements are mutable or non-isbits objects, e.g., for "lazy" array of arrays). Here, we adopt the same solution as for functors: the user provides the scratch data. However, the Julia array interface does not support this approach. When calling `a[i]`, in order to get the element with index `i` in array `a`, there is no extra argument for
the scratch data. In order to circumvent this problem, we add new methods to the `AbstractArray` interface of Julia. We provide default implementations to the new methods, so that any `AbstractArray` can be used with the extended interface. The most important among the new methods is [`getindex!`](@ref), which allows to recover an item in the array by passing some scratch data. The new mehtods are listed below.

## New functions

The functions added to the `AbstractArray` interface are:
- [`getindex!`](@ref)
- [`array_cache`](@ref)
- [`uses_hash`](@ref)
- [`testitem`](@ref)

The new methods can be tested with the these functions:
- [`test_array`](@ref)
- [`test_array_of_functors`](@ref)

```@docs
getindex!
array_cache
uses_hash
testitem
test_array
test_array_of_functors
```

## Working with several arrays

```@docs
testitems
```

## Creating lazy operation trees

```@docs
evaluate_array_of_functors(f::AbstractArray,a::AbstractArray...)
evaluate_array_of_functors(f,a::AbstractArray...)
```

