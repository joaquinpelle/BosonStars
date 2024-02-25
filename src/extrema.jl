function zextrema(runsets::Vector{CameraRunSet})
    zmin, zmax = Inf, -Inf
    for runset in runsets
        zminv, zmaxv = zextrema(runset)
        zmin = min(zmin, zminv)
        zmax = max(zmax, zmaxv)
    end
    return zmin, zmax
end

function zextrema(runset::CameraRunSet)
    zmin, zmax = Inf, -Inf
    for i in model_id(runset)
        for j in eachindex(runset.inclinations)
            runparams = get_runparams(runset, i, j)
            zminv, zmaxv = zextrema(runparams)
            zmin = min(zmin, zminv)
            zmax = max(zmax, zmaxv)
        end
    end
    return zmin, zmax
end

function zextrema(runset::CameraRunSet, j::Int)
    zmin = Inf
    zmax = -Inf
    for i in model_id(runset)
        runparams = get_runparams(runset, i, j)
        zminv, zmaxv = zextrema(runparams)
        zmin = min(zmin, zminv)
        zmax = max(zmax, zmaxv)
    end
    return zmin, zmax
end

function zextrema(runparams::CameraRunParams)
    initial_data, output_data, configurations = load_from_hdf5(runparams, 1)
    Iobs = observed_bolometric_intensities(initial_data, output_data, configurations)
    return extrema(Iobs)
end