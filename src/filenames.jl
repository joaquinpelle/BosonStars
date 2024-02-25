to_string(potential::SBS) = "SBS"
to_string(potential::LBS) = "LBS"
to_symbol(potential::AbstractPotential) = (Symbol ∘ to_string)(potential)
to_symbol(model::BosonStar) = Symbol(to_string(model.potential), model.id)
to_symbol(::Schwarzschild) = :SCHW

modeldir(::BosonStar) = "bosonstar"
modeldir(::Schwarzschild) = "schwarzschild"

function basename(params::RunParams)
    modelsymbol = to_symbol(params.model)
    ξstr = string(@sprintf("%02d", ξ)) 
    Nstr = string(@sprintf("%04d", Nres))
    return "$(modelsymbol)_i$(ξstr)deg_N$(Nstr)"
end

function basename(params::CoronaRunParams)
    modelsymbol = to_symbol(params.model)
    ξstr = string(@sprintf("%02d", ξ)) 
    Nstr = string(@sprintf("%04d", Nres))
    return "$(modelsymbol)_i$(ξstr)deg_N$(Nstr)"
end

function basename(runparams::CoronaRunParams)
    dir = modeldir(runparams.model)
    modelsymbol = to_symbol(runparams.model)
    hstr = string(@sprintf("%.1f", runparams.height))
    istr = string(@sprintf("%02d", runparams.spectral_index))
    return "$(dir)/$(modelsymbol)_h$(hstr)_idx$(istr)"
end

datafile(runparams::RunParams) = datafile(basename(runparams))
datafile(runparams::CoronaRunParams) = corona_file(basename(runparams))
datafile(basename::AbstractString) = "io/$(basename).h5"
corona_file(basename::AbstractString) = "io/corona/$(basename).txt"