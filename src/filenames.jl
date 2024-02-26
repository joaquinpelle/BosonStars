datafile(params::CameraRunParams) = camera_file(basename(params))
datafile(params::CoronaRunParams) = corona_file(basename(params))

camera_file(basename::AbstractString) = "io/camera/$(basename).h5"
corona_file(basename::AbstractString) = "io/corona/$(basename).txt"
temperature_file(model::AbstractModel) = "io/temperature/Temp$(to_string(model)).dat"

function basename(params::CameraRunParams)
    dir = modeldir(params.model)
    modelsymbol = to_symbol(params.model)
    ξstr = string(@sprintf("%02d", params.inclination)) 
    Nstr = string(@sprintf("%04d", params.number_of_pixels_per_side))
    return "$(dir)/$(modelsymbol)_i$(ξstr)deg_N$(Nstr)"
end

function basename(params::CoronaRunParams)
    dir = modeldir(params.model)
    modelsymbol = to_symbol(params.model)
    hstr = string(@sprintf("%.1f", params.height))
    istr = string(@sprintf("%02d", params.spectral_index))
    return "$(dir)/$(modelsymbol)_h$(hstr)_idx$(istr)"
end

modeldir(::AbstractBosonStar) = "bosonstar"
modeldir(::BH) = "schwarzschild"

to_string(model::SBS{Int}) = "SBS$(model.id)"
to_string(model::LBS{Int}) = "LBS$(model.id)"
to_symbol(model::AbstractBosonStar) = (Symbol ∘ to_string)(model)
to_symbol(::BH) = :SCHW