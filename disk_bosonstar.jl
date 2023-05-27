import Pkg
Pkg.activate("BosonStars")
# Pkg.resolve()

using Skylight
using CairoMakie
using Printf

include("bosonstar_parameters.jl")

Nres = 1200

for modeltype in ["SBS"]
    for modelid in [3]
        
        modelname = modeltype*string(modelid)
        
        a = eval(Symbol("a_$(modelname)"))
        b = eval(Symbol("b_$(modelname)"))
        rin = eval(Symbol("rin_$(modelname)"))
        rout = eval(Symbol("rout_$(modelname)"))
        tempfilename = "tables/Temp$(modelname).dat"
        
        spacetime = BosonStarSpacetime(a=a,b=b)

        for ξ in [5, 45, 85]

            ξstr = string(@sprintf("%02d", ξ))
            Nstr = string(@sprintf("%03d", Nres))
            filename =  "$(modelname)_i$(ξstr)deg_N$(Nstr)"
            
            image_plane = ImagePlane(distance = 500.0,
                                    observer_inclination_in_degrees = ξ,
                                    horizontal_side_image_plane = rout*1.1,
                                    vertical_side_image_plane = rout*1.1,
                                    horizontal_number_of_nodes = Nres,
                                    vertical_number_of_nodes = Nres)

            model = BosonStarAccretionDisk(inner_radius=rin, outer_radius=rout, temperature_file=tempfilename)
                    
            configurations = VacuumOTEConfigurations(spacetime=spacetime,
                                                    image_plane = image_plane,
                                                    observed_times = [0.0],
                                                    radiative_model = model,
                                                    unit_mass_in_solar_masses=1.0)

            initial_data = get_initial_data(configurations)

            cb, cb_params = get_callback_and_params(configurations) #... or, define your own cb and cb_params

            run = integrate(initial_data, configurations, cb, cb_params; method=VCABM(), reltol=1e-13, abstol=1e-21)
            
            output_data = run.output_data

            bolometric_intensities = get_observed_bolometric_intensities(initial_data, output_data, configurations)

            xs,ys = get_pixel_coordinates_vectors(configurations)

            zs = view_intensities_grid(bolometric_intensities, configurations)

            fig = Figure(font = "CMU Serif")
            ax = Axis(fig[1,1], xlabel=L"\alpha", ylabel=L"\beta", ylabelsize = 26, xlabelsize = 26) 
            hmap = heatmap!(xs, ys, zs; colormap=:gist_heat, interpolate=true)
            Colorbar(fig[:, end+1], hmap, label=L"I", labelsize=26, width = 15, ticksize = 18, tickalign = 1)
            colsize!(fig.layout, 1, Aspect(1, 1.0))
            colgap!(fig.layout, 7)

            CairoMakie.save("plots/$(filename).png", fig)
            save_to_hdf5("io/$(filename).h5", configurations, initial_data, [run])

        end
    end
end