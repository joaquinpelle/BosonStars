abstract type AbstractPotential end

struct SBS <: AbstractPotential end
struct LBS <: AbstractPotential end

abstract type AbstractModel end

struct Schwarzschild <: AbstractModel end
struct BosonStar{T<:AbstractPotential, N} <: AbstractModel 
    potential::T
end

BosonStar(potential::AbstractPotential, N::Int) = BosonStar{typeof(potential), N}(potential)
BosonStars(potential::AbstractPotential, Ns) = [BosonStar(potential, N) for N in Ns]

@with_kw struct RunParams{M<:AbstractModel,T<:Real}
    model::M
    ξ::T 
    number_of_pixels_per_side::Int 
    observation_radius::Float64 
end

abstract type AbstractRunSet end
abstract type AbstractRunParams end

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
    npp::Int = 5000000
    num_radial_bins::Int = 50
end

@with_kw struct CoronaRunSet{M<:AbstractModel,T<:Real} <: AbstractRunSet 
    models::Vector{M}
    heights::Vector{T} 
    spectral_index::Float64
    npp::Int
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
    return RunParams(params.models[modelidx], params.heights[hidx], params.npp, params.num_radial_bins)
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