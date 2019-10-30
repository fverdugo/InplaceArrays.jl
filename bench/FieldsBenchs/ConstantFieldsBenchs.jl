module ConstantFieldsBenchs

using InplaceArrays.Arrays
using InplaceArrays.Fields

@inline function repeat(n,f,args...)
  for i in 1:n
    f(args...)
  end
  nothing
end

function bench1(n)
  d = 2
  v = 3.0
  f = v
  xi = Point(2,1)
  np = 4
  x = fill(xi,np)
  cf = field_cache(f,x)
  @time repeat(n,evaluate_field!,cf,f,x)
end

for n in (1,1,10,1000,100000)
  @eval begin
    println("+++ runing suite for n = $($n) +++")
    bench1($n)
  end
end

end # module
