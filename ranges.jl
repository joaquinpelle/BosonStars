function ranges(filenames)
    qmin = Inf
    qmax = -Inf
    zmin = Inf
    zmax = -Inf
    Fmax = -Inf
    for filename in filenames 
        qminv, qmaxv, zminv, zmaxv, Fmaxv = ranges(filename)
        qmin = min(qmin, qminv)
        qmax = max(qmax, qmaxv)
        zmin = min(zmin, zminv)
        zmax = max(zmax, zmaxv)
        Fmax = max(Fmax, Fmaxv)
    end
    return qmin, qmax, zmin, zmax, Fmax
end

function ranges(filename::AbstractString, num_bins)
    configurations = load_configurations_from_hdf5(filename)
    initial_data = load_initial_data_from_hdf5(filename)
    output_data = load_output_data_from_hdf5(filename, 1)

    Iobs, q = observed_bolometric_intensities(initial_data, output_data, configurations)
    qmin, qmax = extrema(q[q.!=0.0])
    zmin, zmax = extrema(zs)

    binned_fluxes, bins = line_emission_spectrum(initial_data, output_data, configurations; num_bins = num_bins)
    return qmin, qmax, zmin, zmax, maximum(binned_fluxes)
end
