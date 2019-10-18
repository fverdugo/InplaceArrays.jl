module CellValues

using FillArrays
using TensorValues
using InplaceArrays
using Printf

export CellValue
export PlainCellValue
export apply
export getarrays
export test_cell_value
import Base: +, -, *
export CellArray
export CellNumber
export CellData

# The CellValue interface

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

function test_cell_value(cv::CellValue,b::AbstractArray,cmp=(==))
  a = cv.array
  test_array(a,b,cmp)
end

# Constructors

"""
    CellValue(cv::CellValue,array::AbstractArray)

Creates a `CellValue` object from the array `array` and (possibly)
the metadata available in `cv`. By default, the metadata in `cv`
is discarded and a `PlainCellValue` is returned. However, concrete
implementations of the `CellValue` abstract type can overload this
constructor in order to generate a new `CellValue` object from the
given `array` and the metadata in `cv`.
"""
function CellValue(cv::CellValue,array::AbstractArray)
  CellValue(array)
end

"""
    CellValue(array::AbstractArray) -> PlainCellValue
    
Creates a `PlainCellValue` from the given array
"""
function CellValue(array::AbstractArray)
  PlainCellValue(array)
end

"""
    CellValue(value,len::Integer) -> PlainCellValue

Creates a "constant" `CellValue` object with value `value`
and length `len`.
"""
function CellValue(value,len::Integer)
  array = Fill(value,(len,))
  CellValue(array)
end

"""
    CellValue(value,shape::Integer...) -> PlainCellValue

Creates a "constant" `CellValue` object with value `value`
and length `prod(shape)`. The size of the generated array
is equal to `shape`.
"""
function CellValue(value,shape::Integer...)
  array = Fill(value,shape)
  PlainCellValue(array)
end

# Default concrete implementations

"""
    struct PlainCellValue{T} <: CellValue{T}
      array::AbstractArray{T}
    end
Concrete implementation of `CellValue` with no meta-data
"""
struct PlainCellValue{T} <: CellValue{T}
  array::AbstractArray{T}
end


# Working with several CellValue objects

"""
    getarrays(cvs::CellValue...) -> Tuple

Returns a tuple with the underlying arrays in the `Cellvalue` objects `cvs`.
"""
function getarrays(cv::CellValue,cvs::CellValue...)
  a = cv.array
  b = getarrays(cvs...)
  (a,b...)
end

function getarrays(cv::CellValue)
  a = cv.array
  (a,)
end

# Methods delegated to the underlying array

"""
    Base.length(cv::CellValue)

Returns the length of the underlying array
"""
function Base.length(cv::CellValue)
  length(cv.array)
end

# Pretty printing

function Base.show(io::IO,self::CellValue)
  _show(io,self.array)
end

function _show(io,a)
  for (i, ai) in enumerate(a)
    @printf(io,"%3d -> ",i)
    _printval(io,ai)
    println(io,"")
  end
end

function Base.show(io::IO,::MIME"text/plain",self::CellValue)
  if length(self) < 15
    show(io,self)
  else
    _show_short(io,self.array)
  end
end

function _show_short(io,a)
  for (i, ai) in enumerate(a)
    if i >= 16
      print(io,"... (total length $(length(a)))")
      break
    end
    @printf(io,"%3d -> ",i)
    _printval(io,ai)
    println(io,"")
  end
end

function _printval(io,x)
  print(io,"$x")
end

function _printval(io,v::AbstractVector)
  print(io, "[")
  for (i, vi) in enumerate(v)
    i > 1 && print(io, ", ")
    print(io, vi)
  end
  print(io, "]")
end

# CellValue types holding numeric data

"""
    const CellNumber = CellValue{T} where T<:Number

Any `CellValue{T}` type holding numbers of type `T`.
"""
const CellNumber = CellValue{T} where T<:Number

"""
    const CellArray = CellValue{T} where T<:AbstractArray{S,N} where {S,N}

Any `CellValue{T}` type holding arrays of type `T` in each entry.
"""
const CellArray = CellValue{T} where T<:AbstractArray{S,N} where {S,N}

"""
    const CellData = CellValue{T} where T<:Union{Number,AbstractArray}

Any `CellValue{T}` type holding numbers or arrays of type `T`.
"""
const CellData = CellValue{T} where T<:Union{Number,AbstractArray}

# Lazy operation trees

"""
    apply(f,cvs::CellValue...)

Returns a new `CellValue` object obtained by applying
the functor `f` to the entries of the given `CellValue` objects `cvs`.
"""
function apply(f,cvs::CellData...)
  arrs = getarrays(cvs...)
  r = evaluate_array_of_functors(f,arrs...)
  CellValue(r)
end

function apply(f,cv::CellData)
  arr = cv.array
  r = evaluate_array_of_functors(f,arr)
  CellValue(cv,r)
end

for op in (:+,:-,:*)
  @eval begin

    function ($op)(a::CellNumber)
      apply($op,a)
    end

    function ($op)(a::CellArray)
      apply(bcast($op),a)
    end

    function ($op)(a::CellNumber,b::CellNumber)
      apply($op,a,b)
    end

    function ($op)(a::CellArray,b::CellArray)
      apply(bcast($op),a,b)
    end

    function ($op)(a::CellData,b::CellData)
      apply(bcast($op),a,b)
    end

  end
end

end # module
