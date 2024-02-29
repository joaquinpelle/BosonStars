#This is an extra file, not part of the original code, just kept as future reference
using Roots
using FiniteDiff
include("BosonStars.jl")

function find_isco(model, rmin, rmax)
    spacetime = create_spacetime(model)
    g = zeros(4,4)
    f(r) = FiniteDiff.finite_difference_derivative(x -> effective_potential(x, spacetime, g), r)
    return find_zero(f, (rmin, rmax), Bisection())
end

function effective_potential(r, spacetime, g)
    pos = [0.0, r, π/2, 0.0]
    metric!(g, pos, spacetime, nothing)
    gₜₜ = g[1,1]
    Ω = circular_geodesic_angular_speed(pos, spacetime, ProgradeRotation())
    _, L = circular_geodesic_energy_and_angular_momentum(g, Ω)
    return -gₜₜ*(1 + L^2/r^2)
end

#ISCO calculation
find_isco(SBS(3), 5.9, 7.0)