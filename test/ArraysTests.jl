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

#import InplaceArrays: evaluate_functor_elemwise
#import InplaceArrays: getindex!
#import InplaceArrays: array_cache
#
#"""
#All functors in f can share cache
#"""
#function evaluate_functor_elemwise(f::AbstractArray,a::AbstractArray)
#end
#
#function array_cache(a::)
#  if length(a) > 0
#    cf = array_cache(a.f)
#    fi = getindex!(cf,a.f,1)
#    cas = functor_caches(a.array_functors,1)
#    ais = evaluate_functors!(cas,a.array_functors,i...)
#    cr = functor_cache(fi,ais...)
#    (df,cas,cr)
#  else
#    nothing
#  end
#end
#
#function getindex!(cache,a::,i...)
#  cf, cas, cr = cache
#  fi = getindex!(cf,a.f,i...)
#  ais = evaluate_functors!(cas,a.array_functors,i...)
#  ri = evaluate_functor!(cr,fi,ais...)
#end
#
#

end # module
