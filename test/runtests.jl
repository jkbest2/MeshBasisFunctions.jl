using MeshBasisFunctions
using Meshes
using Test

points = Point2[(0,0), (1,0), (0,1), (1,1),
                (0.25,0.5), (0.75,0.5), (0.5, 0), (0.5, 1.0)]
tris = connect.([(1,5,3), (1, 7, 5), (7, 6, 5), (7, 2, 6),
                 (4, 6, 2), (4, 8, 6), (8, 5, 6), (8, 3, 5)],
                Triangle)
mesh = SimpleMesh(points, tris)
md = meshdata(mesh, Dict(0 => (z = randn(8), )))

basis = PiecewiseLinearBasis{2}()

interp_pts = [Point(0.0, 0.0),
              Point(0.5, 0.5),
              Point(0.34, 0.98),
              Point(0.12, 0.84)]
interp_op = interpolation_operator(interp_pts,
                                   mesh,
                                   basis)
interp1 = interp_op * values(md, 0)[:z]
interp2 = [interpolate(pt, md, :z, basis) for pt in interp_pts]

@testset "MeshBasisFunctions.jl" begin
    @test all(interp1 .== interp2)
end
