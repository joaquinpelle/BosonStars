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

function load_everything(filename)

    configurations = load_configurations_from_hdf5("io/$(filename).h5")
    initial_data = load_initial_data_from_hdf5("io/$(filename).h5")
    output_data = load_output_data_from_hdf5("io/$(filename).h5", 1)

    return initial_data, output_data, configurations
end
function ranges(filenames, num_bins)
    qmin = Inf
    qmax = -Inf
    zmin = Inf
    zmax = -Inf
    Fmax = -Inf
    for filename in filenames
        @assert isa(filename, AbstractString) "filenames must be an array of strings" 
        qminv, qmaxv, zminv, zmaxv, Fmaxv = ranges(filename, num_bins)
        qmin = min(qmin, qminv)
        qmax = max(qmax, qmaxv)
        zmin = min(zmin, zminv)
        zmax = max(zmax, zmaxv)
        Fmax = max(Fmax, Fmaxv)
    end
    return qmin, qmax, zmin, zmax, Fmax
end

function ranges(filename::AbstractString, num_bins)

    initial_data, output_data, configurations = load_everything(filename)
    Iobs, q = observed_bolometric_intensities(initial_data, output_data, configurations)
    qmin, qmax = extrema(q[q.!=0.0])
    zmin, zmax = extrema(Iobs)

    binned_fluxes, bins = line_emission_spectrum(initial_data, output_data, configurations; num_bins = num_bins)
    return qmin, qmax, zmin, zmax, maximum(binned_fluxes)
end
