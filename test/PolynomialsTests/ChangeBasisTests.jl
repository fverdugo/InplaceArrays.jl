module ChangeBasisTests

using InplaceArrays.Fields
using InplaceArrays.Polynomials

xi = Point(0.5,0.5)
np = 5
x = fill(xi,np)

nodes = Point{2,Int}[(0,0),(1,0),(0,1),(1,1)]

order = 1
V = Float64
G = gradient_type(V,xi)
H = gradient_type(G,xi)
f = MonomialBasis{2}(V,order)

change = inv(evaluate(f,nodes))

g = change_basis(f,change)

gx = V[1.0 0.0 0.0 0.0; 0.0 1.0 0.0 0.0; 0.0 0.0 1.0 0.0; 0.0 0.0 0.0 1.0]
∇gx = G[
  (-1.0, -1.0) (1.0, 0.0) (0.0, 1.0) (0.0, 0.0);
  (-1.0, 0.0) (1.0, -1.0) (0.0, 0.0) (0.0, 1.0);
  (0.0, -1.0) (0.0, 0.0) (-1.0, 1.0) (1.0, 0.0);
  (0.0, 0.0) (0.0, -1.0) (-1.0, 0.0) (1.0, 1.0)]
∇∇gx = H[
  (0.0, 1.0, 1.0, 0.0) (0.0, -1.0, -1.0, 0.0) (0.0, -1.0, -1.0, 0.0) (0.0, 1.0, 1.0, 0.0);
  (0.0, 1.0, 1.0, 0.0) (0.0, -1.0, -1.0, 0.0) (0.0, -1.0, -1.0, 0.0) (0.0, 1.0, 1.0, 0.0);
  (0.0, 1.0, 1.0, 0.0) (0.0, -1.0, -1.0, 0.0) (0.0, -1.0, -1.0, 0.0) (0.0, 1.0, 1.0, 0.0);
  (0.0, 1.0, 1.0, 0.0) (0.0, -1.0, -1.0, 0.0) (0.0, -1.0, -1.0, 0.0) (0.0, 1.0, 1.0, 0.0)]

test_field(g,nodes,gx,grad=∇gx,hessian=∇∇gx)

end # module
