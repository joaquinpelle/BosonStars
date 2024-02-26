alpha_label() = L"\alpha \, [^\circ]"
beta_label() = L"\beta \, [^\circ]"
radius_label() = L"r / r_g"
thermal_emission_energy_label() = L"E \, [\text{eV}]"
line_emission_energy_label() = L"E / E_0"
intensity_label() = L"I/I_{\text{max}}"
thermal_emission_flux_label() = L"F_E \,[\text{erg} \, \text{cm}^{-2} \, \text{s}^{-1}\,\text{eV}^{-1}]"
line_emission_flux_label() = L"\text{Flux} \, [\text{arbitrary}]"
emissivity_label() = L"\varepsilon (r) \, \, [\text{arbitrary}]"
flat_lamppost_label() = L"I_e(r,h)"

model_label(model::SBS{Int}) = L"\text{SBS%$(model.id)}"
model_label(model::LBS{Int}) = L"\Lambda \text{BS%$(model.id)}"
model_label(::BH) = L"\text{BH}"
get_model_labels(runset::AbstractRunSet) = [model_label(model) for model in runset.models]

height_label(h) = floor(h) == h ? L"h = %$(Int(h)) M" : L"h = %$(h) M"
function get_height_labels(runset::CoronaRunSet)
    return [height_label(h) for h in runset.heights]
end

function get_inclination_labels(runset::CameraRunSet)
    return [L"\xi = %$(xi)^\circ" for xi in runset.inclinations]
end