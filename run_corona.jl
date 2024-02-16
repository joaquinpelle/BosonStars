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

#   Boson star
function calculate_profile(modelname, modelid; height, npp, nbins, save=true, plot=false)

    filenames = get_filenames(modelname)
    obs_configurations = load_configurations_from_hdf5("io/$(filenames[modelid,1]).h5")
    spacetime = obs_configurations.spacetime
    corona = LamppostCorona(height=height, theta_offset=1e-5, spectral_index = 2.0)
    configurations = VacuumETOConfigurations(spacetime=spacetime,
                                    radiative_model = corona,
                                    number_of_points=1,
                                    number_of_packets_per_point = npp, 
                                    max_radius = 110.0,
                                    unit_mass_in_solar_masses=1.0)
    initial_data = initialize(configurations)
    disk = obs_configurations.radiative_model
    plane = NovikovThorneDisk(inner_radius = 0.0, outer_radius = disk.outer_radius)
    cbp = callback_parameters(spacetime, plane, configurations)
    cb = callback(spacetime, plane)
    sim = integrate(initial_data, configurations, cb, cbp; method=VCABM(), reltol=1e-5, abstol=1e-5)
    output_data = sim.output_data
    
    I, bins_midpoints = emissivity_profile(output_data, spacetime, disk, corona, nbins = nbins)

    hstr = string(@sprintf("%.1f", corona.height))
    istr = string(@sprintf("%02d", corona.spectral_index))
    filename = "$(modelname)$(modelid)_h$(hstr)_idx$(istr)"
    savename = "io/corona/bosonstar/$(filename).txt"
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

function main()
    for modelname in ["LBS"]
        for modelid in [3]
            for height in [10]
                println("Doing $(modelname)$(modelid) h=$(height)")
                calculate_profile(modelname, modelid; height=height, npp=5000000, nbins=50, save=true, plot=true) 
            end
        end
    end
end

main()