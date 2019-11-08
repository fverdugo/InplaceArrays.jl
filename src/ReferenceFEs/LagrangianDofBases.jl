

"""
"""
struct LagrangianDofBasis{P,V} <: Dof
  nodes::Vector{P}
  dof_to_node::Vector{Int}
  dof_to_comp::Vector{Int}
  node_and_comp_to_dof::Vector{V}
end

"""
"""
function LagrangianDofBasis(::Type{T},nodes::Vector{<:Point}) where T
  r = _generate_dof_layout(T,length(nodes))
  LagrangianDofBasis(nodes,r...)
end

function _generate_dof_layout(::Type{<:Real},nnodes::Integer)
  ndofs = nnodes
  dof_to_comp = ones(Int,ndofs)
  dof_to_node = collect(1:nnodes)
  node_and_comp_to_dof = collect(1:ndofs)
  (dof_to_node, dof_to_comp, node_and_comp_to_dof)
end

# Node major implementation
function _generate_dof_layout(::Type{T},nnodes::Integer) where T<:MultiValue
  ncomps = n_components(T)
  V = change_eltype(T,Int)
  ndofs = ncomps*nnodes
  dof_to_comp = zeros(Int,ndofs)
  dof_to_node = zeros(Int,ndofs)
  node_and_comp_to_dof = zeros(V,nnodes)
  m = zero(mutable(V))
  for node in 1:nnodes
    for comp in 1:ncomps
      o = nnodes*(comp-1)
      dof = node+o
      dof_to_comp[dof] = comp
      dof_to_node[dof] = node
      m[comp] = dof
    end
    node_and_comp_to_dof[node] = m
  end
  (dof_to_node, dof_to_comp, node_and_comp_to_dof)
end

function dof_cache(b::LagrangianDofBasis,field)
  field_cache(field,b.nodes)
end

@inline function evaluate_dof!(cache,b::LagrangianDofBasis,field)
  evaluate_field!(cache,field,b.nodes)
end
