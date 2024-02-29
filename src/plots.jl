function bolometric_intensity_mosaic(runset::CameraRunSet; zmax, figname)
    has_three_inclinations(runset) || throw(ArgumentError("The runset does not contain three inclinations"))
    bolometric_intensity_mosaic(runset, runset.models; zmax=zmax, figname=figname)
end

function bolometric_intensity_mosaic(runset::CameraRunSet, model::AbstractBosonStar; zmax, figname)
    has_three_models(runset) || throw(ArgumentError("The runset does not contain three models"))
    has_three_inclinations(runset) || throw(ArgumentError("The runset does not contain three inclinations"))
    data, zmaxcols = bolometric_intensity_data(runset)
    fig, axes = prepare_mosaic(nrows=3, size=(800, 800))
    inclination_labels = get_inclination_labels(runset) 
    model_labels = get_model_labels(runset) 
    cbar_ticks = get_cbar_ticks(model)     
    
    for j in 1:3
        for i in 1:3
            axes[i,j] = Axis(fig[i,j])
            xs, ys, zs = data[i,j]
            xs, ys = rescale_axes(xs, ys)
            heatmap!(xs, ys, zs/zmaxcols[j]; colormap=:gist_heat, interpolate=true)
        end
    end

    for k in 1:3
        axbottom = axes[3,k]
        axtop = axes[1,k]
        axright = axes[k,3]
        axleft = axes[k,1]
        axbottom.xlabel = alpha_label()
        axbottom.xlabelvisible = k == 2 #Only show xlabel for middle column
        axbottom.xlabelsize = 22
        axbottom.xticklabelsize = 12
        axbottom.xtickalign = 1
        axbottom.xtickcolor = :white

        axright.yaxisposition = :right
        axright.ylabelvisible = k == 2 #Only show ylabel for middle row
        axright.ylabel = beta_label()
        axright.ylabelsize = 22
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
        axleft.ylabel = model_labels[k]
        axleft.ylabelsize = 18
        
        cbar = Colorbar(fig[0,k], vertical=false, colormap=:gist_heat, colorrange = (0,zmaxcols[k]/zmax), label=inclination_labels[k])
        cbar.size = 12 
        cbar.ticks = cbar_ticks[k]
        cbar.tickalign = 1
        cbar.ticksize = 12
        cbar.ticklabelsize = 12
        cbar.tickcolor = :black
        cbar.label = intensity_label()
        cbar.labelsize = 22
        cbar.labelpadding = 0.5
        cbar.labelvisible = k == 2 #Only show colorbar label for middle column
        
        supertitle = Label(fig[-1,k], inclination_labels[k], justification=:center, fontsize=16, color=:black)
        supertitle.tellwidth = false
        supertitle.padding = (0.0, 0.0, 10.0, 0.0)
    end
    colgap!(fig.layout, 2)
    rowgap!(fig.layout, 2)
    display(fig)
    save(figname, fig, pt_per_unit = 0.5)
end

