
"""
    compose(g::Function,f...)
"""
function compose(g::Function,f...)
  k = Comp(g)
  apply_kernel_to_field(k,f...)
end

struct Comp{F} <: Kernel
  e::Elem{F}
  @inline Comp(f::Function) = new{typeof(f)}(Elem(f))
end

@inline apply_kernel!(cache,k::Comp,x...) = apply_kernel!(cache,k.e,x...)

kernel_cache(k::Comp,x...) = kernel_cache(k.e,x...)

kernel_return_type(k::Comp,x...) = kernel_return_type(k.e,x...)

function gradient(k::Comp,f...)
  g = gradient(k.e.f)
  compose(g,f...)
end

"""
    compose(g::Function,f::AbstractArray...)
"""
function compose(g::Function,f::AbstractArray...)
  k = Comp(g)
  apply_to_field(k,f...)
end

