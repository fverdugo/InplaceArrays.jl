
"""
    lincomb(a::Basis,b::AbstractVector)

Returns a field `f` with `valuetype(f) <: Number` obtained by the "linear combination" of
the value of the basis `a` and the vector `b`. That is, the value of the resulting field `f`
at a point `x` is defined as

    k = contract(outer)
    ax = evaluate(a,x)
    apply_kernel(k,ax,b)

On the other hand, the gradient of the resulting field is defined as

    k = contract(outer)
    ∇ax = evaluate(gradient(a),x)
    apply_kernel(k,∇ax,b)

"""
function lincomb(a::Field,b::AbstractVector)
  LinComField(a,b)
end

struct LinCom <: Kernel end

function kernel_cache(k::LinCom,a,b)
  _lincomb_checks(a,b)
  Ta = eltype(a)
  Tb = eltype(b)
  T = return_type(outer,Ta,Tb)
  np = length(b)
  r = zeros(T,np)
  CachedArray(r)
end

function _lincomb_checks(a,b)
  nb = length(b)
  np, na = size(a)
  s = "lincom: Number of fields in basis needs to be equal to number of coefs."
  @assert nb == na s
end

@inline function apply_kernel!(r,k::LinCom,a,b)
  _lincomb_checks(a,b)
  np, nf = size(a)
  setsize!(r,(np,))
  z = zero(eltype(r))
  for i in 1:np
    @inbounds r[i] = z
    for j in 1:nf
      @inbounds r[i] += outer(a[i,j],b[j])
    end
  end
  r
end

struct LinComField{A,B} <: Field
  basis::A
  coefs::B
  @inline function LinComField(basis,coefs) 
    A = typeof(basis)
    B = typeof(coefs)
    new{A,B}(basis,coefs)
  end
end

function field_cache(f::LinComField,x)
  ca = field_cache(f.basis,x)
  a = evaluate_field!(ca,f.basis,x)
  b = f.coefs
  k = LinCom()
  ck = kernel_cache(k,a,b)
  (ca,ck)
end

@inline function evaluate_field!(cache,f::LinComField,x)
  ca, ck = cache
  a = evaluate_field!(ca,f.basis,x)
  b = f.coefs
  k = LinCom()
  apply_kernel!(ck,k,a,b)
end

function field_gradient(f::LinComField)
  g = field_gradient(f.basis)
  LinComField(g,f.coefs)
end

struct LinComValued <: Kernel end

@inline function apply_kernel!(::Nothing,k::LinComValued,a,b)
  LinComField(a,b)
end

function apply_gradient(k::LinComValued,a,b)
  g = gradient(a)
  lincomb(g,b)
end

function kernel_evaluate(k::LinComValued,x,a,b)
  ax = evaluate(a,x)
  k = LinCom()
  apply(k,ax,b)
end

"""
    lincomb(a::AbstractArray{<:Field},b::AbstractArray)

Returns an array of field numerically equivalent to

    map(lincomb,a,b)
"""
function lincomb(a::AbstractArray,b::AbstractArray)
  k = LinComValued()
  apply(k,a,b)
end