function bolometric_intensity_mosaic(runset::CameraRunSet, model::BH; zmax, figname)
    has_one_model(runset) || throw(ArgumentError("The runset does not contain one model"))
    has_three_inclinations(runset) || throw(ArgumentError("The runset does not contain three inclinations"))
    data, zmaxcols = bolometric_intensity_data(runset)
    fig, axes = prepare_mosaic(nrows=1, size=(900, 400))
    inclination_labels = get_inclination_labels(runset) 
    cbar_ticks = get_cbar_ticks(model)     
    
    for j in 1:3
        axes[1,j] = Axis(fig[1,j])
        xs, ys, zs = data[1,j]
        xs, ys = rescale_axes(xs, ys)
        heatmap!(xs, ys, zs/zmaxcols[j]; colormap=:gist_heat, interpolate=true)
    end

    axleft = axes[1,1]
    axmid = axes[1,2]
    axright = axes[1,3]

    #Link axes and hide decorations of non-right and non-bottom axes
    #axis linking is redundant here (the ranges coincide already), but just in case
    linkyaxes!(axleft, axmid)
    linkyaxes!(axleft, axright)
    hideydecorations!(axmid)
    hideydecorations!(axleft)

    #Only show xlabel for middle column
    axleft.xlabelvisible = false 
    axright.xlabelvisible = false 

    axright.yaxisposition = :right
    axright.ylabel = beta_label()
    axright.ylabelsize = 22
    axright.yticklabelsize = 12
    axright.ytickalign = 1
    axright.ytickcolor = :white

    #Make left ylabel visible again to use as model label
    axleft.ylabelvisible = true
    axleft.ylabel = model_label(model)
    axleft.ylabelsize = 18

    for k in 1:3

        ax = axes[1,k]
        ax.xlabel = alpha_label()
        ax.xlabelsize = 22
        ax.xticklabelsize = 12
        ax.xtickalign = 1
        ax.xtickcolor = :white

        cbar = Colorbar(fig[0,k], vertical=false, colormap=:gist_heat, colorrange = (0,zmaxcols[k]/zmax))
        cbar.size = 12 
        cbar.ticks = cbar_ticks[k]
        cbar.tickalign = 1
        cbar.ticksize = 12
        cbar.ticklabelsize = 12
        cbar.tickcolor = :black
        cbar.label = intensity_label()
        cbar.labelsize = 22
        cbar.labelpadding = 0.5
        cbar.labelvisible = k == 2 #Only show colorbar label for middle column

        supertitle = Label(fig[-1,k], inclination_labels[k], justification=:center, fontsize=16, color=:black)
        supertitle.tellwidth = false
        supertitle.padding = (0.0, 0.0, 10.0, 0.0)
    end
    colgap!(fig.layout, 2)
    rowgap!(fig.layout, 2)
    display(fig)
    save(figname, fig, pt_per_unit = 0.5)
end

function spectrum_mosaic(LBSrunset::CameraRunSet, SBSrunset::CameraRunSet, BHrunset::CameraRunSet; observation_energies, figname)
    runsets = [LBSrunset, SBSrunset, BHrunset]
    have_three_inclinations(runsets) || throw(ArgumentError("Runsets must have three inclinations")) 
    have_same_inclinations(runsets) || throw(ArgumentError("Runsets must have the same inclinations"))
    have_three_models([LBSrunset, SBSrunset]) || throw(ArgumentError("Boson star runsets must have three models")) 
    has_one_model(BHrunset) || throw(ArgumentError("Black hole runset must have one model")) 

    LBSdata = spectrum_data(LBSrunset, observation_energies)
    SBSdata = spectrum_data(SBSrunset, observation_energies)
    BHdata = spectrum_data(BHrunset, observation_energies)
    
    fig, axes = prepare_mosaic(nrows=1, size=(1000,400))
    inclination_labels = get_inclination_labels(LBSrunset)
    LBSmodel_labels = get_model_labels(LBSrunset)
    SBSmodel_labels = get_model_labels(SBSrunset)
    
    colors = julia_colors(:red, :green, :purple)

    for j in 1:3
        axes[1,j] = Axis(fig[1,j])
    end

    axleft = axes[1,1]
    axmid = axes[1,2]
    axright = axes[1,3]

    #Link axes and hide decorations of non-right and non-bottom axes
    #axis linking is redundant here (the ranges coincide already), but just in case
    linkyaxes!(axleft, axmid)
    linkyaxes!(axleft, axright)
    hideydecorations!(axmid, grid=false)
    hideydecorations!(axright, grid=false)

    #Only show xlabel for middle column
    axleft.xlabelvisible = false 
    axright.xlabelvisible = false 

    axleft.ylabel = thermal_emission_flux_label() 
    
    axleft.ylabelsize = 22
    axleft.yticklabelsize = 12
    axleft.ytickalign = 1

    for j in 1:3
        ax = axes[1,j]
        for i in 1:3
            FLBS = LBSdata[i,j]
            lines!(ax, erg_to_eV(observation_energies), eV_to_erg(FLBS); linewidth=2.0, color=colors[i], linestyle=:dot, label=LBSmodel_labels[i])
        end
        FBH = BHdata[1,j]
        lines!(ax, erg_to_eV(observation_energies), eV_to_erg(FBH); linewidth=2.0, color=:black, linestyle=:solid, label=model_label(BH()))
        ylims!(ax, 1e5, 1e16)
        ax.xscale = log10
        ax.yscale = log10
        ax.title = inclination_labels[j]
        ax.titlesize = 18
        ax.xlabel = thermal_emission_energy_label() 
        ax.xlabelsize = 22
        ax.ylabelsize = 22
        ax.xticklabelsize = 15
        ax.yticklabelsize = 15
        ax.xtickalign = 1
        for i in 1:3
            FSBS = SBSdata[i,j]
            lines!(ax, erg_to_eV(observation_energies), eV_to_erg(FSBS); linewidth=2.0, color=colors[i], linestyle=:dash, label=SBSmodel_labels[i])
        end
    end

    axislegend(axmid, position=:cb, nbanks = 4, orientation=:horizontal)
    # leg = Legend(fig[1,2], axmid, L"\text{Model}", nbanks = 4, tellwidth=false, tellheight=false, orientation=:horizontal, valign=:bottom)
    colgap!(fig.layout, 0)
    display(fig)
    save(figname, fig)
