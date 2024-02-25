abstract type AbstractModel end
abstract type AbstractBosonStar <: AbstractModel end
struct BH <: AbstractModel end

CollectiveId = Union{AbstractVector{Int},AbstractRange{Int}}

struct SBS{T<:Union{Int,CollectiveId}} <: AbstractBosonStar 
    id::T
    function SBS(id::Int) 
        id in 1:3 || throw(ArgumentError("The id of a SBS must be in the range `1:3`"))
        new{Int}(id)
    end
    function SBS(id::CollectiveId) 
        all(i -> i in 1:3, id) || throw(ArgumentError("The ids must be in the range `1:3`"))
        new{typeof(id)}(id)
    end
end

struct LBS{T<:Union{Int,CollectiveId}} <: AbstractBosonStar 
    id::T
    function LBS(id::Int) 
        id in 1:3 || throw(ArgumentError("The id must be in the range `1:3`"))
        new{Int}(id)
    end
    function LBS(id::CollectiveId) 
        all(i -> i in 1:3, id) || throw(ArgumentError("The ids must be in the range `1:3`"))
        new{typeof(id)}(id)
    end
end

abstract type AbstractRunParams end
abstract type AbstractRunSet end

@with_kw struct CameraRunParams{M<:AbstractModel,T<:Real} <: AbstractRunParams
    model::M
    inclination::T 
    number_of_pixels_per_side::Int 
    observation_radius::Float64 
end

@with_kw struct CameraRunSet{M<:AbstractModel,T<:Real} <: AbstractRunSet
    models::M
    inclinations::T 
    number_of_pixels_per_side::Int 
    observation_radius::Float64 
end

@with_kw struct CoronaRunParams{M<:AbstractModel,T<:Real} <: AbstractRunParams
    model::M
    height::T 
    spectral_index::Float64
    number_of_packets::Int
    number_of_radial_bins::Int
end

@with_kw struct CoronaRunSet{M<:AbstractModel,T<:Real} <: AbstractRunSet
    models::M
    heights::T 
    spectral_index::Float64
    number_of_packets::Int
    number_of_radial_bins::Int
end

function get_run_params(set::CameraRunSet, model_idx::Int, inclination_idx::Int)
    return CameraRunParams(set.models[model_idx], set.inclinations[inclination_idx], set.number_of_pixels_per_side, set.observation_radius)
end

function get_run_params(set::CoronaRunSet, model_idx::Int, height_idx::Int)
    return CoronaRunParams(set.models[model_idx], set.heights[height_idx], set.number_of_packets, set.number_of_radial_bins)
end

primary_parameter(set::CameraRunSet) = set.inclinations
primary_parameter(set::CoronaRunSet) = set.heights

# get_model(params::AbstractRunParams) = params.model

# get_potential(runset::RunSet, modelidx::Int) = get_potential(runset.models[modelidx])
# get_potential(model::BosonStar) = model.potential
# get_potential(model::BH) = model 

model_id(params::AbstractRunSet) = params.model.id
primary_id(params::AbstractRunSet) = (eachindex ∘ primary_parameter)(params)

number_of_inclinations(params::CameraRunParams) = length(params.inclinations)
number_of_heights(params::CoronRunParams) = length(params.heights)