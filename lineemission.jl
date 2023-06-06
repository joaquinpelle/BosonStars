using Skylight
using CairoMakie
using Printf
using DataInterpolations

include("bosonstar_parameters.jl")

Nres = 1200

function myprofile(position, spacetime, model)
    r = radius(position, spacetime)
    return 1/r^2
end

num_bins = 40

for modeltype in ["SCHW"]
    for modelid in [""]
        
        modelname = modeltype*string(modelid)
        
        # a = eval(Symbol("a_$(modelname)"))
        # b = eval(Symbol("b_$(modelname)"))
        # rin = eval(Symbol("rin_$(modelname)"))
        # rout = eval(Symbol("rout_$(modelname)"))
        # tempfilename = "tables/Temp$(modelname).dat"
        tempfilename = "tables/TempSchw.dat"
        rin, rout = 6.0, 80.0        
        # spacetime = BosonStarSpacetime(a=a,b=b)
        spacetime = SchwarzschildSpacetimeSphericalCoordinates(M=1.0)
        for ξ in [5, 45, 85]

            ξstr = string(@sprintf("%02d", ξ))
            Nstr = string(@sprintf("%03d", Nres))
            filename =  "$(modelname)_i$(ξstr)deg_N$(Nstr)"
            
            initial_data = load_initial_data_from_hdf5("io/$(filename).h5")
            output_data = load_output_data_from_hdf5("io/$(filename).h5", 1)
            # configurations = load_configurations_from_hdf5("io/$(filename).h5")            
            
            # We recreate the configs because they were saved with model under different name
            image_plane = ImagePlane(distance = 500.0,
                                    observer_inclination_in_degrees = ξ,
                                    observation_times = [0.0],
                                    horizontal_side_image_plane = rout*1.1,
                                    vertical_side_image_plane = rout*1.1,
                                    horizontal_number_of_nodes = Nres,
                                    vertical_number_of_nodes = Nres)

            model = AccretionDiskWithTabulatedTemperature(inner_radius=rin, outer_radius=rout, filename=tempfilename)
                    
            configurations = VacuumOTEConfigurations(spacetime=spacetime,
                                                    image_plane = image_plane,
                                                    radiative_model = model,
                                                    unit_mass_in_solar_masses=1.0)
            binned_fluxes, bins = line_emission_spectrum(initial_data, output_data, configurations; emission_profile = myprofile, num_bins = num_bins)
            set_theme!(; fonts = (; regular = "Times New Roman"))

            # We calculate midpoints of x to use as x coordinates for y
            max_flux = maximum(binned_fluxes)
            bins_midpoints = 0.5*(bins[1:end-1] + bins[2:end])
            fig = Figure(resolution = (600, 400))
            ax = Axis(fig[1, 1], xlabel = L"E/E_0", ylabel = "Flux (arbitrary)", title = "Relativistic line broadening", titlefont=:regular)
            skl = lines!(ax, bins_midpoints, binned_fluxes/max_flux, linewidth = 3, color = :black)
            
            ax.titlesize = 22
            ax.xlabelsize = 22
            ax.ylabelsize = 22
            ax.xticklabelsize = 15
            ax.yticklabelsize = 15
            
            # Save the figure
            save("plots/line_broadening/$(filename)_bins$num_bins.png", fig; dpi=300)

        end
    end
end