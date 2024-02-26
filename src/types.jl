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
    inclinations::Vector{T} 
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
    heights::Vector{T} 
    spectral_index::Float64
    number_of_packets::Int
    number_of_radial_bins::Int
end

function get_runparams(set::CameraRunSet, model_idx::Int, inclination_idx::Int)
    return CameraRunParams(set.models[model_idx], set.inclinations[inclination_idx], set.number_of_pixels_per_side, set.observation_radius)
end

function get_runparams(runset::CoronaRunSet, model_idx::Int, height_idx::Int)
    return CoronaRunParams(runset.models[model_idx], runset.heights[height_idx], runset.spectral_index, runset.number_of_packets, runset.number_of_radial_bins)
end

primary_parameter(runset::CameraRunSet) = runset.inclinations
primary_parameter(runset::CoronaRunSet) = runset.heights

abstract type CollectiveTrait end
struct IsCollective <: CollectiveTrait end
struct IsNotCollective <: CollectiveTrait end

iscollective(::AbstractModel) = IsNotCollective()
iscollective(::SBS{T}) where {T<:CollectiveId} = IsCollective()
iscollective(::LBS{T}) where {T<:CollectiveId} = IsCollective()
iscollective(runset::AbstractRunSet) = iscollective(runset.models)

model_id(runset::AbstractRunSet) = model_id(iscollective(runset), runset) 
model_id(::IsNotCollective, runset::AbstractRunSet) = 1:1
model_id(::IsCollective, runset::AbstractRunSet) = runset.models.id

primary_id(runset::AbstractRunSet) = (eachindex ∘ primary_parameter)(runset)

number_of_inclinations(runset::CameraRunSet) = length(runset.inclinations)
number_of_heights(runset::CoronaRunSet) = length(runset.heights)