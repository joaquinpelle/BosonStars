abstract type AbstractModel end

struct AbstractBosonStar <: AbstractModel end

struct SBS{N} <: AbstractBosonStar end
struct LBS{N} <: AbstractBosonStar end
struct Schwarzschild <: AbstractModel end

SBS(N) = SBS{N}()
LBS(N) = LBS{N}()

abstract type AbstractRunParams end
abstract type AbstractRunSet end

@with_kw struct RunParams{M<:AbstractModel,T<:Real} <: AbstractRunParams
    model::M
    ξ::T 
    number_of_pixels_per_side::Int 
    observation_radius::Float64 
end

@with_kw struct RunSet{M<:AbstractModel,T<:Real} <: AbstractRunSet
    models::Vector{M}
    inclinations::Vector{T} 
    number_of_pixels_per_side::Int
    observation_radius::Float64 
end

@with_kw struct CoronaRunParams{M<:AbstractModel,T<:Real} <: AbstractRunParams
    model::M
    height::T 
    spectral_index::Float64
    number_of_packets::Int
    num_radial_bins::Int
end

@with_kw struct CoronaRunSet{M<:AbstractModel,T<:Real} <: AbstractRunSet 
    models::Vector{M}
    heights::Vector{T} 
    spectral_index::Float64
    number_of_packets::Int
    num_radial_bins::Int
end

function create_model_set(;LBS_ids=[], 
                    SBS_ids=[], 
                    BH = false)
    models = vcat(BosonStars(LBS(), LBS_ids), BosonStars(SBS(), SBS_ids))
    if BH 
        push!(models, Schwarzschild()) 
    end
    return models
end

function get_runparams(params::RunSet, modelidx, ξidx)
    return RunParams(params.models[modelidx], params.inclinations[ξidx], params.number_of_pixels_per_side, params.observation_radius)
end

function get_runparams(params::CoronaRunSet, modelidx, hidx)
    return RunParams(params.models[modelidx], params.heights[hidx], params.number_of_packets, params.num_radial_bins)
end

iterated_parameter(::RunSet) = params.inclinations
iterated_parameter(::CoronaRunSet) = params.heights

get_model(params::AbstractRunParams) = params.model

get_potential(runset::RunSet, modelidx::Int) = get_potential(runset.models[modelidx])
get_potential(model::BosonStar) = model.potential
get_potential(model::Schwarzschild) = model 

number_of_models(runset::AbstractRunSet) = length(runset.models)
number_of_inclinations(runset::RunSet) = length(runset.inclinations)
number_of_heights(runset::CoronaRunSet) = length(runset.heights)