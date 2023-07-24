import Pkg
Pkg.activate("BosonStars")
# Pkg.resolve()

using Skylight
using CairoMakie
using Printf

include("bosonstar_parameters.jl")

function main(obs_distance=1000.0, Nres=1200)

    for modeltype in ["SBS"]
        for modelid in [3]
            
            modelname = modeltype*string(modelid)
            
            a = eval(Symbol("a_$(modelname)"))
            b = eval(Symbol("b_$(modelname)"))
            rin = eval(Symbol("rin_$(modelname)"))
            rout = eval(Symbol("rout_$(modelname)"))
            tempfilename = "tables/Temp$(modelname).dat"
            
            spacetime = BosonStarSpacetime(a=a,b=b)

            for ξ in [5,45,85]

                ξstr = string(@sprintf("%02d", ξ))
                Nstr = string(@sprintf("%03d", Nres))
                filename =  "$(modelname)_i$(ξstr)deg_N$(Nstr)"
                
                spher_pos = [0.0, obs_distance, deg2rad(ξ), 0.0]

                if modeltype=="LBS"
                    ap = 3.5
                elseif modeltype=="SBS"
                    ap = 4.25
                end

                camera = PinholeCamera(position = spher_pos,
                                    horizontal_aperture_in_degrees = ap, #rad2deg(70/distance),
                                    vertical_aperture_in_degrees = ap, #rad2deg(70/distance),
                                    horizontal_number_of_pixels = Nres,
                                    vertical_number_of_pixels = Nres) 

                model = AccretionDiskWithTabulatedTemperature(inner_radius=rin, outer_radius=rout, filename=tempfilename)
                        
                configurations = VacuumOTEConfigurations(spacetime=spacetime,
                                                        camera = camera,
                                                        radiative_model = model,
                                                        unit_mass_in_solar_masses=1.0)

                initial_data = initialize(configurations)
                cb, cb_params = callback_setup(configurations) #... or, define your own cb and cb_params
                run = integrate(initial_data, configurations, cb, cb_params; method=VCABM(), reltol=1e-6, abstol=1e-6)
                output_data = run.output_data
                save_to_hdf5("io/$(filename).h5", configurations, initial_data, [run]; mode="w")

                bolometric_intensities, q = observed_bolometric_intensities(initial_data, output_data, configurations)
                xs,ys = axes_ranges(camera)
                zs = grid_view(bolometric_intensities, configurations)

                # joint_limits = (1e4,2e5)
                fig = Figure()
                ax = Axis(fig[1,1], xlabel=L"\alpha", ylabel=L"\beta", ylabelsize = 26, xlabelsize = 26) 
                hmap = heatmap!(xs, ys, zs; colormap=:gist_heat, interpolate=true)#, colorrange=joint_limits)
                Colorbar(fig[:, end+1], hmap, label=L"I", labelsize=26, width = 15, ticksize = 18, tickalign = 1)
                colsize!(fig.layout, 1, Aspect(1, 1.0))
                colgap!(fig.layout, 7)
                CairoMakie.save("plots/image/$(filename).png", fig)

                println("$(filename) done")
                # binned_fluxes, bins = line_emission_spectrum(initial_data, output_data, configurations; emission_profile = myprofile, num_bins = num_bins)
                # max_flux = maximum(binned_fluxes)
                # bins_midpoints = 0.5*(bins[1:end-1] + bins[2:end])

                # fig = Figure(resolution = (600, 400))
                # ax = Axis(fig[1, 1], xlabel = L"E/E_0", ylabel = "Flux (arbitrary)", title = "Relativistic line broadening", titlefont=:regular)
                # skl = lines!(ax, bins_midpoints, binned_fluxes/max_flux, linewidth = 3, color = :black)

                # ax.titlesize = 22
                # ax.xlabelsize = 22
                # ax.ylabelsize = 22
                # ax.xticklabelsize = 15
                # ax.yticklabelsize = 15

                # # Save the figure
                # CairoMakie.save("plots/line_broadening/$(filename)_bins$(num_bins).png", fig; dpi=300)
            end
        end
    end
end

main()