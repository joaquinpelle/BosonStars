abstract type AbstractModel end
abstract type AbstractBosonStar <: AbstractModel end
struct Schwarzschild <: AbstractModel end

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

@with_kw struct CameraRunParams{M<:AbstractModel,T<:Real} <: AbstractRunParams
    model::M
    inclination::T 
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

# function get_runparams(params::RunSet, modelidx, ξidx)
#     return CameraRunParams(params.models[modelidx], params.inclinations[ξidx], params.number_of_pixels_per_side, params.observation_radius)
# end

# function get_runparams(params::CoronaRunSet, modelidx, hidx)
#     return CoronaRunParams(params.models[modelidx], params.heights[hidx], params.number_of_packets, params.num_radial_bins)
# end

# iterated_parameter(::RunSet) = params.inclinations
# iterated_parameter(::CoronaRunSet) = params.heights

# get_model(params::AbstractRunParams) = params.model

# get_potential(runset::RunSet, modelidx::Int) = get_potential(runset.models[modelidx])
# get_potential(model::BosonStar) = model.potential
# get_potential(model::Schwarzschild) = model 

number_of_models(params::AbstractRunParams) = isa(runset.model.id, Int) ? 1 : length(runset.model)
number_of_inclinations(params::CameraRunParams) = length(runset.inclinations)
number_of_heights(oarans::CoronRunParams) = length(runset.heights)