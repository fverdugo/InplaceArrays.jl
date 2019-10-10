module ArraysTests

using Test
using InplaceArrays
using FillArrays

a = rand(3,2,4)
test_inplace_array(a,a)

a = rand(3,2,4)
a = CartesianIndices(a)
test_inplace_array(a,a)

a = rand(3,2)
a = CartesianIndices(a)
c = evaluate_functor_with_array(-,a)
test_inplace_array(c,-a)

a = rand(12)
c = evaluate_functor_with_array(-,a)
test_inplace_array(c,-a)

a = rand(12)
b = rand(12)
c = evaluate_functor_with_array(-,a,b)
test_inplace_array(c,a.-b)

a = rand(0)
b = rand(0)
c = evaluate_functor_with_array(-,a,b)
test_inplace_array(c,a.-b)

a = fill(rand(2,3),12)
b = rand(12)
c = evaluate_functor_with_array(bcast(-),a,b)
test_inplace_array(c,[ai.-bi for (ai,bi) in zip(a,b)])

a = fill(rand(2,3),0)
b = rand(0)
c = evaluate_functor_with_array(bcast(-),a,b)
test_inplace_array(c,[ai.-bi for (ai,bi) in zip(a,b)])

a = fill(rand(2,3),12)
b = rand(12)
c = evaluate_functor_with_array(bcast(-),a,b)
d = evaluate_functor_with_array(bcast(+),a,c)
e = evaluate_functor_with_array(bcast(*),d,c)
test_inplace_array(e,[((ai.-bi).+ai).*(ai.-bi) for (ai,bi) in zip(a,b)])

a = fill(rand(Int,2,3),12)
b = fill(rand(Int,1,3),12)
c = array_caches(a,b)
i = 1
v = getitems!(c,(a,b),i)
@test c == (nothing,nothing)
@test v == (a[i],b[i])

a = fill(rand(Int,2,3),12)
b = fill(rand(Int,1,3),12)
ai = testitem(a)
@test ai == a[1]
ai, bi = testitems(a,b)
@test ai == a[1]
@test bi == b[1]

a = fill(rand(Int,2,3),0)
b = fill(1,0)
ai = testitem(a)
@test ai == Array{Int,2}(undef,0,0)
ai, bi = testitems(a,b)
@test ai == Array{Int,2}(undef,0,0)
@test bi == zero(Int)

a = fill(+,10)
b = fill(-,10)
c = compose_functor_with_array(*,a,b)
d = fill(compose_functors(*,+,-),10)
test_inplace_array(c,d)
x = rand(10)
y = rand(10)
r = [(xi+yi)*(xi-yi) for (xi,yi) in zip(x,y)]
test_inplace_array_of_functors(c,(x,y),r)
v = evaluate_array_of_functors(c,x,y)
test_inplace_array(v,r)

a = fill(bcast(+),10)
b = fill(bcast(-),10)
c = compose_functor_with_array(bcast(*),a,b)
d = fill(compose_functors(bcast(*),bcast(+),bcast(-)),10)
test_inplace_array(c,d)
x = [rand(2,3) for i in 1:10]
y = [rand(1,3) for i in 1:10]
r = [(xi.+yi).*(xi.-yi) for (xi,yi) in zip(x,y)]
test_inplace_array_of_functors(c,(x,y),r)

a = fill(+,10)
x = rand(10)
y = rand(10)
v = evaluate_array_of_functors(a,x,y)
r = [(xi+yi) for (xi,yi) in zip(x,y)]
test_inplace_array(v,r)

a = Fill(bcast(+),10)
x = [rand(2,3) for i in 1:10]
y = [rand(1,3) for i in 1:10]
v = evaluate_array_of_functors(a,x,y)
r = [(xi.+yi) for (xi,yi) in zip(x,y)]
test_inplace_array(v,r)

a = Fill(bcast(+),10)
x = [rand(mod(i-1,3)+1,3) for i in 1:10]
y = [rand(1,3) for i in 1:10]
v = evaluate_array_of_functors(a,x,y)
r = [(xi.+yi) for (xi,yi) in zip(x,y)]
test_inplace_array(v,r)

# Test the intermediate results caching mechanism

struct ArrayWithCounter{T,N,A,C} <: AbstractArray{T,N}
  array::A
  counter::C
  function ArrayWithCounter(a::AbstractArray{T,N}) where {T,N}
    c = zeros(Int,size(a))
    c[:] .= 0
    new{T,N,typeof(a),typeof(c)}(a,c)
  end
end

Base.size(a::ArrayWithCounter) = size(a.array)

function Base.getindex(a::ArrayWithCounter,i::Integer...)
  a.counter[i...] += 1
  a.array[i...]
end

Base.IndexStyle(::Type{<:ArrayWithCounter{T,N,A}}) where {T,A,N} = IndexStyle(A)

function reset_counter!(a::ArrayWithCounter)
  a.counter[:] .= 0
end

a = ArrayWithCounter(fill(rand(2,3),12))
b = ArrayWithCounter(rand(12))
c = evaluate_functor_with_array(bcast(-),a,b)
d = evaluate_functor_with_array(bcast(+),a,c)
e = evaluate_functor_with_array(bcast(*),d,c)
cache = array_cache(e)
reset_counter!(a)
reset_counter!(b)
for i in 1:length(e)
  ei = getindex!(cache,e,i)
  ei = getindex!(cache,e,i)
  ei = getindex!(cache,e,i)
end

@test all(a.counter .== 2) 
@test all(b.counter .== 1)

a = Fill(+,12)
b = ArrayWithCounter(fill(2,12))
c = compose_functor_with_array(-,a,b)
d = compose_functor_with_array(*,c,c)
x = fill(3,12)
r = evaluate_array_of_functors(d,x)

cr = array_cache(r)
reset_counter!(b)
for i in 1:length(b)
  ri = getindex!(cr,r,i)
end
@test all(b.counter .== 1)


end # module
