function inner_radius(model::SBS{Int}) 
    model.id == 1 && return 6.74968
    model.id == 2 && return 6.0 
    model.id == 3 && return 6.0
end
inner_radius(::LBS) = 0.1 
function inner_radius(model::ABS{Int}) 
    model.id == 1 && return 5.56021
    model.id == 2 && return 5.9736 
    model.id == 3 && return 5.95582
end
inner_radius(::BH) = 6.0

function outer_radius(model::SBS{Int}) 
    model.id == 1 && return 79.74968
    model.id == 2 && return 80.0
    model.id == 3 && return 80.0
end
outer_radius(::LBS) = 79.6
outer_radius(::ABS) = 80.0
outer_radius(::BH) = 80.0

minimum_radius(::BH) = (event_horizon_radius∘create_spacetime∘BH)() + 1e-3
minimum_radius(::AbstractBosonStar) = 0.0

camera_aperture(params::CameraRunParams) = camera_aperture(params.model)
camera_aperture(::LBS) = 3.5
camera_aperture(::SBS) = 4.25
camera_aperture(::ABS) = 4.25
camera_aperture(::BH) = 4.5

observation_position(params::CameraRunParams) = [0.0, params.observation_radius, deg2rad(params.inclination), 0.0]

cbp_kwargs(runparams::AbstractRunParams) = cbp_kwargs(runparams.model)   
cbp_kwargs(::BH) = (rhorizon_bound=1e-3,)
cbp_kwargs(::AbstractBosonStar) = ()

create_spacetime(params::AbstractRunParams) = create_spacetime(params.model)
create_spacetime(model::AbstractBosonStar) = BosonStarSpacetime(to_symbol(model))
function create_spacetime(model::ABS)
    @warn "The spacetime for ABS models uses dummy temperature tables that are copies of the SBS models.
    It does not matter if you only want line emission calculations, but be aware!"
    return BosonStarSpacetime(to_symbol(model))
end
create_spacetime(::BH) = SchwarzschildSpacetimeSphericalCoordinates(M=1.0)

create_accretion_disk(params::AbstractRunParams) = create_accretion_disk(params.model)
function create_accretion_disk(model::AbstractModel)
    AccretionDiskWithTabulatedTemperature(inner_radius = inner_radius(model), outer_radius = outer_radius(model), filename = temperature_file(model))
end
function create_line_emission_disk(params::CoronaRunParams)
    Skylight.AccretionDiskWithTabulatedProfile(inner_radius = inner_radius(params.model), outer_radius = outer_radius(params.model), filename = datafile(params))
end

create_plane(params::AbstractRunParams) = create_plane(params.model)
create_plane(model::BH) = NovikovThorneDisk(inner_radius = event_horizon_radius(create_spacetime(model))+1e-3+eps(), outer_radius = 100.0)
create_plane(model::AbstractBosonStar) = NovikovThorneDisk(inner_radius = 0.0, outer_radius = outer_radius(model))

create_corona(params::CoronaRunParams) = LamppostCorona(height=params.height, theta_offset=1e-5, spectral_index = params.spectral_index)

function create_camera(params::CameraRunParams)
    aperture = camera_aperture(params)
    return PinholeCamera(position = observation_position(params),
                horizontal_aperture_in_degrees = aperture, 
                vertical_aperture_in_degrees = aperture, 
                horizontal_number_of_pixels = params.number_of_pixels_per_side,
                vertical_number_of_pixels = params.number_of_pixels_per_side) 
end

function replace_radiative_model(configurations, new_radiative_model)
    return VacuumOTEConfigurations(spacetime = configurations.spacetime,
                                camera = configurations.camera,
                                radiative_model = new_radiative_model,
                                unit_mass_in_solar_masses = configurations.unit_mass_in_solar_masses)
end