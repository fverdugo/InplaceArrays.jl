module FieldApplyBenchs

using InplaceArrays.Arrays
using InplaceArrays.Fields
using InplaceArrays.Fields: MockField, MockBasis

@inline function repeat(n,f,args...)
  for i in 1:n
    f(args...)
  end
  nothing
end

function bench1(n)
  np = 4
  p = Point(1,2)
  x = fill(p,np)
  v = 3.0
  d = 2
  f = MockField{d}(v)
  g = apply_kernel_to_field(elem(+),f,v)
  cg = field_cache(g,x)
  @time repeat(n,evaluate!,cg,g,x)
  ∇g = gradient(g)
  ∇cg = field_cache(∇g,x)
  @time repeat(n,evaluate!,∇cg,∇g,x)
  h = apply_kernel_to_field(elem(+),f,f)
  ch = field_cache(h,x)
  @time repeat(n,evaluate!,ch,h,x)
end

function bench2(n)
  np = 4
  p = Point(1,2)
  x = fill(p,np)
  v = 3.0
  d = 2
  ndof = 8
  f = MockBasis{d}(v,ndof)
  g = apply_kernel_to_field(elem(+),f,v)
  cg = field_cache(g,x)
  @time repeat(n,evaluate!,cg,g,x)
  ∇g = gradient(g)
  ∇cg = field_cache(∇g,x)
  @time repeat(n,evaluate!,∇cg,∇g,x)
  h = apply_kernel_to_field(elem(+),f,f)
  ch = field_cache(h,x)
  @time repeat(n,evaluate!,ch,h,x)
end

using InplaceArrays.Inference

function bench3(n)
  np = 4
  p = Point(1,2)
  x = fill(p,np)
  v = 3.0
  d = 2
  f = MockField{d}(v)
  k = elem(+)
  @time repeat(n,apply_kernel_to_field,k,f,v)
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
