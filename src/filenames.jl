to_string(::SBS{Int}) = "SBS$(model.id)"
to_string(::LBS{Int}) = "LBS$(model.id)"
to_symbol(model::SBS{Int}) = (Symbol ∘ to_string)(model)
to_symbol(::BH) = :SCHW

modeldir(::AbstractBosonStar) = "bosonstar"
modeldir(::BH) = "schwarzschild"

function basename(params::CameraRunParams)
    modelsymbol = to_symbol(params.model)
    ξstr = string(@sprintf("%02d", params.inclination)) 
    Nstr = string(@sprintf("%04d", params.number_of_pixels_per_side))
    return "$(modelsymbol)_i$(ξstr)deg_N$(Nstr)"
end

function basename(params::CoronaRunParams)
    modelsymbol = to_symbol(params.model)
    ξstr = string(@sprintf("%02d", params.inclination)) 
    Nstr = string(@sprintf("%04d", params.number_of_pixels_per_side))
    return "$(modelsymbol)_i$(ξstr)deg_N$(Nstr)"
end

function basename(params::CoronaRunParams)
    dir = modeldir(params.model)
    modelsymbol = to_symbol(params.model)
    hstr = string(@sprintf("%.1f", params.height))
    istr = string(@sprintf("%02d", params.spectral_index))
    return "$(dir)/$(modelsymbol)_h$(hstr)_idx$(istr)"
end

datafile(params::CameraRunParams) = datafile(basename(params))
datafile(params::CoronaRunParams) = corona_file(basename(params))
datafile(basename::AbstractString) = "io/$(basename).h5"
corona_file(basename::AbstractString) = "io/corona/$(basename).txt"