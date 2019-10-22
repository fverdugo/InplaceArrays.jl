
# Cell-wise physical fields

## Definitions

```@docs
CellFieldLike
CellField
CellBasis
CellPoints
```
## Cell-wise evaluation and gradient

```@docs
evaluate(cf::CellFieldLike,x::CellPoints)
gradient(cf::CellFieldLike)
```

## CellFieldLike objects without underlying array

In most cases, it is not necessary to iterate over the fields stored 
in a cell-wise field. One can implement concrete types of the `CellFieldLike`
type that do not have an underlying `array` object. In this cases, its enough to
overload functions:
- [`evaluate(cf::CellFieldLike,x::CellPoints)`](@ref)
- [`gradient(cf::CellFieldLike)`](@ref)

## Lazy operation trees

```@docs
apply(g,f::CellFieldLikeOrData...)
```

## Testers

```@docs
test_cell_field_like
test_cell_field_like_no_array
test_cell_field
test_cell_basis
test_cell_field_like_with_gradient
test_cell_field_like_with_gradient_no_array
test_cell_field_with_gradient
test_cell_basis_with_gradient
```

