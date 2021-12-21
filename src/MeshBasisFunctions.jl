module MeshBasisFunctions

using Meshes
using StaticArrays
using SparseArrays

export
    MeshBasisFunction,
    PiecewiseLinearBasis,
    BarycentricCoordTransform,
    tobarycoord,
    tonatcoord,
    interpolation_wts,
    interpolation_operator,
    interpolate

abstract type MeshBasisFunction{D} end

struct PiecewiseLinearBasis{D} <: MeshBasisFunction{D} end

struct BarycentricCoordTransform{D, F, L}
    p0::Point{D, F}
    T::SMatrix{D, D, F, L}

    function BarycentricCoordTransform(p0::Point{D, F}, T::SMatrix{D, D, F, L}) where {D, F, L}
        new{D, F, L}(p0, T)
    end
end

function BarycentricCoordTransform(tri::Triangle)
    v = vertices(tri)
    p0 = v[1]
    T = [v[2] - p0 v[3] - p0]
    D = length(p0.coords)
    F = eltype(p0.coords)
    L = length(T)
    BarycentricCoordTransform(p0, T)
end

function tobarycoord(pt::Point{D}, bct::BarycentricCoordTransform{D}) where D
    bct.T \ (pt - bct.p0)
end

function tonatcoord(pt::Point{D}, bct::BarycentricCoordTransform{D}) where D
    bct.T * pt + bct.p0
end

function interpolation_wts(pt::Point{D}, mesh::SimpleMesh{D}, basis::PiecewiseLinearBasis{D}) where D
    el_idx = findfirst(Ref(pt) .∈ mesh)
    node_idx = mesh.topology.connec[el_idx].indices
    tri = mesh[el_idx]
    wts = _interp_wts(pt, tri)

    (cols = [node_idx...], wts = wts)
end

function _interp_wts(pt::Point, tri::Triangle)
    bct = BarycentricCoordTransform(tri)
    wt23 = tobarycoord(pt, bct)
    wt1 = 1 - sum(wt23)
    [wt1; wt23]
end

function interpolation_operator(pts::Vector{<:Point}, mesh::SimpleMesh, basis::PiecewiseLinearBasis)
    Is = Vector{Int}()
    Js = Vector{Int}()
    Vs = Vector{Float64}()
    js = zeros(3)
    vs = zeros(3)
    for (i, pt) in enumerate(pts)
        js[:], vs[:] = interpolation_wts(pt, mesh, basis)
        perm = sortperm(js)
        append!(Is, repeat([i], 3))
        append!(Js, js[perm])
        append!(Vs, vs[perm])
    end
    dropzeros!(sparse(Is, Js, Vs))
end

function interpolate(pt::Point{2}, md::MeshData, sym, basis::PiecewiseLinearBasis{2})
    js, vs = interpolation_wts(pt, domain(md), basis)
    vals = values(md, 0)[sym]
    sum(vs .* vals[js])
end

end
