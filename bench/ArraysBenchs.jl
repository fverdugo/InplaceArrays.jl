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
  c = data_array_apply(-,a)
  cache = array_cache(c)
  loop(c,cache)
end

function bench2(n)
  a = rand(n)
  b = rand(n)
  c = data_array_apply(-,a,b)
  cache = array_cache(c)
  loop(c,cache)
end

function bench3(n)
  a = fill(rand(2,3),n)
  b = rand(n)
  c = data_array_apply(bcast(-),a,b)
  cache = array_cache(c)
  loop(c,cache)
end

for n in (1,1,10,1000,100000)
  @eval begin
    println("+++ runing suite for n = $($n) +++")
    run(bench1,$n)
    run(bench2,$n)
    run(bench3,$n)
  end
end

end # module
