alpha_label() = L"\alpha \, [^\circ]"
beta_label() = L"\beta \, [^\circ]"
radius_label() = L"r / M"
temperature_label() = L"T \, [\text{K}]"
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

get_cbar_ticks(::LBS) = [[0.0,0.02,0.05],[0.0, 0.1, 0.2],[0.0, 0.5, 1.0]]
get_cbar_ticks(::SBS) = [[0.0,0.002,0.004],[0.0, 0.005, 0.01, 0.015],[0.01, 0.02, 0.03]]
get_cbar_ticks(::BH) = [[0.0,0.0005,0.0015],[0.0, 0.002, 0.004],[0.0, 0.004, 0.008]]

model_label(F::TemperatureFactors) = model_label(F.model)
function property_label(property)
    if property == :sqrtg
        return L"\text{sqrt}(-g)"
    elseif property == :gₜₜ
        return L"g_{tt}"
    elseif property == :gᵣᵣ
        return L"g_{rr}"
    elseif property == :Ω
        return L"\Omega"
    elseif property == :E
        return L"E"
    elseif property == :L
        return L"L"
    elseif property == :∂ᵣΩ
        return L"\partial_r \Omega"
    elseif property == :∂ᵣL
        return L"\partial_r L"
    elseif property == :EmΩL
        return L"E - \Omega L"
    elseif property == :df
        return L"(E - \Omega L) \partial_r L \, dr"
    elseif property == :∫df
        return L"\int (E - \Omega L) \partial_r L \, dr"
    elseif property == :Q
        return L"Q"
    elseif property == :T
        return L"T"
    elseif property == :V
        return L"V_\text{eff}"
    else
        return "Unknown property"
    end
end