function bolometric_intensity_data(runset::RunSet)
    data = Matrix{Any}(undef, size(runset))
    zmaxcols = zeros_like(runset.inclinations)
    for j in eachindex(runset.inclinations)
        _, zmaxcols[j] = zrange(runset, j)
        for i in eachindex(runset.models)
            runparams = get_runparams(runset, i, j)
            initial_data, output_data, configurations = load_from_hdf5(runparams)
            Iobs = observed_bolometric_intensities(initial_data, output_data, configurations)
            xs,ys = axes_ranges(configurations.camera)
            zs = grid_view(Iobs, configurations)
            data[i,j] = (xs, ys, zs)
        end
    end
    return data, zmaxcols
end

function spectrum_data(runset::RunSet, observation_energies)
    data = Matrix{Any}(undef, size(runset))
    for j in eachindex(runset.inclinations)
        for i in eachindex(runset.models)
            runparams = get_runparams(runset, i, j)
            initial_data, output_data, configurations = load_from_hdf5(runparams)
            data[i,j] = spectrum(initial_data, output_data, configurations, observation_energies)
        end
    end
    return data
end

function emissivity_profile_data(runset::CoronaRunSet)
    data = Matrix{Any}(undef, size(runset))
    for j in eachindex(runset.heights)
        for i in eachindex(runset.models)
            runparams = get_runparams(runset, i, j)
            data[i,j] = load_from_file(runparams) 
        end
    end
    return data
end

function line_emission_data(runset::RunSet, corona_runset::CoronaRunSet; num_energy_bins)
    have_same_models(runset, corona_runset) || throw(ArgumentError("Runsets must have the same models"))
    data = Array{Any}(undef, size(runset)..., number_of_heights(corona_runset))
    for j in 1:number_of_inclinations(runset)
        for i in 1:number_of_models(runset)
            runparams = get_runparams(runset, i, j)
            initial_data, output_data, configurations = load_from_hdf5(runparams)
            for k in number_of_heights(corona_runset)
                corona_runparams = get_runparams(corona_runset, i, k)
                line_emission_disk = create_line_emission_disk(corona_runparams)
                line_emission_configurations = replace_radiative_model!(configurations, line_emission_disk) 
                binned_fluxes, bins = line_emission_spectrum(initial_data, output_data, line_emission_configurations; num_bins = num_energy_bins)
                data[i,j,k] = (binned_fluxes, bins)
            end
        end
    end
    return data
end