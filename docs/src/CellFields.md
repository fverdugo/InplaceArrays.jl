
# Cell-wise physical fields

## Definitions

```@docs
CellFieldLike
CellField
CellBasis
CellPoints
```
## API

```@docs
evaluate(cf::CellFieldLike,x::CellPoints)
gradient(cf::CellFieldLike)
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

