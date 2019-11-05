module MonomialBasesBenchs

using InplaceArrays.TensorValues
using InplaceArrays.Fields
using InplaceArrays.Polynomials

@inline function repeat(n,f,args...)
  for i in 1:n
    f(args...)
  end
  nothing
end

function bench1(n)

  xi = Point(2,3)
  np = 5
  x = fill(xi,np)

  orders = (1,2)
  V = Float64
  G = gradient_type(V,xi)
  b = MonomialBasis{2}(V,orders)

  cb = field_cache(b,x)
  @time repeat(n,evaluate_field!,cb,b,x)

  ∇b = ∇(b)
  c∇b = field_cache(∇b,x)
  @time repeat(n,evaluate_field!,c∇b,∇b,x)

end

for n in (1,1,10,1000,100000)
  @eval begin
    println("+++ runing suite for n = $($n) +++")
    bench1($n)
  end
end

end # module
