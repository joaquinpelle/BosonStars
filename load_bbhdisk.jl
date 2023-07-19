using Skylight
using CairoMakie
using Colors
using Printf

const julia_blue = RGB(0.251, 0.388, 0.847)
const julia_green = RGB(0.22, 0.596, 0.149)
const julia_purple = RGB(0.584, 0.345, 0.698)
const julia_red = RGB(0.796, 0.235, 0.2)

function replot(dirname, obs_times; start_offset::Real, verbose=true)
    qmin, qmax, logzmin, logzmax, Fmax = ranges(dirname, obs_times; start_offset=start_offset)
    if verbose 
        println("Calculated ranges")
    end
    for obs_time in obs_times
        replot(dirname, obs_time; start_offset=start_offset, qmin=qmin, qmax=qmax, Fmax=Fmax, logzmin=logzmin, logzmax=logzmax)
        if verbose
            println("Plotted t = $obs_time")
        end
    end
end

function replot_duplicate(dirname, obs_times; start_offset::Real, dup_offset::Real, verbose=true)
    qmin, qmax, logzmin, logzmax, Fmax = ranges(dirname, obs_times; start_offset=start_offset)
    if verbose 
        println("Calculated ranges")
    end
    for obs_time in obs_times
        replot_duplicate(dirname, obs_time; start_offset=start_offset, dup_offset=dup_offset, qmin=qmin, qmax=qmax, Fmax=Fmax, logzmin=logzmin, logzmax=logzmax)
        if verbose
            println("Plotted t = $obs_time and t = $(obs_time+dup_offset)")
        end
    end
end

function ranges(dirname, obs_times; start_offset::Real)
    qmin = Inf
    qmax = -Inf
    logzmin = Inf
    logzmax = -Inf
    Fmax = -Inf
    for obs_time in obs_times
        qminv, qmaxv, logzminv, logzmaxv, Fmaxv = ranges(dirname, obs_time; start_offset=start_offset)
        qmin = min(qmin, qminv)
        qmax = max(qmax, qmaxv)
        logzmin = min(logzmin, logzminv)
        logzmax = max(logzmax, logzmaxv)
        Fmax = max(Fmax, Fmaxv)
    end
    return qmin, qmax, logzmin, logzmax, Fmax
end

function ranges(dirname, obs_time::Real; start_offset::Real)
    tstr = string(@sprintf("%04d", obs_time-start_offset)) 
    filename = "t$tstr"
    datafile = "$(dirname)/data/$filename.h5"
    configurations = load_configurations_from_hdf5(datafile)
    initial_data = load_initial_data_from_hdf5(datafile)
    output_data = load_output_data_from_hdf5(datafile, 1)

    Iobs, q = observed_bolometric_intensities(initial_data, output_data, configurations)
    qmin = minimum(q[q.!=0.0])
    qmax = maximum(q)
    zs = grid_view(Iobs, configurations)
    zs[zs.!=0.0] = log10.(zs[zs.!=0.0])
    zs[zs.==0.0] .= -40
    logzmin = minimum(zs[zs.!=-40])
    logzmax = maximum(zs)

    binned_fluxes, bins = line_emission_spectrum(initial_data, output_data, configurations; num_bins = 40)
    return qmin, qmax, logzmin, logzmax, maximum(binned_fluxes)
end

