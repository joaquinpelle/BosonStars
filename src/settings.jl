inner_radius(::BosonStar{SBS,1}) = 6.8
inner_radius(::BosonStar{SBS,2}) = 6.2
inner_radius(::BosonStar{SBS,3}) = 6.1
inner_radius(::BosonStar{LBS, N}) where N = 0.1
innter_radius(::Schwarzschild) = 6.0

outer_radius(::BosonStar{SBS,1}) = 79.8
outer_radius(::BosonStar{SBS,2}) = 79.7
outer_radius(::BosonStar{SBS,3}) = 79.6
outer_radius(::BosonStar{LBS, N}) where N = 79.6
outer_radius(::Schwarzschild) = 80.0

camera_aperture(params::RunParams) = camera_aperture(params.model)
camera_aperture(::BosonStar{LBS, N}) where N = 3.5
camera_aperture(::BosonStar{SBS, N}) where N = 4.25
camera_aperture(::Schwarzschild) = 4.5

observation_position(params::RunParams) = [0.0, params.observation_radius, deg2rad(params.ξ), 0.0]

cbp_kwargs(runparams::AbstractRunParams) = cbp_kwargs(runparams.model)   
cbp_kwargs(::Schwarzschild) = (rhorizon_bound=1e-3,)
cbp_kwargs(::BosonStar) = ()

create_spacetime(params::RunParams) = create_spacetime(params.model)
create_spacetime(model::BosonStar) = BosonStarSpacetime(to_symbol(model))
create_spacetime(::Schwarzschild) = SchwarzschildSpacetimeSphericalCoordinates(M=1.0)

create_accretion_disk(params::RunParams) = create_accretion_disk(params.model)
function create_accretion_disk(model::AbstractModel)
    AccretionDiskWithTabulatedTemperature(inner_radius = inner_radius(model), outer_radius = outer_radius(model), filename = temperature_filename(model))
end
function create_line_emission_disk(params::CoronaRunParams)
    AccretionDiskWithTabulatedProfile(inner_radius = inner_radius(params.model), outer_radius = outer_radius(params.model), filename = datafile(params))
end

function create_camera(params::RunParams)
    aperture = camera_aperture(params)
    return PinholeCamera(position = observation_position(params),
                horizontal_aperture_in_degrees = aperture, 
                vertical_aperture_in_degrees = aperture, 
                horizontal_number_of_pixels = params.number_of_pixels_per_side,
                vertical_number_of_pixels = params.number_of_pixels_per_side) 
end

create_plane(params::RunParams) = create_plane(params.model)
create_plane(model::Schwarzschild) = NovikovThorneDisk(inner_radius = event_horizon_radius(create_spacetime(model))+1e-3+eps(), outer_radius = 100.0)
create_plane(::BosonStar) = NovikovThorneDisk(inner_radius = 0.0, outer_radius = outer_radius(model))

create_corona(runparams::CoronaRunParams) = LamppostCorona(height=runparams.height, theta_offset=1e-5, spectral_index = runparams.spectral_index)