end

function emissiviy_profile_mosaic(LBSrunset::CoronaRunSet, SBSrunset::CoronaRunSet, BHrunset::CoronaRunSet; figname)
    runsets = [LBSrunset, SBSrunset, BHrunset]
    have_three_heights(runsets) || throw(ArgumentError("Runsets must have three heights")) 
    have_same_heights(runsets) || throw(ArgumentError("Runsets must have the same heights"))
    have_three_models([LBSrunset, SBSrunset]) || throw(ArgumentError("Boson star runsets must have three models")) 
    has_one_model(BHrunset) || throw(ArgumentError("Black hole runset must have one model")) 

    LBSdata = emissivity_profile_data(LBSrunset)
    SBSdata = emissivity_profile_data(SBSrunset)
    BHdata = emissivity_profile_data(BHrunset)
    
    fig, axes = prepare_mosaic(nrows=1, size=(1000,400))

    height_labels = get_height_labels(LBSrunset)
    LBSmodel_labels = get_model_labels(LBSrunset)
    SBSmodel_labels = get_model_labels(SBSrunset)
    
    colors = julia_colors(:red, :green, :purple)

    xticks= [[0.1,1.0,10.0,100.0],[1.0,10.0,100.0],[1.0,10.0,100.0]]

    for j in 1:3
        axes[1,j] = Axis(fig[1,j])
    end

    axleft = axes[1,1]
    axmid = axes[1,2]
    axright = axes[1,3]

    #Link axes and hide decorations of non-right and non-bottom axes
    #axis linking is redundant here (the ranges coincide already), but just in case
    linkyaxes!(axleft, axmid)
    linkyaxes!(axleft, axright)
    hideydecorations!(axmid, grid=false)
    hideydecorations!(axright, grid=false)

    #Only show xlabel for middle column
    axleft.xlabelvisible = false 
    axright.xlabelvisible = false 

    axleft.ylabel = emissivity_label()
    axleft.ylabelsize = 22
    axleft.yticklabelsize = 12
    axleft.ytickalign = 1

    for j in 1:3
        ax = axes[1,j]
        for i in 1:3
            data = LBSdata[i,j]
            lines!(ax, data[:,1], data[:,2]; linewidth=2.0, color=colors[i], linestyle=:dot, label=LBSmodel_labels[i])
        end
        data = BHdata[1,j]
        lines!(ax, data[:,1], data[:,2]; linewidth=2.0, color=:black, linestyle=:solid, label=model_label(BH()))
        ylims!(ax, 1e-7, 1e-1)
        xlims!(ax, nothing, 110.0)
        ax.xscale = log10
        ax.yscale = log10
        ax.titlesize = 18
        ax.xlabel = radius_label() 
        
        ax.xlabelsize = 22
        ax.ylabelsize = 22
        ax.xticklabelsize = 15
        ax.yticklabelsize = 15
        ax.xtickalign = 1
        ax.xticks = xticks[j]
        ax.xtickformat = "{:.1f}"
        for i in 1:3
            data = SBSdata[i,j]
            lines!(ax, data[:,1], data[:,2]; linewidth=2.0, color=colors[i], linestyle=:dash, label=SBSmodel_labels[i])
        end
        rad = exp10.(range(log10(0.1), stop=log10(110), length=100))
        lamp = map(r -> flat_lamppost(r, LBSrunset.heights[j]), rad)
        lines!(ax, rad, 0.4lamp; linewidth=2.0, color=:gray, linestyle=:solid, label=flat_lamppost_label())
        supertitle = Label(fig[0,j], height_labels[j], justification=:center, fontsize=18, color=:black)
        supertitle.tellwidth = false
        supertitle.padding = (0.0, 0.0, 1.0, 0.0)
    end

    axislegend(axmid, position=:lb, nbanks = 4, orientation=:horizontal)
    # leg = Legend(fig[1,2], axmid, L"\text{Model}", nbanks = 4, tellwidth=false, tellheight=false, orientation=:horizontal, valign=:bottom)
    colgap!(fig.layout, 0)
    display(fig)
    save(figname, fig)
