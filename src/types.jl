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

abstract type CollectiveTrait end
struct IsCollective <: CollectiveTrait end
struct IsNotCollective <: CollectiveTrait end

iscollective(::AbstractModel) = IsNotCollective()
iscollective(::SBS{T}) where {T<:CollectiveId} = IsCollective()
iscollective(::LBS{T}) where {T<:CollectiveId} = IsCollective()
iscollective(runset::AbstractRunSet) = iscollective(runset.models)

@with_kw mutable struct TemperatureFactors{M}
    model::M
    N::Int = 100
    r::Vector{Float64} = zeros(N)
    gₜₜ::Vector{Float64} = zeros(N)
    gᵣᵣ::Vector{Float64} = zeros(N)
    sqrtg::Vector{Float64} = zeros(N)
    Ω::Vector{Float64} = zeros(N)
    E::Vector{Float64} = zeros(N)
    L::Vector{Float64} = zeros(N)
    V::Vector{Float64} = zeros(N)
    ∂ᵣΩ::Vector{Float64} = zeros(N)
    ∂ᵣL::Vector{Float64} = zeros(N)
    EmΩL::Vector{Float64} = zeros(N)
    df::Vector{Float64} = zeros(N)
    ∫df::Vector{Float64} = zeros(N)
    Q::Vector{Float64} = zeros(N)
    T::Vector{Float64} = zeros(N)
end

@with_kw mutable struct EffectivePotential{M}
    model::M
    N::Int = 100
    r::Vector{Float64} = zeros(N)
    gₜₜ::Vector{Float64} = zeros(N)
    gᵣᵣ::Vector{Float64} = zeros(N)
    sqrtg::Vector{Float64} = zeros(N)
    Ω::Vector{Float64} = zeros(N)
    E::Vector{Float64} = zeros(N)
    L::Vector{Float64} = zeros(N)
    V::Vector{Float64} = zeros(N)
end