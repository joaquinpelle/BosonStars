using Pkg
Pkg.activate("BosonStars")
using Skylight
using StatsBase
using CairoMakie
using LinearAlgebra
using Printf
using Colors
using DataFrames
using GLM
using DelimitedFiles
include("corona.jl")
include("ranges.jl")
include("juliacolors.jl")

#  schwarzschild 
function calculate_sch_profile(;height, npp, nbins, save=true, plot=false)
    spacetime = KerrSpacetimeBoyerLindquistCoordinates(M=1.0, a=0.0)
    disk = NovikovThorneDisk(inner_radius = isco_radius(spacetime, ProgradeRotation()), outer_radius = 100.0)
    corona = LamppostCorona(height=height, theta_offset=1e-5, spectral_index = 2.0)
    configurations = VacuumETOConfigurations(spacetime=spacetime,
                                    radiative_model = corona,
                                    number_of_points=1,
                                    number_of_packets_per_point = npp, 
                                    max_radius = 110.0,
                                    unit_mass_in_solar_masses=1.0)
    initial_data = initialize(configurations)
    cbp = callback_parameters(spacetime, disk, configurations; rhorizon_bound=2e-3)
    cb = callback(spacetime, disk)
    sim = integrate(initial_data, configurations, cb, cbp; method=VCABM(), reltol=1e-5, abstol=1e-5)
    output_data = sim.output_data
    at_source = map(ray -> is_final_position_at_source(ray[1:4], spacetime, disk) && ray[3] ≈ π/2 && abs(Skylight.norm_squared(ray[5:8], metric(ray[1:4], spacetime))) < 1e-2, eachcol(output_data))
    radii = output_data[2,at_source]
    q = energies_quotients(output_data[:,at_source], spacetime, disk)
    # bins = radial_bins(disk, nbins=100)
    bins = range(cbrt(disk.inner_radius), stop=cbrt(disk.outer_radius), length=nbins).^3
    A = ring_areas(bins, spacetime)
    γ = lorentz_factors(bins, spacetime, disk)
    h = fit(Histogram, radii, bins)
    h = normalize(h, mode=:probability)
    𝓝 = h.weights

    qavg = average_inside_radial_bins(q, radii, bins)

    Γ = corona.spectral_index
    n = 𝓝./(A.*γ)
    I = qavg.^Γ.*n

    bins_midpoints = 0.5*(bins[1:end-1] + bins[2:end])
    hstr = string(@sprintf("%.1f", corona.height))
    istr = string(@sprintf("%02d", corona.spectral_index))
    filename = "SCHW_h$(hstr)_idx$(istr)"
    savename = "io/corona/schwarzschild/$(filename).txt"
    figname = "plots/profiles/$(filename).png"

    if save
        open(savename, "w") do io
            writedlm(io, [bins_midpoints I])
        end
    end

    if plot
        fig = Figure(size=(400,400))
        ax = Axis(fig[1,1])
        lines!(ax, bins_midpoints, I)
        ax.xscale = log10
        ax.yscale = log10
        # xlims!(1.0,200)
        # ylims!(1e-6, 1e0)
        ax.xtickformat = "{:.1f}"
        display(fig)
        CairoMakie.save(figname, fig)
    end
    return nothing 
end

function main_sch()
    for height in [5,10]
        println("Doing SCHW h=$(height)")
        calculate_sch_profile(height = height, npp=5000000, nbins=50, save=true, plot=true)
    end
end

main_sch()