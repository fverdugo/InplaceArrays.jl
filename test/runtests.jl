module Runtests

using Test
using InplaceArrays

a = collect(1:10)
b = InplaceArray(a)
test_inplace_array(b,a)

b[3] = -1
@test a[3] == -1
test_inplace_array(b,a)

a = rand(3,2,4)
b = InplaceArray(a)
test_inplace_array(b,a)

a = CartesianIndices(a)
b = InplaceArray(a)
test_inplace_array(b,a)

#import InplaceArrays: new_cache
#import InplaceArrays: getindex!
#
#struct InplaceArrayFromOp{T,N,A,F} <: InplaceArray{T,N}
#  f::F
#  data::A
#
#  function InplaceArrayFromOp(
#    f::Function,data::InplaceArray{T,N}) where {T,N}
#    F = typeof(f)
#    A = typeof(A)
#    new{T,N,A,F}(f,data)
#  end
#
#end
#
#function getindex!(cache,a::InplaceArrayFromOp,I::Integer...)
#  ai = getindex!(cache,a.data,I...)
#  a.f(ai)
#end
#j
#function getindex!(cache,a::InplaceArrayFromOp,I::Integer...)
#  ai, c = cache
#  di = getindex!(c,a.data,I...)
#  s = new_size(a.f,di)
#  resize!(ai,size(di)...)
#  a.f!(ai,di)
#  ai
#end
#
#new_cache(a::InplaceArrayFromOp) = new_cache(a.data)
#
#Base.size(a::InplaceArrayFromOp) = size(a.data)
#
#function Base.IndexStyle(
#  ::Type{InplaceArrayFromOp{T,N,A}}) where {T,N,A}
#  IndexStyle(A)
#end


end # module

