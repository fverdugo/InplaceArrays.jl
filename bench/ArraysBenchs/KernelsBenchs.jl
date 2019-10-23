module KernelsBenchs

using InplaceArrays.Arrays

@inline function repeat(n,f,args...)
  for i in 1:n
    f(args...)
  end
  nothing
end

function bench1(n)
  a = 1
  b = 2
  cache = kernel_cache(+,a,b)
  @time repeat(n,apply_kernel!,cache,+,a,b)
end

function bench2(n)
  f = bcast(+)
  a = rand(3,2)
  b = 3
  cache = kernel_cache(f,a,b)
  @time repeat(n,apply_kernel!,cache,f,a,b)
end

for n in (1,1,10,1000,100000)
  @eval begin
    println("+++ runing suite for n = $($n) +++")
    bench1($n)
    bench2($n)
  end
end

end # module
