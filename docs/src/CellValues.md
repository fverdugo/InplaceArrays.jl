
# The CellValue interface

```@docs
CellValue
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

## Creating lazy operation trees

```@docs
apply
```

## CellValue objects holding numeric data

```@docs
CellNumber
CellArray
CellData
```

The arithmetic operations `+`, `-`, `*` are overloaded for
`CellNumber`, `CellArray`, and `CellData` objects.

