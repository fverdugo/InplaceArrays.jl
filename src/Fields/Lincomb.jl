
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
function lincomb(a::Basis,b::AbstractVector)
  k = LinCom()
  apply_kernel_to_field(k,a,b)
end

struct LinCom <: Kernel
  k::Contracted{typeof(outer)}
  @inline LinCom() = new(contract(outer))
end

@inline kernel_return_type(k::LinCom,a,b) = kernel_return_type(k.k,a,b)

@inline kernel_cache(k::LinCom,a,b) = kernel_cache(k.k,a,b)

@inline apply_kernel!(cache,k::LinCom,a,b) = apply_kernel!(cache,k.k,a,b)

@inline function gradient(k::LinCom,a::Field,b::ConstantField)
  g = gradient(a)
  apply_kernel_to_field(k,g,b)
end

"""
    lincomb(a::AbstractArray{<:Field},b::AbstractArray)

Returns an array of field numerically equivalent to

    map(lincomb,a,b)
"""
function lincomb(a::AbstractArray{<:Field},b::AbstractArray)
  k = LinCom()
  apply_to_field(k,a,b)
end



