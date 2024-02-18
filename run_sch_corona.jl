using Pkg
Pkg.activate("BosonStars")
using CairoMakie
using Printf
using Colors
using DelimitedFiles
using Skylight
include("corona.jl")
include("ranges.jl")
include("juliacolors.jl")

#  schwarzschild 
function calculate_sch_profile(;height, npp, nbins, save=true, plot=false)

    spacetime = KerrSpacetimeBoyerLindquistCoordinates(M=1.0, a=0.0)
    corona = LamppostCorona(height=height, theta_offset=1e-5, spectral_index = 2.0)
    configurations = VacuumETOConfigurations(spacetime=spacetime,
                                    radiative_model = corona,
                                    number_of_points=1,
                                    number_of_packets_per_point = npp, 
                                    max_radius = 110.0,
                                    unit_mass_in_solar_masses=1.0)
    initial_data = initialize(configurations)
    disk = NovikovThorneDisk(inner_radius = isco_radius(spacetime, ProgradeRotation()), outer_radius = 100.0)
    plane = NovikovThorneDisk(inner_radius = event_horizon_radius(spacetime)+1e-3+eps(), outer_radius = 100.0)
    cbp = callback_parameters(spacetime, plane, configurations; rhorizon_bound=1e-3)
    cb = callback(spacetime, plane)
    sim = integrate(initial_data, configurations, cb, cbp; method=VCABM(), reltol=1e-5, abstol=1e-5)
    output_data = sim.output_data

    I, bins_edges = emissivity_profile(output_data, spacetime, disk, corona, nbins = nbins)

    hstr = string(@sprintf("%.1f", corona.height))
    istr = string(@sprintf("%02d", corona.spectral_index))
    filename = "SCHW_h$(hstr)_idx$(istr)"
    savename = "io/corona/schwarzschild/$(filename).txt"
    figname = "plots/profiles/$(filename).png"

    if save
        open(savename, "w") do io
            writedlm(io, [bins_edges I])
        end
    end

    if plot
        fig = Figure(size=(400,400))
        ax = Axis(fig[1,1])
        lines!(ax, bins_edges, I)
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
    for height in [40.0]
        println("Doing SCHW h=$(height)")
        calculate_sch_profile(height = height, npp=5000000, nbins=50, save=true, plot=true)
    end
end

main_sch()