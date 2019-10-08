module ArraysBenchs

using InplaceArrays

# TODO not repeat these functions
function run(f,n)
  @time f(n)
end

@inline function loop(a,cache)
  for i in eachindex(a)
    ai = getindex!(cache,a,i)
  end
end

function bench1(n)
  a = rand(n)
  c = evaluate_functor_elemwise(-,a)
  cache = array_cache(c)
  loop(c,cache)
end

function bench2(n)
  a = rand(n)
  b = rand(n)
  c = evaluate_functor_elemwise(-,a,b)
  cache = array_cache(c)
  loop(c,cache)
end

function bench3(n)
  a = fill(rand(2,3),n)
  b = rand(n)
  c = evaluate_functor_elemwise(bcast(-),a,b)
  cache = array_cache(c)
  loop(c,cache)
end

function bench4(n)
  a = fill(rand(2,3),n)
  b = rand(n)
  c = evaluate_functor_elemwise(bcast(-),a,b)
  d = evaluate_functor_elemwise(bcast(+),a,c)
  cache = array_cache(d)
  loop(d,cache)
end

for n in (1,1,10,1000,100000)
  @eval begin
    println("+++ runing suite for n = $($n) +++")
    run(bench1,$n)
    run(bench2,$n)
    run(bench3,$n)
    run(bench4,$n)
  end
end

end # module
