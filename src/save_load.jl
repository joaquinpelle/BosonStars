function save_profile(I, bins_edges; filename)
    open(filename, "w") do io
        writedlm(io, [bins_edges I])
    end
end

function load_run_from(file::AbstractString, runid::Int)
    initial_data = load_initial_data_from_hdf5(file)
    output_data = load_output_data_from_hdf5(file, runid)
    return initial_data, output_data
end

function load_from_hdf5(file::AbstractString, runid::Int)
    initial_data, output_data = load_run_from(file, runid)
    configurations = load_configurations_from_hdf5(file)
    return initial_data, output_data, configurations
end

load_from_hdf5(runparams::CameraRunParams, runid::Int) = load_from_hdf5(datafile(runparams), runid)
load_from_file(runparams::CoronaRunParams) = readdlm(datafile(runparams), '\t', Float64, '\n')