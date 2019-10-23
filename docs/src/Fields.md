```@meta
CurrentModule = InplaceArrays.Fields
```
# Gridap.Fields

```@docs
Fields
```

## Interface

```@docs
FieldLike
Field
Basis
Point
evaluate!(cache,f::FieldLike,x)
field_cache(f::FieldLike)
gradient(::FieldLike)
∇(::FieldLike)
num_dofs(f::Basis)
test_field_like
test_field
test_basis
```
## Other functions using fields

```@docs
evaluate
valuetype
pointdim
gradtype
```

