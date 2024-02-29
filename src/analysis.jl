#This script is not part of the original code, just kept as future reference
include("BosonStars.jl")
include("isco.jl")

#Temperature factors
FSBS = calculate_temperature_factors(SBS(1:3), rout=40, N=100)
FLBS = calculate_temperature_factors(LBS(1:3), rout=40, N=100)
FBH = calculate_temperature_factors(BH(), rout=40, N=100)

properties = [:Ω, :E, :L, :T]
plot_factors(;FLBS=FLBS, FSBS=FSBS, FBH=FBH, rout=20.0, properties=properties, logscale=false)

#Effective potential
FSBS = calculate_effective_potential(SBS(1:3), rin=5.0, rout=10, N=100)
FBH = calculate_effective_potential(BH(), rin=5.0, rout=10, N=100)
plot_potential(;FSBS=FSBS, FBH=FBH, rin=5.0, rout=20.0, property=:V, logscale=false)