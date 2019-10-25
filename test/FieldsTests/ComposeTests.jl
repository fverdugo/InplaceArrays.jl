module ComposeTests

using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.Fields: MockField
using TensorValues

using InplaceArrays.Arrays: Elem
import InplaceArrays.Arrays: kernel_cache
import InplaceArrays.Arrays: apply_kernel!
import InplaceArrays.Arrays: kernel_return_type
import InplaceArrays.Fields: gradient

#TODO test all possible combinations
const NumberOrArray = Union{Number,AbstractArray}

@inline function apply_kernel!(cache,k::Elem,x::NumberOrArray...)
  b = bcast(k.f)
  apply_kernel!(cache,b,x...)
end

function kernel_cache(k::Elem,x::NumberOrArray...)
  b = bcast(k.f)
  kernel_cache(b,x...)
end

function kernel_return_type(k::Elem,x::NumberOrArray...)
  b = bcast(k.f)
  kernel_return_type(b,x...)
end


import InplaceArrays.Fields: ∇

function compose(g::Function,f...)
  k = Comp(g)
  apply_kernel_to_field(k,f...)
end

struct Comp{F}
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



np = 4
p = Point(1,2)
x = fill(p,np)

fun(x,y) = 2*x
∇fun(x,y) = VectorValue(2*one(x[1]),2*one(x[1]))
∇(::typeof(fun)) = ∇fun

v = 3.0
d = 2
f = MockField(d,v)
fx = fill(v,np)

k = Comp(fun)
test_kernel(k,(v,v),2*v)

g = compose(fun,f,f)
gx = 2*fx
∇gx = fill(∇fun(v,v),np)
test_field(g,x,gx,grad=∇gx)

end # module
