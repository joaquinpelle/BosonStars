function inner_radius(model::SBS{Int}) 
    model.id == 1 && return 6.8
    model.id == 2 && return 6.2
    model.id == 3 && return 6.1
end
inner_radius(::LBS) = 0.1
innter_radius(::BH) = 6.0

function outer_radius(model::SBS{Int}) 
    model.id == 1 && return 79.8
    model.id == 2 && return 79.7
    model.id == 3 && return 79.6
end
outer_radius(::LBS) = 79.6
outer_radius(::BH) = 80.0

camera_aperture(params::CameraRunParams) = camera_aperture(params.model)
camera_aperture(::LBS) = 3.5
camera_aperture(::SBS) = 4.25
camera_aperture(::BH) = 4.5

observation_position(params::CameraRunParams) = [0.0, params.observation_radius, deg2rad(params.inclination), 0.0]

cbp_kwargs(runparams::AbstractRunParams) = cbp_kwargs(runparams.model)   
cbp_kwargs(::BH) = (rhorizon_bound=1e-3,)
cbp_kwargs(::AbstractBosonStar) = ()

create_spacetime(params::CameraRunParams) = create_spacetime(params.model)
create_spacetime(model::AbstractBosonStar) = BosonStarSpacetime(to_symbol(model))
create_spacetime(::BH) = SchwarzschildSpacetimeSphericalCoordinates(M=1.0)

create_accretion_disk(params::CameraRunParams) = create_accretion_disk(params.model)
function create_accretion_disk(model::AbstractModel)
    AccretionDiskWithTabulatedTemperature(inner_radius = inner_radius(model), outer_radius = outer_radius(model), filename = temperature_filename(model))
end
function create_line_emission_disk(params::CoronaRunParams)
    AccretionDiskWithTabulatedProfile(inner_radius = inner_radius(params.model), outer_radius = outer_radius(params.model), filename = datafile(params))
end

function create_camera(params::CameraRunParams)
    aperture = camera_aperture(params)
    return PinholeCamera(position = observation_position(params),
                horizontal_aperture_in_degrees = aperture, 
                vertical_aperture_in_degrees = aperture, 
                horizontal_number_of_pixels = params.number_of_pixels_per_side,
                vertical_number_of_pixels = params.number_of_pixels_per_side) 
end

create_plane(params::CameraRunParams) = create_plane(params.model)
create_plane(model::BH) = NovikovThorneDisk(inner_radius = event_horizon_radius(create_spacetime(model))+1e-3+eps(), outer_radius = 100.0)
create_plane(::AbstractBosonStar) = NovikovThorneDisk(inner_radius = 0.0, outer_radius = outer_radius(model))

create_corona(params::CoronaRunParams) = LamppostCorona(height=params.height, theta_offset=1e-5, spectral_index = params.spectral_index)