end

function emissiviy_profile_mosaic_focused(SBSrunset::CoronaRunSet, BHrunset::CoronaRunSet; figname)
    runsets = [SBSrunset, BHrunset]
    have_three_heights(runsets) || throw(ArgumentError("Runsets must have three heights")) 
    have_same_heights(runsets) || throw(ArgumentError("Runsets must have the same heights"))
    has_three_models(SBSrunset) || throw(ArgumentError("Boson star runsets must have three models")) 
    has_one_model(BHrunset) || throw(ArgumentError("Black hole runset must have one model")) 

    SBSdata = emissivity_profile_data(SBSrunset)
    BHdata = emissivity_profile_data(BHrunset)
    
    fig, axes = prepare_mosaic(nrows=1, size=(1000,400))

    height_labels = get_height_labels(SBSrunset)
    SBSmodel_labels = get_model_labels(SBSrunset)
    
    colors = julia_colors(:red, :green, :purple)

    xticks= [[5.0,10.0,15.0,20.0],[10.0,15.0,20.0],[10.0,15.0,20.0]]

    for j in 1:3
        axes[1,j] = Axis(fig[1,j])
    end

    axleft = axes[1,1]
    axmid = axes[1,2]
    axright = axes[1,3]

    #Link axes and hide decorations of non-right and non-bottom axes
    #axis linking is redundant here (the ranges coincide already), but just in case
    linkyaxes!(axleft, axmid)
    linkyaxes!(axleft, axright)
    hideydecorations!(axmid, grid=false)
    hideydecorations!(axright, grid=false)

    #Only show xlabel for middle column
    axleft.xlabelvisible = false 
    axright.xlabelvisible = false 

    axleft.ylabel = emissivity_label()
    axleft.ylabelsize = 22
    axleft.yticklabelsize = 12
    axleft.ytickalign = 1

    for j in 1:3
        ax = axes[1,j]
        for i in 1:3
            data = SBSdata[i,j]
            lines!(ax, data[:,1], data[:,2]; linewidth=2.0, color=colors[i], linestyle=:dot, label=SBSmodel_labels[i])
        end
        data = BHdata[1,j]
        lines!(ax, data[:,1], data[:,2]; linewidth=2.0, color=:black, linestyle=:solid, label=model_label(BH()))
        ylims!(ax, 1e-5, nothing)
        xlims!(ax, 5.0, 21.0)
        # ax.xscale = log10
        ax.yscale = log10
        ax.titlesize = 18
        ax.xlabel = radius_label() 
        
        ax.xlabelsize = 22
        ax.ylabelsize = 22
        ax.xticklabelsize = 15
        ax.yticklabelsize = 15
        ax.xtickalign = 1
        ax.xticks = xticks[j]
        ax.xtickformat = "{:.1f}"
        supertitle = Label(fig[0,j], height_labels[j], justification=:center, fontsize=18, color=:black)
        supertitle.tellwidth = false
        supertitle.padding = (0.0, 0.0, 1.0, 0.0)
    end

    axislegend(axmid, position=:lb, nbanks = 4, orientation=:horizontal)
    # leg = Legend(fig[1,2], axmid, L"\text{Model}", nbanks = 4, tellwidth=false, tellheight=false, orientation=:horizontal, valign=:bottom)
    colgap!(fig.layout, 0)
    display(fig)
    save(figname, fig)
