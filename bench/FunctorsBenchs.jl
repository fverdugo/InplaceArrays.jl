include("../src/Functors.jl")
function run(f,n)
  @time f(n)
end

function repeat(n,f,args...)
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

run(bench1,1)
run(bench2,1)
run(bench3,1)
run(bench4,1)

run(bench1,10)
run(bench2,10)
run(bench3,10)
run(bench4,10)

run(bench1,10000)
run(bench2,10000)
run(bench3,10000)
run(bench4,10000)




