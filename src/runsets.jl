function get_runparams(runset::CameraRunSet, model_idx::Int, inclination_idx::Int)
    return CameraRunParams(runset.models[model_idx], runset.inclinations[inclination_idx], runset.number_of_pixels_per_side, runset.observation_radius)
end

function get_runparams(runset::CoronaRunSet, model_idx::Int, height_idx::Int)
    return CoronaRunParams(runset.models[model_idx], runset.heights[height_idx], runset.spectral_index, runset.number_of_packets, runset.number_of_radial_bins)
end

primary_parameter(runset::CameraRunSet) = runset.inclinations
primary_parameter(runset::CoronaRunSet) = runset.heights

primary_id(runset::AbstractRunSet) = (eachindex ∘ primary_parameter)(runset)

model_id(runset::AbstractRunSet) = model_id(iscollective(runset), runset) 
model_id(::IsNotCollective, runset::AbstractRunSet) = 1:1
model_id(::IsCollective, runset::AbstractRunSet) = runset.models.id

number_of_models(runset::AbstractRunSet) = length(model_id(runset))
number_of_inclinations(runset::CameraRunSet) = length(runset.inclinations)
number_of_heights(runset::CoronaRunSet) = length(runset.heights)

size(runset::AbstractRunSet) = (number_of_models(runset)), length(primary_parameter(runset))