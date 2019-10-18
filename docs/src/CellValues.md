
# The CellValue interface

```@docs
CellValue
test_cell_value
```

## Constructors

```@docs
CellValue(cv::CellValue,array::AbstractArray)
CellValue(array::AbstractArray)
CellValue(value,len::Integer)
CellValue(value,shape::Integer...)
```

## Methods delegated to the underlying array

```@docs
Base.length(cv::CellValue)
```

## Default concrete implementations

```@docs
PlainCellValue
```

## Working with several CellValue objects

```@docs
getarrays
```
## CellValue objects holding numeric data

```@docs
CellNumber
CellArray
CellData
```
## Creating lazy operation trees

```@docs
apply(f,cvs::CellData...)
```
The following (lazy) arithmetic operations are defined for `CellData` objects. When `CellArrays` are involved, the operations are done in broadcast form in the inner arrays.

- `+`
- `-`
- `*`

