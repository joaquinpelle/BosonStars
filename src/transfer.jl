function radiative_transfer(runsets::Vector{T}; reltol, abstol) where {T<:AbstractRunSet}
    for runset in runsets
        radiative_transfer(runset; reltol=reltol, abstol=abstol)
    end
end

function radiative_transfer(runset::AbstractRunSet;
                reltol, 
                abstol)
    for i in model_id(runset)
        for j in primary_id(runset)
            runparams = get_runparams(runset, i, j)
            radiative_transfer(runparams; reltol=reltol, abstol=abstol)
        end
    end
end

function radiative_transfer(runparams::CameraRunParams;
                reltol, 
                abstol)
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
    save_to_hdf5(datafile(runparams), configurations, initial_data, [run]; mode="w")
    finished_run_message(runparams)
end

function radiative_transfer(runparams::CoronaRunParams;
                reltol=1e-5, 
                abstol=1e-5)
    spacetime = create_spacetime(runparams)
    disk = create_accretion_disk(runparams)
    corona = create_corona(runparams)
    configurations = VacuumETOConfigurations(spacetime=spacetime,
                                    radiative_model = corona,
                                    number_of_points=1,
                                    number_of_packets_per_point = runparams.number_of_packets, 
                                    max_radius = 110.0,
                                    unit_mass_in_solar_masses=1.0)
    initial_data = initialize(configurations)
    plane = create_plane(runparams)
    cb = callback(spacetime, plane)
    cbp = callback_parameters(spacetime, plane, configurations; cbp_kwargs(runparams)...)
    sim = integrate(initial_data, configurations, cb, cbp; method=VCABM(), reltol=reltol, abstol=abstol)
    output_data = sim.output_data
    I, bins_edges = emissivity_profile(output_data, spacetime, disk, corona; nbins = runparams.number_of_radial_bins)
    save_profile(I, bins_edges; filename = datafile(runparams))
    finished_run_message(runparams)
end