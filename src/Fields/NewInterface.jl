"""
    const Point{D,T} = VectorValue{D,T}

Type representing a point of D dimensions with coordinates of type T
"""
const Point{D,T} = VectorValue{D,T}

abstract type Field end

function field_cache(f::Field,x::Point)
  @abstractmethod
end

function evaluate!(f::Field,x::Point)
  @abstractmethod
end

function gradient(f::Field)
  @abstractmethod
end
