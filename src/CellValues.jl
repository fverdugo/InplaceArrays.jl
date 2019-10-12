module CellValues

export CellValue

"""
    abstract type CellValue{T}

Abstract type representing a collection of values of type `T`
associated with the objects (e.g, cells, but also facets, edges, etc.) of a FE mesh.

A `CellValue` has to be understood as an array plus (possibly) some extra metatada,
e.g., the underlying mesh, fe space, information about the current field in multi-field
FE computations etc. The simplest version of `CellValue`, namely [`PlainCellValue`](@ref),
has no metadata.

All concrete types extending `CellValue` are assumed to have a field named `array`
that contains an instance of `AbstractArray{T}` representing the collection of values
in the `CellValue` object.

Concrete implementations of `CellValue` do not need to be type stable. In particular, the type of the
`array` field does not need to be included as a type parameter in the corresponding `CellValue` concrete
type. This allows to pass `CellValue` objects around without polluting the stack trace if an error occurs.
However, the object stored in the `array` field has to be type stable. This allows to access
items in `CellValue` objects efficiently via the `array` field (within a function barrier).
"""
abstract type CellValue{T} end

end # module
