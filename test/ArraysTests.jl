module ArraysTests

using Test
using InplaceArrays
using FillArrays

a = rand(3,2,4)
test_array(a,a)

a = rand(3,2,4)
a = CartesianIndices(a)
test_array(a,a)

a = rand(3,2)
a = CartesianIndices(a)
c = evaluate_array_of_functors(-,a)
test_array(c,-a)

a = rand(12)
c = evaluate_array_of_functors(-,a)
test_array(c,-a)

a = rand(12)
b = rand(12)
c = evaluate_array_of_functors(-,a,b)
test_array(c,a.-b)

a = rand(0)
b = rand(0)
c = evaluate_array_of_functors(-,a,b)
test_array(c,a.-b)

a = fill(rand(2,3),12)
b = rand(12)
c = evaluate_array_of_functors(bcast(-),a,b)
test_array(c,[ai.-bi for (ai,bi) in zip(a,b)])

a = fill(rand(2,3),0)
b = rand(0)
c = evaluate_array_of_functors(bcast(-),a,b)
test_array(c,[ai.-bi for (ai,bi) in zip(a,b)])

a = fill(rand(2,3),12)
b = rand(12)
c = evaluate_array_of_functors(bcast(-),a,b)
d = evaluate_array_of_functors(bcast(+),a,c)
e = evaluate_array_of_functors(bcast(*),d,c)
test_array(e,[((ai.-bi).+ai).*(ai.-bi) for (ai,bi) in zip(a,b)])

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
x = rand(10)
y = rand(10)
v = evaluate_array_of_functors(a,x,y)
r = [(xi+yi) for (xi,yi) in zip(x,y)]
test_array(v,r)

a = Fill(bcast(+),10)
x = [rand(2,3) for i in 1:10]
y = [rand(1,3) for i in 1:10]
v = evaluate_array_of_functors(a,x,y)
r = [(xi.+yi) for (xi,yi) in zip(x,y)]
test_array(v,r)

a = Fill(bcast(+),10)
x = [rand(mod(i-1,3)+1,3) for i in 1:10]
y = [rand(1,3) for i in 1:10]
v = evaluate_array_of_functors(a,x,y)
r = [(xi.+yi) for (xi,yi) in zip(x,y)]
test_array(v,r)

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
c = evaluate_array_of_functors(bcast(-),a,b)
d = evaluate_array_of_functors(bcast(+),a,c)
e = evaluate_array_of_functors(bcast(*),d,c)
r = [ (ai.-bi).*(ai.+(ai.-bi)) for (ai,bi) in zip(a,b)]
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

end # module
