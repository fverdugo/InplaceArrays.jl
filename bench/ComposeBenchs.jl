module ComposeBenchs

using InplaceArrays
using ..MockFields

function loop(a,cache)
  for i in eachindex(a)
    ai = getindex!(cache,a,i)
  end
end

function loop_and_evaluate(ca,cai,cx,a,x)
  for i in eachindex(a)
    ai = getindex!(ca,a,i)
    xi = getindex!(cx,x,i)
    vi = evaluate!(cai,ai,xi)
  end
end

fun(x) = 2*x

function bench1(l)
  d = 2
  ndofs = 8
  bi = VectorValue(1.0,2.0)
  b = MockBasis(d,bi,ndofs)
  vi = VectorValue(1.0,2.0)
  v = fill(vi,ndofs)
  np = 4
  xi = Point(1,2)
  x = fill(xi,np)
  cb = CellValue(b,l)
  cv = CellValue(v,l)
  cx = CellValue(x,l)
  cr = lincomb(cb,cv)
  T = valuetype(cr)
  cf = compose(T,fun,cr)
  chf = array_cache(cf.array)
  chx = array_cache(cx.array)
  fi = testitem(cf.array)
  chfi = new_cache(fi)
  @time loop_and_evaluate(chf,chfi,chx,cf.array,cx.array)
  @time loop(cx.array,chx)
  cfx = evaluate(cf,cx)
  chfx = array_cache(cfx.array)
  @time loop(cfx.array,chfx)
end

for n in (1,1,10,1000,100000)
  @eval begin
    println("+++ runing suite for n = $($n) +++")
    bench1($n)
  end
end

end # module
