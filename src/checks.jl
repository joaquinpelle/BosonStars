has_boson_stars(runset::AbstractRunSet) = all(m -> isa(m, AbstractBosonStar) , runset.models)
has_three_models(runset::AbstractRunSet) = length(runset.models) == 3
has_one_model(runset::AbstractRunSet) = isa(iscollective(runset), IsNotCollective)
has_three_inclinations(runset::CameraRunSet) = length(runset.inclinations) == 3
has_three_heights(runset::CoronaRunSet) = length(runset.heights) == 3

have_boson_stars(runsets::Vector{T}) where {T<:AbstractRunSet} = all(has_boson_stars, runsets)
have_three_models(runsets::Vector{T}) where {T<:AbstractRunSet} = all(has_three_models, runsets)
have_one_model(runsets::Vector{T}) where {T<:AbstractRunSet} = all(has_one_model, runsets)
have_three_inclinations(runsets::Vector{T}) where {T<:CameraRunSet} = all(has_three_inclinations, runsets)
have_three_heights(runsets::Vector{T}) where {T<:CoronaRunSet} = all(has_three_heights, runsets)
have_same_models(runsets::Vector{T}) where {T<:AbstractRunSet} = all(r -> r.models == runsets[1].models, runsets)
have_same_inclinations(runsets::Vector{T}) where {T<:CameraRunSet} = all(r -> r.inclinations == runsets[1].inclinations, runsets)
have_same_heights(runsets::Vector{T}) where {T<:CoronaRunSet} = all(r -> r.heights == runsets[1].heights, runsets)
have_three_primary_parameters(runsets::Vector{T}) where {T<:AbstractRunSet} = all(r -> length(primary_parameter(r)) == 3, runsets)
have_same_primary_parameters(runsets::Vector{T}) where {T<:AbstractRunSet} = all(r -> primary_parameter(r) == primary_parameter(runsets[1]), runsets)