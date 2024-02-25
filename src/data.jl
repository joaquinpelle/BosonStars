function bolometric_intensity_data(runset::CameraRunSet)
    data = Matrix{Any}(undef, size(runset))
    zmaxcols = zeros_like(runset.inclinations)
    for j in eachindex(runset.inclinations)
        _, zmaxcols[j] = zrange(runset, j)
        for i in model_id(runset)
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

function spectrum_data(runset::CameraRunSet, observation_energies)
    data = Matrix{Any}(undef, size(runset))
    for j in eachindex(runset.inclinations)
        for i in model_id(runset)
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
        for i in model_id(runset)
            runparams = get_runparams(runset, i, j)
            data[i,j] = load_from_file(runparams) 
        end
    end
    return data
end

function line_emission_data(runset::CameraRunSet, corona_runset::CoronaRunSet; number_of__energy_bins)
    have_same_models(runset, corona_runset) || throw(ArgumentError("Runsets must have the same models"))
    data = Array{Any}(undef, size(runset)..., number_of_heights(corona_runset))
    for j in eachindex(runset.inclinations)
        for i in model_id(runset)
            runparams = get_runparams(runset, i, j)
            initial_data, output_data, configurations = load_from_hdf5(runparams)
            for k in eachindex(corona_runset.heights)
                corona_runparams = get_runparams(corona_runset, i, k)
                line_emission_disk = create_line_emission_disk(corona_runparams)
                line_emission_configurations = replace_radiative_model!(configurations, line_emission_disk) 
                binned_fluxes, bins = line_emission_spectrum(initial_data, output_data, line_emission_configurations; num_bins = number_of__energy_bins)
                data[i,j,k] = (binned_fluxes, bins)
            end
        end
    end
    return data
end