```@meta
CurrentModule = InplaceArrays.Fields
```
# Gridap.Fields

```@docs
Fields
```

## Interface

```@docs
Field
Basis
Point
evaluate!(cache,f::Field,x::Point)
field_cache(f::Field,x::Point)
gradient(::Field)
∇(::Field)
field_return_type(f::Field,x::Point)
evaluate!(cache,f::Field,x::AbstractVector{<:Point})
field_cache(f::Field,x::AbstractVector{<:Point})
field_return_type(f::Field,x::AbstractVector{<:Point})
test_field
```
## Other functions using fields

```@docs
evaluate(f::Field,x)
valuetype(::Type{<:Field})
pointdim(::Type{<:Field})
compose(g::Function,f...)
lincomb(a::Basis,b::AbstractVector)
```

## Applying kernels to fields

```@docs
apply_kernel_to_field(k::Kernel,f::FieldNumberOrArray{D}...) where D
gradient(k::Kernel,f::Field...)
```

## Working with arrays of fields

```@docs
evaluate(::AbstractArray{<:Field},::AbstractArray)
gradient(::AbstractArray{<:Field})
apply_to_field(k::Kernel,f::AbstractArray...)
field_cache(::AbstractArray{<:Field},::AbstractArray)
compose(g::Function,f::AbstractArray...)
lincomb(a::AbstractArray{<:Field},b::AbstractArray)
test_array_of_fields
```


