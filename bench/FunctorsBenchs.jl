module FunctorsBenchs

using InplaceArrays
#using Test
#include("../src/Functors.jl")

function run(f,n)
  @time f(n)
end

@inline function repeat(n,f,args...)
  for i in 1:n
    f(args...)
  end
  nothing
end

function bench1(n)
  a = 1
  b = 2
  cache = new_cache(+,a,b)
  repeat(n,evaluate!,cache,+,a,b)
end

function bench2(n)
  f = bcast(+)
  a = rand(3,2)
  b = 3
  cache = new_cache(f,a,b)
  repeat(n,evaluate!,cache,f,a,b)
end

function bench3(n)
  f = apply(-,+)
  a = 2
  b = 3
  cache = new_cache(f,a,b)
  repeat(n,evaluate!,cache,f,a,b)
end

function bench4(n)
  f = apply(bcast(-),bcast(+))
  a = rand(3,2)
  b = 3
  cache = new_cache(f,a,b)
  repeat(n,evaluate!,cache,f,a,b)
end

function bench5(n)
  f = apply(bcast(-),bcast(*),bcast(+))
  a = rand(3,2)
  b = 3
  cache = new_cache(f,a,b)
  repeat(n,evaluate!,cache,f,a,b)
end

function bench6(n)
  a = rand(2,3)
  f = apply(bcast(+),bcast(-),a)
  b = 3
  c = rand(1,3)
  cache = new_cache(f,b,c)
  repeat(n,evaluate!,cache,f,b,c)
end

function bench7(n)
  a = rand(2,3)
  b = 4
  f = apply(bcast(-),a,b)
  cache = new_cache(f)
  repeat(n,evaluate!,cache,f)
end

function bench8(n)
  C = bcast(+)
  D = rand(2,3)
  B = apply(bcast(-),C,D)
  A = apply(bcast(*),B,C)
  x = rand(2,3)
  y = 3
  cache = new_cache(A,x,y)
  repeat(n,evaluate!,cache,A,x,y)
end

for n in (1,1,10,1000,100000)
  @eval begin
    println("+++ runing suite for n = $($n) +++")
    run(bench1,$n)
    run(bench2,$n)
    run(bench3,$n)
    run(bench4,$n)
    run(bench5,$n)
    run(bench6,$n)
    run(bench7,$n)
    run(bench8,$n)
  end
end

end # module
