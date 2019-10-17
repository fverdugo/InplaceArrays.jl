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
    bench9($n)
    bench10($n)
  end
end

end # module
