module FunctorsBenchs

using InplaceArrays

@inline function repeat(n,f,args...)
  for i in 1:n
    f(args...)
  end
  nothing
end

function bench1(n)
  a = 1
  b = 2
  cache = functor_cache(+,a,b)
  @time repeat(n,evaluate_functor!,cache,+,a,b)
end

function bench2(n)
  f = bcast(+)
  a = rand(3,2)
  b = 3
  cache = functor_cache(f,a,b)
  @time repeat(n,evaluate_functor!,cache,f,a,b)
end

function bench3(n)
  f = functor_apply(-,+)
  a = 2
  b = 3
  cache = functor_cache(f,a,b)
  @time repeat(n,evaluate_functor!,cache,f,a,b)
end

function bench4(n)
  f = functor_apply(bcast(-),bcast(+))
  a = rand(3,2)
  b = 3
  cache = functor_cache(f,a,b)
  @time repeat(n,evaluate_functor!,cache,f,a,b)
end

function bench5(n)
  f = functor_apply(bcast(-),bcast(*),bcast(+))
  a = rand(3,2)
  b = 3
  cache = functor_cache(f,a,b)
  @time repeat(n,evaluate_functor!,cache,f,a,b)
end

function bench6(n)
  a = rand(2,3)
  f = functor_apply(bcast(+),bcast(-),a)
  b = 3
  c = rand(1,3)
  cache = functor_cache(f,b,c)
  @time repeat(n,evaluate_functor!,cache,f,b,c)
end

function bench7(n)
  a = rand(2,3)
  b = 4
  f = functor_apply(bcast(-),a,b)
  cache = functor_cache(f)
  @time repeat(n,evaluate_functor!,cache,f)
end

function bench8(n)
  C = bcast(+)
  D = rand(2,3)
  B = functor_apply(bcast(-),C,D)
  A = functor_apply(bcast(*),B,C)
  x = rand(2,3)
  y = 3
  cache = functor_cache(A,x,y)
  @time repeat(n,evaluate_functor!,cache,A,x,y)
end

function bench9(n)
  a = 1
  b = 2
  cache = functor_cache(typedfun(Int,+),a,b)
  @time repeat(n,evaluate_functor!,cache,+,a,b)
end

function bench10(n)
  f = bcast(Float64,2,+)
  a = rand(3,2)
  b = 3
  cache = functor_cache(f,a,b)
  @time repeat(n,evaluate_functor!,cache,f,a,b)
end

for n in (1,1,10,1000,100000)
  @eval begin
    println("+++ runing suite for n = $($n) +++")
    bench1($n)
    bench2($n)
    bench3($n)
    bench4($n)
    bench5($n)
    bench6($n)
    bench7($n)
    bench8($n)
    bench9($n)
    bench10($n)
  end
end

end # module
