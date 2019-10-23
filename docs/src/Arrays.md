
```@meta
CurrentModule = InplaceArrays.Arrays
```
# Gridap.Arrays

```@docs
Arrays
```

## Extended AbstractArray interface

New methods added that can be overload by new types:
- [`getindex!(cache,a::AbstractArray,i...)`](@ref)
- [`array_cache(a::AbstractArray)`](@ref)
- [`uses_hash(::Type{<:AbstractArray})`](@ref)
- [`testitem(a::AbstractArray)`](@ref)

The interface can be tested with the following function
- [`test_array`](@ref)

```@docs
getindex!(cache,a::AbstractArray,i...)
getitems!
array_cache(a::AbstractArray)
array_caches
uses_hash(::Type{<:AbstractArray})
testitem(a::AbstractArray)
testitems
test_array
```

## Creting lazy operation trees

```@docs
apply(f,a::AbstractArray...)
apply(f::AbstractArray,a::AbstractArray...)
```

### Operation kernels

The [`apply`](@ref) function provides a mechanism to construct lazy arrays
obtained by applying some operations to other arrays. The operations are
represented by objects (referred to as *kernels*). We rely in duck typing here.
There is not an abstract type representing a kernel. Any type is
referred to as a *kernel* if it implements the following interface:

- [`apply_kernel!(cache,k,x...)`](@ref)
- [`kernel_cache(k,x...)`](@ref)
- [`kernel_return_type(k,Ts::Type...)`](@ref)

The kernel interface can be tested with the [`test_kernel`](@ref) function.

We provide some default (obvious) implementations of this interface so that `Function`,
`Number`, and `AbstractArray` objects behave like kernels.

```jldoctests
julia> using InplaceArrays.Arrays

julia> cache = kernel_cache(+,0,0)

julia> apply_kernel!(cache,+,1,2)
3

julia> apply_kernel!(cache,+,-1,10)
9
```

`Number` and `AbstractArray` objects behave like "constant" kernels.

```jldoctests
julia> using InplaceArrays.Arrays

julia> a = 2.0
2.0

julia> cache = kernel_cache(a,0)

julia> apply_kernel!(cache,a,1)
2.0

julia> apply_kernel!(cache,a,2)
2.0

julia> apply_kernel!(cache,a,3)
2.0
```

```@docs
apply_kernel!
kernel_cache
kernel_return_type
test_kernel
```

### Build-in kernels

```@docs
bcast
```

### Other functions acting on kernels

```@docs
apply_kernel
apply_kernels!
kernel_caches
kernel_return_types
```

## Concrete array implementations

### CachedArray

```@docs
CachedArray
CachedArray(a::AbstractArray)
CachedArray(T,N)
setsize!
CachedMatrix
CachedVector
```