function replot(dirname, obs_time::Real; start_offset::Real, qmin=nothing, qmax=nothing, Fmax=nothing, logzmin=nothing, logzmax=nothing)

    t_str = string(@sprintf("%04d", obs_time-start_offset)) 
    filename = "t$t_str"

    datafile = "$(dirname)/data/$filename.h5"
    spectrumfile = "$(dirname)/spectrum/$filename.png"
    imagefile = "$(dirname)/images/$filename.png"

    configurations = load_configurations_from_hdf5(datafile)
    initial_data = load_initial_data_from_hdf5(datafile)
    output_data = load_output_data_from_hdf5(datafile, 1)

    mass_ratio = configurations.spacetime.m[2]/configurations.spacetime.m[1]
    q_str = string(@sprintf("%.1f", mass_ratio)) 
    spin_str = string(@sprintf("%.2f", configurations.spacetime.chi[1]))

    r, ξ, φ = spherical_from_cartesian(configurations.camera.position[2:end]) 
    ξ_str = string(@sprintf("%02d", round(Int,rad2deg(ξ)))) 
    title = "q=$q_str, spin=$spin_str, inclination=$ξ_str deg, time=$t_str M"
    
    model1 = Skylight.BBHDiskBH1(inner_radii=configurations.radiative_model.inner_radii,outer_radii=configurations.radiative_model.outer_radii)
    model2 = Skylight.BBHDiskBH2(inner_radii=configurations.radiative_model.inner_radii,outer_radii=configurations.radiative_model.outer_radii)
    configurations1 = VacuumOTEConfigurations(spacetime=configurations.spacetime,
                                            camera = configurations.camera,
                                            radiative_model = model1,
                                            unit_mass_in_solar_masses=configurations.unit_mass_in_solar_masses)
    configurations2 = VacuumOTEConfigurations(spacetime=configurations.spacetime,
                                            camera = configurations.camera,
                                            radiative_model = model2,
                                            unit_mass_in_solar_masses=configurations.unit_mass_in_solar_masses)

    binned_fluxes, bins = line_emission_spectrum(initial_data, output_data, configurations; num_bins = 40)
    binned_fluxes1, bins1 = line_emission_spectrum(initial_data, output_data, configurations1; num_bins = 40)
    binned_fluxes2, bins2 = line_emission_spectrum(initial_data, output_data, configurations2; num_bins = 40)
    # We calculate midpoints of x to use as x coordinates for y
    bins_midpoints = 0.5*(bins[1:end-1] + bins[2:end])
    bins_midpoints1 = 0.5*(bins1[1:end-1] + bins1[2:end])
    bins_midpoints2 = 0.5*(bins2[1:end-1] + bins2[2:end])

    fig = Figure(resolution = (600, 400), font = "CMU Serif")
    ax = Axis(fig[1, 1], xlabel = L"E/E_0", ylabel = "Flux (arbitrary)", title = title, titlefont=:regular)
    lines!(ax, bins_midpoints, binned_fluxes/Fmax, linewidth = 3, color = julia_green, label="Total")
    lines!(ax, bins_midpoints1, binned_fluxes1/Fmax, linestyle=:dash, linewidth = 3, color = julia_red, label="BH1")
    lines!(ax, bins_midpoints2, binned_fluxes2/Fmax, linestyle=:dash, linewidth = 3, color = julia_blue, label="BH2")
    xlims!(ax, qmin, qmax)
    ylims!(ax, 0, 1.05)
    ax.titlesize = 22
    ax.xlabelsize = 22
    ax.ylabelsize = 22
    ax.xticklabelsize = 15
    ax.yticklabelsize = 15
    axislegend(;labelsize=18, position=:lt)
    CairoMakie.save(spectrumfile, fig)

    Iobs, _ = observed_bolometric_intensities(initial_data, output_data, configurations)
    xs,ys = axes_ranges(configurations.camera)
    zs = grid_view(Iobs, configurations)
    zs[zs.!=0.0] = log10.(zs[zs.!=0.0])
    zs[zs.==0.0] .= -40
    if logzmin === nothing logzmin = minimum(zs[zs.!=-40]) end
    if logzmax === nothing logzmax = maximum(zs) end
    fig = Figure(font = "CMU Serif")
    ax = Axis(fig[1,1], xlabel=L"\alpha", ylabel=L"\beta", ylabelsize = 26, xlabelsize = 26, title=title) 
    hmap = heatmap!(xs, ys, zs; colormap=:gist_heat, interpolate=true, colorrange=(logzmin, logzmax))
    Colorbar(fig[:, end+1], hmap, label=L"\log_{10}(I)", labelsize=26, width = 15, ticksize = 18, tickalign = 1)
    colsize!(fig.layout, 1, Aspect(1, 1.0))
    colgap!(fig.layout, 7)
    CairoMakie.save(imagefile, fig)
    return nothing
