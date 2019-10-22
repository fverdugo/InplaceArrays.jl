
```@meta
CurrentModule = InplaceArrays.Arrays
```
# Arrays

```@docs
Arrays
```

## Extended AbstractArray interface

New methods added:
- [`getindex!(cache,a::AbstractArray,i...)`](@ref)
- [`array_cache(a::AbstractArray)`](@ref)
- [`uses_hash(::Type{<:AbstractArray})`](@ref)
- [`testitem(a::AbstractArray)`](@ref)

The interface can be tested with the following function
- [`test_array`](@ref)

```@docs
getindex!(cache,a::AbstractArray,i...)
array_cache(a::AbstractArray)
uses_hash(::Type{<:AbstractArray})
testitem(a::AbstractArray)
test_array
```

## Useful array implementations

```@docs
CachedArray
```
