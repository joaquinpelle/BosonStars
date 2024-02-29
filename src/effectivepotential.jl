calculate_effective_potential(model; rin, rout, N) = calculate_effective_potential(iscollective(model), model, rin=rin, rout=rout, N=N)
calculate_effective_potential(::IsCollective, model; rin, rout, N) = [calculate_effective_potential(m, rin=rin, rout=rout, N=N) for m in model] 

function calculate_effective_potential(::IsNotCollective, model; rin, rout, N)
    spacetime = create_spacetime(model)
    rin = max(rin, minimum_radius(model))
    F = EffectivePotential(model=model, N=N)
    F.r = range(rin, stop=rout, length=N)
    positions = [[0.0, r, π/2, 0.0] for r in F.r]
    g = zeros(4,4)
    for (i,position) in enumerate(positions)
        metric!(g, position, spacetime, nothing)
        F.gₜₜ[i] = g[1,1]
        F.gᵣᵣ[i] = g[2,2]
        F.sqrtg[i] = volume_element(position, spacetime, g, nothing)
        F.Ω[i] = circular_geodesic_angular_speed(position, spacetime, ProgradeRotation())
        F.E[i], F.L[i] = circular_geodesic_energy_and_angular_momentum(g, F.Ω[i])
        F.V[i] = -F.gₜₜ[i]*(1+F.L[i]^2/position[2]^2) 
    end
    return F
end

function circular_geodesic_energy_and_angular_momentum(g, Ω)
    gtt = g[1,1]
    gφφ = g[4,4] 
    den = sqrt(-gtt -gφφ*Ω^2) 
    return -gtt/den, gφφ*Ω/den
end