end

function line_emission_mosaic(SBSrunset::CameraRunSet, BHrunset::CameraRunSet, SBScorona_runset::CoronaRunSet, BHcorona_runset::CoronaRunSet; number_of_energy_bins, figname)

    runsets = [SBSrunset, BHrunset, SBScorona_runset, BHcorona_runset]
    have_three_primary_parameters(runsets) || throw(ArgumentError("Runsets must have three secondary parameters (height or inclination)")) 
    have_same_inclinations([SBSrunset, BHrunset]) || throw(ArgumentError("Runsets must have the same inclinations"))
    have_same_heights([SBScorona_runset, BHcorona_runset]) || throw(ArgumentError("Runsets must have the same heights"))
    have_three_models([SBSrunset, SBScorona_runset]) || throw(ArgumentError("Boson star runsets must have three models")) 
    have_one_model([BHrunset, BHcorona_runset]) || throw(ArgumentError("Black hole runset must have one model")) 

    SBSdata = line_emission_data(SBSrunset, SBScorona_runset; number_of_energy_bins = number_of_energy_bins)
    BHdata = line_emission_data(BHrunset, BHcorona_runset; number_of_energy_bins = number_of_energy_bins)

    fig, axes = prepare_mosaic(nrows=3, size=(800, 800))
    inclination_labels = get_inclination_labels(SBSrunset)
    height_labels = get_height_labels(SBScorona_runset)
    model_labels = get_model_labels(SBSrunset) 
    colors = julia_colors(:red, :green, :purple)

    for j in 1:3
        for k in 1:3
            axes[k,j] = Axis(fig[k,j])
            for i in 1:3
                binned_fluxes, bins_edges = SBSdata[i,j,k]
                fmax = maximum(binned_fluxes)
                lines!(axes[k,j], Skylight.midpoints(bins_edges), binned_fluxes/fmax; linewidth=2.0, color=colors[i], linestyle=:dash, label=model_labels[i])
            end
            binned_fluxes, bins_edges = BHdata[1,j,k]
            fmax = maximum(binned_fluxes)
            lines!(axes[k,j], Skylight.midpoints(bins_edges), binned_fluxes/fmax; linewidth=2.0, color=:black, linestyle=:solid, label=model_label(BH()))
        end
    end

    for k in 1:3
        axbottom = axes[3,k]
        axtop = axes[1,k]
        axright = axes[k,3]
        axleft = axes[k,1]
        # axbottom.xlabel = L"\alpha \, [\text{rad}]"
        axbottom.xlabel = line_emission_energy_label()
        axbottom.xlabelvisible = k == 2 #Only show xlabel for middle column
        axbottom.xlabelsize = 22
        axbottom.xticklabelsize = 12
        axbottom.xtickalign = 1
        axbottom.xtickcolor = :white

        axleft.ylabelvisible = k == 2 #Only show ylabel for middle row
        axleft.ylabel = line_emission_flux_label() 
        axleft.ylabelsize = 22
        axleft.yticklabelsize = 12
        axleft.ytickalign = 1

        for l in 1:2
            #Link axes and hide decorations of non-right and non-bottom axes
            #axis linking is redundant here (the ranges coincide already), but just in case
            linkxaxes!(axbottom, axes[l,k])
            hidexdecorations!(axes[l,k], grid=false)
            linkyaxes!(axleft, axes[k,l])
            hideydecorations!(axes[k,l+1], grid=false)
        end

        #Make left ylabel visible again to use as model label
        axright.yaxisposition = :right
        axright.ylabelvisible = true
        axright.ylabel = height_labels[k]
        axright.ylabelsize = 18
        
        supertitle = Label(fig[0,k], inclination_labels[k], justification=:center, fontsize=18, color=:black)
        supertitle.tellwidth = false
        supertitle.padding = (0.0, 0.0, 10.0, 0.0)

    end

    leg = axislegend(axes[2,2], position=:lt, nbanks = 4, orientation=:horizontal)
    colgap!(fig.layout, 1)
    rowgap!(fig.layout, 1)
    display(fig)
    save(figname, fig, pt_per_unit = 0.5)
