function update_configurations_in_hdf5(runsets::Vector{T}; reltol, abstol) where {T<:AbstractRunSet}
    for runset in runsets
        update_configurations_in_hdf5(runset; reltol=reltol, abstol=abstol)
    end
end

function update_configurations_in_hdf5(runset::AbstractRunSet;
                reltol, 
                abstol)
    for i in model_id(runset)
        for j in primary_id(runset)
            runparams = get_runparams(runset, i, j)
            update_configurations_in_hdf5(runparams; reltol=reltol, abstol=abstol)
        end
    end
end

function update_configurations_in_hdf5(runparams::CameraRunParams;
                reltol, 
                abstol)

    initial_data, output_data, _ = load_from_hdf5(runparams,1)
    
    spacetime = create_spacetime(runparams)
    disk = create_accretion_disk(runparams)
    camera = create_camera(runparams)
    configurations = VacuumOTEConfigurations(spacetime=spacetime,
                                            camera = camera,
                                            radiative_model = disk,
                                            unit_mass_in_solar_masses=1.0)

    cb_kwargs = cbp_kwargs(runparams)
    cb, cb_params = callback_setup(configurations; cb_kwargs...)  
    kwargs_dict = Skylight.collect_args(VCABM(), reltol, abstol; cb_kwargs...)
    run = Skylight.Run(output_data, cb, cb_params, kwargs_dict)
    save_to_hdf5(datafile(runparams), configurations, initial_data, [run]; mode="w")
    finished_run_message(runparams)
end