end

function replot_duplicate(dirname, obs_time::Real; start_offset::Real, dup_offset::Real, qmin=nothing, qmax=nothing, Fmax=nothing, logzmin=nothing, logzmax=nothing)

    t_str = string(@sprintf("%04d", obs_time-start_offset)) 
    t_str_dup = string(@sprintf("%04d", obs_time-start_offset+dup_offset)) 
    
    filename = "t$t_str"
    filename_dup = "t$t_str_dup"

    datafile = "$(dirname)/data/$filename.h5"
    spectrumfile = "$(dirname)/spectrum/$filename.png"
    imagefile = "$(dirname)/images/$filename.png"
    spectrumfile_dup = "$(dirname)/spectrum/$filename_dup.png"
    imagefile_dup = "$(dirname)/images/$filename_dup.png"

    configurations = load_configurations_from_hdf5(datafile)
    initial_data = load_initial_data_from_hdf5(datafile)
    output_data = load_output_data_from_hdf5(datafile, 1)

    mass_ratio = configurations.spacetime.m[2]/configurations.spacetime.m[1]
    q_str = string(@sprintf("%.1f", mass_ratio)) 
    spin_str = string(@sprintf("%.2f", configurations.spacetime.chi[1]))

    r, ξ, φ = spherical_from_cartesian(configurations.camera.position[2:end]) 
    ξ_str = string(@sprintf("%02d", round(Int,rad2deg(ξ)))) 
    title = "q=$q_str, spin=$spin_str, inclination=$ξ_str deg, time=$t_str M"
    title_dup = "q=$q_str, spin=$spin_str, inclination=$ξ_str deg, time=$t_str_dup M"
    
    model1 = Skylight.BBHDiskBH1(inner_radii=configurations.radiative_model.inner_radii,outer_radii=configurations.radiative_model.outer_radii)
    model2 = Skylight.BBHDiskBH2(inner_radii=configurations.radiative_model.inner_radii,outer_radii=configurations.radiative_model.outer_radii)
    configurations1 = VacuumOTEConfigurations(spacetime=configurations.spacetime,
                                            camera = configurations.camera,
                                            radiative_model = model1,
                                            unit_mass_in_solar_masses=configurations.unit_mass_in_solar_masses)
    configurations2 = VacuumOTEConfigurations(spacetime=configurations.spacetime,
                                            camera = configurations.camera,
                                            radiative_model = model2,
                                            unit_mass_in_solar_masses=configurations.unit_mass_in_solar_masses)

    binned_fluxes, bins = line_emission_spectrum(initial_data, output_data, configurations; num_bins = 40)
    binned_fluxes1, bins1 = line_emission_spectrum(initial_data, output_data, configurations1; num_bins = 40)
    binned_fluxes2, bins2 = line_emission_spectrum(initial_data, output_data, configurations2; num_bins = 40)
    # We calculate midpoints of x to use as x coordinates for y
    bins_midpoints = 0.5*(bins[1:end-1] + bins[2:end])
    bins_midpoints1 = 0.5*(bins1[1:end-1] + bins1[2:end])
    bins_midpoints2 = 0.5*(bins2[1:end-1] + bins2[2:end])

    fig = Figure(resolution = (600, 400), font = "CMU Serif")
    ax = Axis(fig[1, 1], xlabel = L"E/E_0", ylabel = "Flux (arbitrary)", title = title, titlefont=:regular)
    lines!(ax, bins_midpoints, binned_fluxes/Fmax, linewidth = 3, color = julia_green, label="Total")
    lines!(ax, bins_midpoints1, binned_fluxes1/Fmax, linestyle=:dash, linewidth = 3, color = julia_red, label="BH1")
    lines!(ax, bins_midpoints2, binned_fluxes2/Fmax, linestyle=:dash, linewidth = 3, color = julia_blue, label="BH2")
    xlims!(ax, qmin, qmax)
    ylims!(ax, 0, 1.05)
    ax.titlesize = 22
    ax.xlabelsize = 22
    ax.ylabelsize = 22
    ax.xticklabelsize = 15
    ax.yticklabelsize = 15
    axislegend(;labelsize=18, position=:lt)
    CairoMakie.save(spectrumfile, fig)

    fig = Figure(resolution = (600, 400), font = "CMU Serif")
    ax = Axis(fig[1, 1], xlabel = L"E/E_0", ylabel = "Flux (arbitrary)", title = title_dup, titlefont=:regular)
    lines!(ax, bins_midpoints, binned_fluxes/Fmax, linewidth = 3, color = julia_green, label="Total")
    lines!(ax, bins_midpoints2, binned_fluxes2/Fmax, linestyle=:dash, linewidth = 3, color = julia_red, label="BH1")
    lines!(ax, bins_midpoints1, binned_fluxes1/Fmax, linestyle=:dash, linewidth = 3, color = julia_blue, label="BH2")
    xlims!(ax, qmin, qmax)
    ylims!(ax, 0, 1.05)
    ax.titlesize = 22
    ax.xlabelsize = 22
    ax.ylabelsize = 22
    ax.xticklabelsize = 15
    ax.yticklabelsize = 15

    axislegend(;labelsize=18, position=:lt)
    CairoMakie.save(spectrumfile_dup, fig)

    Iobs, _ = observed_bolometric_intensities(initial_data, output_data, configurations)
    xs,ys = axes_ranges(configurations.camera)
    zs = grid_view(Iobs, configurations)
    zs[zs.!=0.0] = log10.(zs[zs.!=0.0])
    zs[zs.==0.0] .= -40
    if logzmin === nothing logzmin = minimum(zs[zs.!=-40]) end
    if logzmax === nothing logzmax = maximum(zs) end
    fig = Figure(font = "CMU Serif")
    ax = Axis(fig[1,1], xlabel=L"\alpha", ylabel=L"\beta", ylabelsize = 26, xlabelsize = 26, title=title) 
    hmap = heatmap!(xs, ys, zs; colormap=:gist_heat, interpolate=true, colorrange=(logzmin, logzmax))
    Colorbar(fig[:, end+1], hmap, label=L"\log_{10}(I)", labelsize=26, width = 15, ticksize = 18, tickalign = 1)
    colsize!(fig.layout, 1, Aspect(1, 1.0))
    colgap!(fig.layout, 7)
    CairoMakie.save(imagefile, fig)
    fig = Figure(font = "CMU Serif")
    ax = Axis(fig[1,1], xlabel=L"\alpha", ylabel=L"\beta", ylabelsize = 26, xlabelsize = 26, title=title_dup) 
    hmap = heatmap!(xs, ys, zs; colormap=:gist_heat, interpolate=true, colorrange=(logzmin, logzmax))
    Colorbar(fig[:, end+1], hmap, label=L"\log_{10}(I)", labelsize=26, width = 15, ticksize = 18, tickalign = 1)
    colsize!(fig.layout, 1, Aspect(1, 1.0))
    colgap!(fig.layout, 7)
    CairoMakie.save(imagefile_dup, fig)
    return nothing
end

function main()
    qnames = ["q05", "q10"]
    snames = ["s00", "s06"]
    inames = ["i45", "i85"]
    for qname in qnames
        for sname in snames
            for iname in inames
                dirname = "/home/jpelle/spn-line/$qname/$sname/$iname/n1000"
                println(dirname)
                if qname == "q05"
                    replot(dirname, 200.0:25.0:1200.0; start_offset=200.0, verbose=false)
                elseif qname == "q10"
                    replot_duplicate(dirname, 200.0:25.0:675.0; start_offset=200.0, dup_offset=500.0, verbose=false)
                end
            end
        end
    end
end

main()