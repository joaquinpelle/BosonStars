import Pkg
Pkg.activate("BosonStars")
# Pkg.resolve()

using Skylight
using CairoMakie
using Colors
using Printf

const julia_blue = RGB(0.251, 0.388, 0.847)
const julia_green = RGB(0.22, 0.596, 0.149)
const julia_purple = RGB(0.584, 0.345, 0.698)
const julia_red = RGB(0.796, 0.235, 0.2)

include("bosonstar_parameters.jl")
include("ranges.jl")

const num_bins = 50
const N = "1200"

for modeltype in ["LBS","SBS"]

    for modelid in [1,2,3]    
        model = modeltype*string(modelid)
        
        for ξ in ["05", "45", "85"]

            filename =  "$(model)_i$(ξ)deg_N$(N)"
            
            initial_data = load_initial_data_from_hdf5("io/$(filename).h5")
            configurations = load_configurations_from_hdf5("io/$(filename).h5")
            output_data = load_output_data_from_hdf5("io/$(filename).h5", 1)
            
            bolometric_intensities, q = observed_bolometric_intensities(initial_data, output_data, configurations)
            xs,ys = axes_ranges(camera)
            zs = grid_view(bolometric_intensities, configurations)

            joint_limits = (1e4,2e5)
            fig = Figure()
            ax = Axis(fig[1,1], xlabel=L"\alpha/(GM/c^2)", ylabel=L"\beta/(GM/c^2)", ylabelsize = 26, xlabelsize = 26) 
            hmap = heatmap!(xs, ys, zs; colormap=:gist_heat, interpolate=true, colorrange=joint_limits)
            Colorbar(fig[:, end+1], hmap, label=L"I", labelsize=26, width = 15, ticksize = 18, tickalign = 1)
            colsize!(fig.layout, 1, Aspect(1, 1.0))
            colgap!(fig.layout, 7)
            CairoMakie.save("plots/image/$(filename).png", fig)

            # binned_fluxes, bins = line_emission_spectrum(initial_data, output_data, configurations; emission_profile = myprofile, num_bins = num_bins)
            # max_flux = maximum(binned_fluxes)
            # bins_midpoints = 0.5*(bins[1:end-1] + bins[2:end])

            # fig = Figure(size = (600, 400))
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