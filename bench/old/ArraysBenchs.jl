module ArraysBenchs

using InplaceArrays
using FillArrays

@inline function loop(a,cache)
  for i in eachindex(a)
    ai = getindex!(cache,a,i)
  end
end

@inline function loop_and_evaluate(ca,cai,cx,a,x...)
  for i in eachindex(a)
    ai = getindex!(ca,a,i)
    xi = getitems!(cx,x,i...)
    vi = evaluate_functor!(cai,ai,xi...)
  end
end

function bench1(n)
  a = rand(n)
  c = evaluate_array_of_functors(-,a)
  cache = array_cache(c)
  @time loop(c,cache)
end

function bench2(n)
  a = rand(n)
  b = rand(n)
  c = evaluate_array_of_functors(-,a,b)
  cache = array_cache(c)
  @time loop(c,cache)
end

function bench3(n)
  a = fill(rand(2,3),n)
  b = rand(n)
  c = evaluate_array_of_functors(bcast(-),a,b)
  cache = array_cache(c)
  @time loop(c,cache)
end

function bench4(n)
  a = fill(rand(2,3),n)
  b = rand(n)
  c = evaluate_array_of_functors(bcast(-),a,b)
  d = evaluate_array_of_functors(bcast(+),a,c)
  e = evaluate_array_of_functors(bcast(*),d,c)
  cache = array_cache(e)
  @time loop(e,cache)
end

function bench7(n)
  a = fill(+,n)
  x = rand(n)
  y = rand(n)
  v = evaluate_array_of_functors(a,x,y)
  cache = array_cache(v)
  @time loop(v,cache)
end

function bench8(n)
  a = fill(bcast(+),n)
  x = [rand(2,3) for i in 1:n]
  y = [rand(1,3) for i in 1:n]
  v = evaluate_array_of_functors(a,x,y)
  cache = array_cache(v)
  @time loop(v,cache)
end

function bench9(n)
  a = Fill(bcast(+),n)
  x = [rand(mod(i-1,3)+1,3) for i in 1:n]
  y = [rand(1,3) for i in 1:n]
  v = evaluate_array_of_functors(a,x,y)
  cache = array_cache(v)
  @time loop(v,cache)
end

function bench10(n)
  a = fill(rand(2,3),n)
  b = rand(n)
  c = evaluate_array_of_functors(bcast(Float64,2,-),a,b)
  cache = array_cache(c)
  @time loop(c,cache)
end

for n in (1,1,10,1000,100000)
  @eval begin
    println("+++ runing suite for n = $($n) +++")
    bench1($n)
    bench2($n)
    bench3($n)
    bench4($n)
    bench7($n)
    bench8($n)
    bench9($n)
  end
end

end # module