end

function temperature_plot(LBSrunset::CameraRunSet, SBSrunset::CameraRunSet, BHrunset::CameraRunSet; figname)
    has_three_models(LBSrunset) || throw(ArgumentError("Boson star runsets must have three models")) 
    has_three_models(SBSrunset) || throw(ArgumentError("Boson star runsets must have three models")) 
    has_one_model(BHrunset) || throw(ArgumentError("Black hole runset must have one model")) 

    LBSdata = temperature_data(LBSrunset)
    SBSdata = temperature_data(SBSrunset)
    BHdata = temperature_data(BHrunset)
    
    LBSmodel_labels = get_model_labels(LBSrunset)
    SBSmodel_labels = get_model_labels(SBSrunset)
    colors = julia_colors(:red, :green, :purple)

    fig = Figure(size = (600,600))
    ax = Axis(fig[1,1])

    ax.ylabel = temperature_label()
    ax.ylabelsize = 22
    ax.yticklabelsize = 12
    ax.ytickalign = 1

    for i in 1:3
        data = LBSdata[i]
        lines!(ax, data[:,1], data[:,2]; linewidth=2.0, color=colors[i], linestyle=:dot, label=LBSmodel_labels[i])
    end
    data = BHdata[1]
    lines!(ax, data[:,1], data[:,2]; linewidth=2.0, color=:black, linestyle=:solid, label=model_label(BH()))
    for i in 1:3
        data = SBSdata[i]
        lines!(ax, data[:,1], data[:,2]; linewidth=2.0, color=colors[i], linestyle=:dash, label=SBSmodel_labels[i])
    end
    ylims!(ax, 1e6, 5.3e6)
    xlims!(ax, 0.0, 26.0)
    # ax.xscale = log10
    # ax.yscale = log10
    ax.titlesize = 18
    ax.xlabel = radius_label() 
    
    ax.xlabelsize = 22
    ax.ylabelsize = 22
    ax.xticklabelsize = 15
    ax.yticklabelsize = 15
    ax.xtickalign = 1
    ax.xticks = [0.0,5.0,10.0,15.0,20.0,25.0]
    ax.xtickformat = "{:.1f}"
    # supertitle = Label(fig[0,j], height_labels[j], justification=:center, fontsize=18, color=:black)
    # supertitle.tellwidth = false
    # supertitle.padding = (0.0, 0.0, 1.0, 0.0)
    axislegend(ax, position=:rt, nbanks = 4, orientation=:horizontal)
    # leg = Legend(fig[1,2], axmid, L"\text{Model}", nbanks = 4, tellwidth=false, tellheight=false, orientation=:horizontal, valign=:bottom)
    # colgap!(fig.layout, 0)
    display(fig)
    save(figname, fig)
