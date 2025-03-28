datafile(params::CameraRunParams) = camera_file(basename(params))
datafile(params::CoronaRunParams) = corona_file(basename(params))

camera_file(basename::AbstractString) = "io/camera/$(basename).h5"
corona_file(basename::AbstractString) = "io/corona/$(basename).txt"
temperature_file(model::AbstractModel) = "io/temperature/Temp$(to_symbol(model)).dat"

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
    Nstr = string(@sprintf("%04d", params.number_of_packets/1e6))
    return "$(dir)/$(modelsymbol)_h$(hstr)_idx$(istr)_np$(Nstr)"
end

modeldir(::AbstractBosonStar) = "bosonstar"
modeldir(::BH) = "schwarzschild"

to_symbol(model::SBS{Int}) = Symbol("SBS", model.id)
to_symbol(model::LBS{Int}) = Symbol("LBS", model.id)
to_symbol(model::ABS{Int}) = Symbol("ABS", model.id+5)
to_symbol(::BH) = :BH