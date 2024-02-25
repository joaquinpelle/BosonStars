function has_unique_potential(runset::CameraRunSet)
    has_only_boson_stars(runset) || throw(ArgumentError("The runset contains models other than Boson Stars"))
    potential = runset.models[1].potential
    for model in runset.models
        if model.potential != potential
            return false
        end
    end
    return true
end

has_only_boson_stars(runset::AbstractRunSet) = all(m -> isa(m, BosonStar) , runset.models)
has_three_models(runset::AbstractRunSet) = length(runset.models) == 3
has_one_model(runset::AbstractRunSet) = length(runset.models) == 1
has_three_inclinations(runset::CameraRunSet) = length(runset.inclinations) == 3
has_three_heights(runset::CoronaRunSet) = length(runset.heights) == 3

have_unique_potentials(runsets::Vector{T}) where {T<:AbstractRunSet} = all(has_unique_potential, runsets)
have_only_boson_stars(runsets::Vector{T}) where {T<:AbstractRunSet} = all(has_only_boson_stars, runsets)
have_three_models(runsets::Vector{T}) where {T<:AbstractRunSet} = all(has_three_models, runsets)
have_one_model(runsets::Vector{T}) where {T<:AbstractRunSet} = all(has_one_model, runsets)

have_three_inclinations(runsets::Vector{CameraRunSet}) = all(has_three_inclinations, runsets)
have_same_inclinations(runsets::Vector{CameraRunSet}) = all(r -> r.inclinations == runsets[1].inclinations, runsets)
have_three_heights(runsets::Vector{CoronaRunSet}) = all(has_three_heights, runsets)
have_same_heights(runsets::Vector{CoronaRunSet}) = all(r -> r.heights == runsets[1].heights, runsets)
have_same_models(runsets::Vector{T}) where {T<:AbstractRunSet} = all(r -> r.models == runsets[1].models, runsets)

have_three_iterated_parameters(runsets::Vector{T}) where {T<:AbstractRunSet} = all(r -> length(iterated_parameter(r)) == 3, runsets)
have_same_iterated_parameters(runsets::Vector{T}) where {T<:AbstractRunSet} = all(r -> iterated_parameter(r) == iterated_parameter(runsets[1]), runsets)