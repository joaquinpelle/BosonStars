calculate_temperature_factors(model; rout, N) = calculate_temperature_factors(iscollective(model), model, rout=rout, N=N)
calculate_temperature_factors(::IsCollective, model; rout, N) = [calculate_temperature_factors(m, rout=rout, N=N) for m in model] 

function calculate_temperature_factors(::IsNotCollective, model; rout, N)
    spacetime = create_spacetime(model)
    rin = inner_radius(model)
    F = TemperatureFactors(model=model, N=N)
    F.r = range(rin, stop=rout, length=N)
    positions = [[0.0, r, π/2, 0.0] for r in F.r]
    g = zeros(4,4)

    for (i,position) in enumerate(positions)
        r = position[2]
        metric!(g, position, spacetime, nothing)
        F.gₜₜ[i] = g[1,1]
        F.gᵣᵣ[i] = g[2,2]
        F.sqrtg[i] = -sqrt(g[1,1]*g[2,2])*r^2
        F.Ω[i] = circular_geodesic_angular_speed(position, spacetime, ProgradeRotation())
        F.E[i], F.L[i] = circular_geodesic_energy_and_angular_momentum(g, F.Ω[i])
        F.EmΩL[i] = F.E[i] - F.Ω[i]*F.L[i]
        F.V[i] = -F.gₜₜ[i]*(1+F.L[i]^2/r^2) 
    end

    second_order_finite_difference!(F.∂ᵣΩ, F.Ω, F.r)
    second_order_finite_difference!(F.∂ᵣL, F.L, F.r)
    
    dr = F.r[2] - F.r[1]
    F.df .= F.EmΩL.*F.∂ᵣL*dr 
    for i in 2:100
        F.∫df[i] = F.∫df[i-1] + F.df[i]
    end
    F.Q .= -F.∂ᵣΩ./(F.sqrtg.*(F.EmΩL).^2).*F.∫df
    F.Q[1] = 1e-40
    F.T .= F.Q.^0.25
    return F
end