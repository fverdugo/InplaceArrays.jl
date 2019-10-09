module ArraysTests

using Test
using InplaceArrays

a = rand(3,2,4)
test_inplace_array(a,a)

a = CartesianIndices(a)
test_inplace_array(a,a)

a = rand(12)
c = evaluate_functor_elemwise(-,a)
test_inplace_array(c,-a)

a = rand(12)
b = rand(12)
c = evaluate_functor_elemwise(-,a,b)
test_inplace_array(c,a.-b)

a = rand(0)
b = rand(0)
c = evaluate_functor_elemwise(-,a,b)
test_inplace_array(c,a.-b)

a = fill(rand(2,3),12)
b = rand(12)
c = evaluate_functor_elemwise(bcast(-),a,b)
test_inplace_array(c,[ai.-bi for (ai,bi) in zip(a,b)])

a = fill(rand(2,3),0)
b = rand(0)
c = evaluate_functor_elemwise(bcast(-),a,b)
test_inplace_array(c,[ai.-bi for (ai,bi) in zip(a,b)])

a = fill(rand(2,3),12)
b = rand(12)
c = evaluate_functor_elemwise(bcast(-),a,b)
d = evaluate_functor_elemwise(bcast(+),a,c)
e = evaluate_functor_elemwise(bcast(*),d,c)
test_inplace_array(e,[((ai.-bi).+ai).*(ai.-bi) for (ai,bi) in zip(a,b)])

a = fill(rand(Int,2,3),12)
b = fill(rand(Int,1,3),12)
c = array_caches(a,b)
i = 1
v = getitems!(c,(a,b),i)
@test c == (nothing,nothing)
@test v == (a[i],b[i])

#function apply_functor_elemwise(g,f::AbstractArray...)
#  cf = array_caches(f...)
#  fis = getitems(cf,f...)
#
#  apply_functor(g,fis)
#
#end
#
#struct AppliedArray{T,N,I,A,F} <:AbstractArray{T,N}
#  size::NTuple{N,Int}
#  applied::T
#  f::F
#end
#
#function getitem!(cache,a::AppliedArray,i...)
#  cf, ca = cache
#  fis = getitems!(cf,a.f,i...)
#  _, _, inputs = ca
#  inputs.f = fis
#  a.applied
#end
#
#mutable struct AppliedInputs{F<:Tuple}
#  f::F
#  function AppliedInputs(f...)
#    new{typeof(f)}(f)
#  end
#end
#
#struct Applied{G,F<:Tuple}
#  g::G
#  f0::F
#  function Applied(g,f...)
#    new{typeof(g),typeof(f)}(g,f)
#  end
#end
#
#apply_functor(g,f...) = Applied(g,f...)
#
#function functor_cache(hash::Dict,f::Applied,x...)
#  cfs = functor_caches(hash,f.f0,x...)
#  fxs = evaluate_functors!(cfs,f.f0,x...)
#  cg = functor_cache(hash,f.g,fxs...)
#  inputs = AppliedInputs(f.f0...)
#  (cg,cfs,inputs)
#end
#
#@inline function evaluate_functor!(cache,f::Applied,x...)
#  cg, cfs, inputs = cache
#  fxs = evaluate_functors!(cfs,inputs.f,x...)
#  y = evaluate_functor!(cg,f.g,fxs...)
#  y
#end

end # module