end

function plot_potential(;FLBS::Union{Nothing,Vector{L}}=nothing, 
    FSBS::Union{Nothing,Vector{S}}=nothing,
    FBH::Union{Nothing,EffectivePotential{BH}}=nothing,
    rin,
    rout, 
    property, 
    logscale) where {L<:EffectivePotential{LBS{Int}}, S<:EffectivePotential{SBS{Int}}}

    fig = Figure(size = (600,600))
    ax = Axis(fig[1,1])
    colors = [:red, :green, :purple]
    if !isa(FBH, Nothing)
        lines!(ax, FBH.r, getproperty(FBH, property); linewidth=2.0, color=:black, linestyle=:solid, label=model_label(FBH))
    end
    if !isa(FLBS, Nothing)
        for F in FLBS
            color = colors[F.model.id]
            lines!(ax, F.r, getproperty(F, property); linewidth=2.0, color=color, linestyle=:dash, label=model_label(F))
        end
    end
    if !isa(FSBS, Nothing)
        for F in FSBS
            color = colors[F.model.id]
            lines!(ax, F.r, getproperty(F, property); linewidth=2.0, color=color, linestyle=:dot, label=model_label(F))
        end
    end
    ax.ylabelsize = 22
    ax.yticklabelsize = 12
    ax.ytickalign = 1
    ax.ylabel = property_label(property)
    ax.xlabel = radius_label() 
    ax.xlabelsize = 22
    ax.ylabelsize = 22
    ax.xticklabelsize = 15
    ax.yticklabelsize = 15
    ax.xtickalign = 1
    ax.xtickformat = "{:.1f}"
    xlims!(ax, rin, rout)
    if logscale
        ax.yscale = log10
    end
    axislegend(ax, nbanks = 1, orientation=:horizontal)
    display(fig)
    save("plots/heat/$(property).png", fig)
end

function plot_factor(;FLBS::Union{Nothing,Vector{L}}=nothing, 
    FSBS::Union{Nothing,Vector{S}}=nothing,
    FBH::Union{Nothing,TemperatureFactors{BH}}=nothing,
    rout, 
    property, 
    ylims,
    logscale) where {L<:TemperatureFactors{LBS{Int}}, S<:TemperatureFactors{SBS{Int}}}

    fig = Figure(size = (600,600))
    ax = Axis(fig[1,1])
    colors = [:red, :green, :purple]
    if !isa(FBH, Nothing)
        lines!(ax, FBH.r, getproperty(FBH, property); linewidth=2.0, color=:black, linestyle=:solid, label=model_label(FBH))
    end
    if !isa(FLBS, Nothing)
        for F in FLBS
            color = colors[F.model.id]
            lines!(ax, F.r, getproperty(F, property); linewidth=2.0, color=color, linestyle=:dash, label=model_label(F))
        end
    end
    if !isa(FSBS, Nothing)
        for F in FSBS
            color = colors[F.model.id]
            lines!(ax, F.r, getproperty(F, property); linewidth=2.0, color=color, linestyle=:dot, label=model_label(F))
        end
    end
    ax.ylabelsize = 22
    ax.yticklabelsize = 12
    ax.ytickalign = 1
    ax.ylabel = property_label(property)
    ax.xlabel = radius_label() 
    ax.xlabelsize = 22
    ax.ylabelsize = 22
    ax.xticklabelsize = 15
    ax.yticklabelsize = 15
    ax.xtickalign = 1
    ax.xtickformat = "{:.1f}"
    ylims!(ax, ylims...)
    xlims!(ax, nothing, rout)
    if logscale
        ax.yscale = log10
    end
    axislegend(ax, nbanks = 1, orientation=:horizontal)
    display(fig)
    save("plots/heat/$(property).png", fig)
end