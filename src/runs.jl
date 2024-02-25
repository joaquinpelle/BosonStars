function make_runs(params::AbstractRunSet; 
                reltol, 
                abstol)
    for i in eachindex(params.models)
        var = iterated_parameter(params)
        for j in eachindex(var)
            runparams = get_runparams(params, i, j)
            make_run(runparams; reltol=reltol, abstol=abstol)
        end
    end
end

function make_run(runparams::CameraRunParams;
                reltol=1e-6, 
                abstol=1e-6)
    spacetime = create_spacetime(runparams)
    disk = create_accretion_disk(runparams)
    camera = create_camera(runparams)
    configurations = VacuumOTEConfigurations(spacetime=spacetime,
                                            camera = camera,
                                            radiative_model = disk,
                                            unit_mass_in_solar_masses=1.0)
    initial_data = initialize(configurations)
    cb, cb_params = callback_setup(configurations; cbp_kwargs(runparams)...)  
    run = integrate(initial_data, configurations, cb, cb_params; method=VCABM(), reltol=reltol, abstol=abstol)
    name = get_basename(runparams) 
    save_to_hdf5(datafile(name), configurations, initial_data, [run]; mode="w")
    finished_run_message(name)
end

function make_run(runparams::CoronaRunParams;
                reltol=1e-5, 
                abstol=1e-5)
    spacetime = create_spacetime(runparams)
    disk = create_accretion_disk(runparams)
    corona = create_corona(runparams)
    configurations = VacuumETOConfigurations(spacetime=spacetime,
                                    radiative_model = corona,
                                    number_of_points=1,
                                    number_of_packets_per_point = number_of_packets, 
                                    max_radius = 110.0,
                                    unit_mass_in_solar_masses=1.0)
    initial_data = initialize(configurations)
    plane = create_plane(runparams)
    cb = callback(spacetime, plane)
    cbp = callback_parameters(spacetime, plane, configurations; cbp_kwargs(runparams)...)
    sim = integrate(initial_data, configurations, cb, cbp; method=VCABM(), reltol=reltol, abstol=abstol)
    output_data = sim.output_data
    I, bins_edges = emissivity_profile(output_data, spacetime, disk, corona; number_of__radial_bins = runparams.number_of__radial_bins)
    name = basename(runparams)
    save_profile(I, bins_edges; filename = corona_file(name))
    finished_run_message(name)
end