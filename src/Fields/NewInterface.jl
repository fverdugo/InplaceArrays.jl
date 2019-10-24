"""
    const Point{D,T} = VectorValue{D,T}

Type representing a point of D dimensions with coordinates of type T
"""
const Point{D,T} = VectorValue{D,T}

abstract type Field end

function field_cache(f::Field,x::Point)
  @abstractmethod
end

function evaluate!(cache,f::Field,x::Point)
  @abstractmethod
end

function gradient(f::Field)
  @abstractmethod
end

# Default return type

function field_return_type(f::Field,x::Point)
  typeof(evaluate(f,x))
end

#Default vectorized versions

function field_cache(f::Field,x::AbstractVector{<:Point})
  xi = testitem(x)
  fi = evaluate(f,xi)
  si = size(fi)
  s = (si...,length(x))
  a = zeros(eltype(fi),s)
  ca = CachedArray(a)
  cfi = field_cache(f,xi)
  cis = CartesianIndices(fi)
  (ca,cfi,cis)
end

function evaluate!(cache,f::Field,x::AbstractVector{<:Point})
  ca, cfi, cis = cache
  s = (size(cis)...,length(x))
  setsize!(ca,s)
  for i in 1:length(x)
    xi = x[i]
    fi = evaluate!(cfi,f,xi)
    for ci in cis
      ca[ci,i] = fi[ci]
    end
  end
end

function field_return_type(f::Field,x::AbstractVector{<:Point})
  xi = testitem(x)
  Ti = field_return_type(f,xi)
  ca = CachedArray(eltype(Ti),ndims(Ti)+1)
  typeof(ca)
end

# Evaluation without cache

function evaluate(f::Field,x)
  cache = field_cache(f,x)
  evaluate!(cache,f,x)
end

# Implement kernel interface

function kernel_return_type(f::Field,x)
  field_return_type(f,x)
end

function kernel_cache(f::Field,x)
  field_cache(f,x)
end

@inline function apply_kernel!(cache,f::Field,x)
  evaluate!(cache,f,x)
end

# Testers

function test_field(
  f::Fiel,
  x::AbstractVector{<:Point},
  v::AbstractArray,cmp=(==);
  grad=nothing)

  w = evaluate(f,x)
  @test cmp(w,v)
  @test typeof(w) == field_return_type(f,x)
  test_kernel(f,(x,),v,cmp)

  t = true
  for i in 1:length(x)
    xi = x[i]
    fi = evaluate(f,xi)
    ti = cmp(fi,v[i])
    t = t && ti
    ti = (typeof(fi) == field_return_type(f,xi))
    t = t && ti
  end
  @test t

  if grad != nothing
    g = gradient(f)
    test_field(g,x,grad,cmp)
  end

end

# Result of applying a kernel to some fields

struct AppliedField{K,F} <: Field
  k::K
  f::F
  function AppliedField(k,f...)
    new{typeof(k),typeof(f)}(k,f)
  end
end

function field_return_type(f::AppliedField,x::Point)
  Ts = kernel_return_types(f.f,x)
  kernel_return_type(f.k, map(testvalue,Ts)...)
end

function field_cache(f::AppliedField,x::Point)
  cf = kernel_caches(f.f,x)
  fx = apply_kernels!(cf,f.f,x)
  ck = kernel_cache(f.k,fx...)
  (ck,cf)
end

@inline function evaluate!(cache,f::AppliedField,x::Point)
  ck, cf = cache
  fx = apply_kernels!(cf,f.f,x)
  apply_kernel!(ck,f.k,fx...)
end

function gradient(f::AppliedField)
  gradient(f.k,f.f...) # TODO each kernel implements its gradient
  #TODO it also will be necessary to implement gradient for numbers and arrays
end

## Option B
#function gradient(f::AppliedField)
#  ∇f = map(gradient,f.f) # TODO Define gradient for numbers and arrays
#  ∇k = gradient(f.k) #TODO define gradient for kernels returning a tuple of coefs, one for each arg
#  _lincom(∇k,∇f) #TODO here we assume that * by scalar and binary + is defined to the objects in ∇f
#end

