module ConstantFieldsBenchs

using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.Fields: ConstantField

@inline function repeat(n,f,args...)
  for i in 1:n
    f(args...)
  end
  nothing
end

@noinline function genloop(n,::Val{d},v) where d
  for i in 1:n
    f = ConstantField{d}(v)
  end
  nothing
end

function bench1(n)
  d = 2
  v = 3.0
  f = ConstantField{d}(v)
  xi = Point(2,1)
  np = 4
  x = fill(xi,np)
  cf = field_cache(f,x)
  @time repeat(n,evaluate!,cf,f,x)
end

function bench2(n)
  d = 2
  v = [1,2,3]
  f = ConstantField{d}(v)
  xi = Point(2,1)
  np = 4
  x = fill(xi,np)
  cf = field_cache(f,x)
  @time repeat(n,evaluate!,cf,f,x)
end

function bench3(n)
  d = 2
  v = [1,2,3]
  @time repeat(n,ConstantField{d},v)
  @time genloop(n,Val(d),v)
end

for n in (1,1,10,1000,100000)
  @eval begin
    println("+++ runing suite for n = $($n) +++")
    bench1($n)
    bench2($n)
    bench3($n)
  end
end

end # module
