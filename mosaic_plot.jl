
# import Pkg
# Pkg.activate("BosonStars")
# Pkg.resolve()

using Skylight
using CairoMakie
using Printf

include("ranges.jl")

const char_dict = Dict("LBS"=>L"\Lambda", "SBS"=>"S")
const model_ticks = Dict("LBS" => [[0.0,0.02,0.05],[0.0, 0.1, 0.2],[0.0, 0.5, 1.0]], 
                  "SBS" => [[0.0,0.02,0.05],[0.0, 0.1, 0.2],[0.0, 0.5, 1.0]])

function get_filenames(model)
    filenames = Matrix{String}(undef, 3, 3)
    inclinations = [5, 45, 85]
    Nres = 1200
    for i in 1:3
        modelname = model*string(i)
        for j in 1:3
            ξ = inclinations[j]
            ξstr = string(@sprintf("%02d", ξ))
            Nstr = string(@sprintf("%03d", Nres))
            filenames[i,j] = "$(modelname)_i$(ξstr)deg_N$(Nstr)"
            @assert isfile("io/$(filenames[i,j]).h5") "File $(filenames[i,j]).h5 does not exist"
        end
    end
    return filenames
end

function get_zmaxglobal()
    num_bins = 3
    qmin, qmax, zmin, zmaxLBS, Fmax = ranges(get_filenames("LBS"), num_bins)
    qmin, qmax, zmin, zmaxSBS, Fmax = ranges(get_filenames("SBS"), num_bins)
    zmaxglobal = max(zmaxLBS, zmaxSBS)
    return zmaxglobal
end

function get_data_and_zmaxcols(filenames)
    data = Matrix{Any}(undef, 3, 3)
    zmaxcols = zeros(3)
    num_bins = 50
    for j in 1:3
        qmin, qmax, zmin, zmaxcol, Fmax = ranges(filenames[:,j], num_bins) 
        zmaxcols[j] = zmaxcol
        for i in 1:3
            initial_data, output_data, configurations = load_everything(filenames[i,j])
            Iobs, q = observed_bolometric_intensities(initial_data, output_data, configurations)
            xs,ys = axes_ranges(configurations.camera)
            zs = grid_view(Iobs, configurations)
            data[i,j] = (xs, ys, zs)
        end
    end
    return data, zmaxcols
end

function plot_mosaic(model, figname)
    filenames = get_filenames(model)
    zmaxglobal = get_zmaxglobal()
    data, zmaxcols = get_data_and_zmaxcols(filenames)
    axes = Matrix{Axis}(undef, 3, 3)
    set_theme!(; fonts = (; regular = "Times New Roman"))
    layout = GridLayout(3, 3)
    fig = Figure(layout = layout, resolution = (800, 800))
    inclination_labels = [L"\xi = 5^\circ", L"\xi = 45^\circ", L"\xi = 85^\circ"]
    cbar_ticks = model_ticks[model]
    modelchar = char_dict[model] 
    for j in 1:3
        for i in 1:3
            ax = Axis(fig[i,j])
            axes[i,j] = ax
            xs, ys, zs = data[i,j]
            xs = rad2deg.(xs)
            ys = rad2deg.(ys)
            hmap = heatmap!(xs, ys, zs/zmaxcols[j]; colormap=:gist_heat, interpolate=true)
        end
    end

    for k in 1:3

        axbottom = axes[3,k]
        axtop = axes[1,k]
        axright = axes[k,3]
        axleft = axes[k,1]
        # axbottom.xlabel = L"\alpha \, [\text{rad}]"
        axbottom.xlabel = L"\alpha \, [^\circ]"
        axbottom.xlabelvisible = k == 2 #Only show xlabel for middle column
        axbottom.xlabelsize = 20
        axbottom.xticklabelsize = 12
        axbottom.xtickalign = 1
        axbottom.xtickcolor = :white

        axright.yaxisposition = :right
        axright.ylabelvisible = k == 2 #Only show ylabel for middle row
        # axright.ylabel = L"\beta \, [\text{rad}]"
        axright.ylabel = L"\beta \, [^\circ]"
        axright.ylabelsize = 20
        axright.yticklabelsize = 12
        axright.ytickalign = 1
        axright.ytickcolor = :white

        for l in 1:2
        
            #Link axes and hide decorations of non-right and non-bottom axes
            #axis linking is redundant here (the ranges coincide already), but just in case
            linkxaxes!(axright, axes[l,k])
            hidexdecorations!(axes[l,k])
            linkyaxes!(axleft, axes[k,l])
            hideydecorations!(axes[k,l])
        end

        #Make left ylabel visible again to use as model label
        axleft.ylabelvisible = true
        axleft.ylabel = L"%$(modelchar) \text{BS%$(k)}"
        axleft.ylabelsize = 16
        
        
        cbar = Colorbar(fig[0,k], vertical=false, colormap=:gist_heat, colorrange = (0,zmaxcols[k]/zmaxglobal), label=inclination_labels[k])
        cbar.size = 12 
        cbar.ticks = cbar_ticks[k]
        cbar.tickalign = 1
        cbar.ticksize = 12
        cbar.ticklabelsize = 10
        cbar.tickcolor = :black
        cbar.labelsize = 20
        cbar.label = L"I \, (\text{arbitrary})"
        cbar.labelpadding = 0.5
        cbar.labelvisible = k == 2 #Only show colorbar label for middle column
        
        supertitle = Label(fig[-1,k], inclination_labels[k], justification=:center, fontsize=16, color=:black)
        supertitle.tellwidth = false
        supertitle.padding = (0.0, 0.0, 10.0, 0.0)

    end

    colgap!(fig.layout, 2)
    rowgap!(fig.layout, 2)
    CairoMakie.save(figname, fig)
end