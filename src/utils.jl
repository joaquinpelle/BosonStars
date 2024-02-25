function replace_radiative_model(configurations, new_radiative_model)
    return VacuumOTEConfigurations(spacetime = configurations.spacetime,
                                camera = configurations.camera,
                                radiative_model = new_radiative_model,
                                unit_mass_in_solar_masses = configurations.unit_mass_in_solar_masses)
end

function flat_lamppost(r, h)
    return h/(r^2+h^2)^(3/2)
end

finished_run_message(name) = println("Finished run: $name")

function prepare_mosaic(; nrows, size)
    paxes = Matrix{Axis}(undef, nrows, 3)
    set_theme!(; fonts = (; regular = "Times New Roman"))
    layout = GridLayout(nrows, 3)
    fig = Figure(layout = layout, size = size)
    return fig, paxes
end

function rescale_axes(xs, ys)
    xs = rad2deg.(xs)
    ys = rad2deg.(ys)
    return xs, ys
end

size(runset::AbstractRunSet) = (length(runset.models), length(iterated_parameter(runset)))

colorbar_label() = L"I/I_{\text{max}}"
get_cbar_ticks(::LBS) = [[0.0,0.02,0.05],[0.0, 0.1, 0.2],[0.0, 0.5, 1.0]]
get_cbar_ticks(::SBS) = [[0.0,0.002,0.004],[0.0, 0.005, 0.01, 0.015],[0.01, 0.02, 0.03]]
get_cbar_ticks(::Schwarzschild) = [[0.0,0.002,0.004],[0.0, 0.005, 0.01, 0.015],[0.01, 0.02, 0.03]]

xaxis_label() = L"\alpha \, [^\circ]"
yaxis_label() = L"\beta \, [^\circ]"

function model_label(model::BosonStar)
    symbol = to_symbol(model)
    return L"\text{%$(symbol)}"
end

model_label(::Schwarzschild) = L"\text{BH}"
model_labels(runset::AbstractRunSet) = [model_label(model) for model in runset.models]

function get_inclination_labels(runset::RunSet)
    return [L"\xi = %$(xi)^\circ" for xi in runset.inclinations]
end

function get_height_labels(runset::CoronaRunSet)
    return [L"h = %$(h) M" for h in runset.heights]
end

energy_label() = L"E \, [\text{eV}]"
line_emission_energy_label() = L"E / E_0"
radius_label() = L"r / r_g"
flux_label() = L"F_E \,[\text{erg} \, \text{cm}^{-2} \, \text{s}^{-1}\,\text{eV}^{-1}]"
line_emission_flux_label() = L"\text{Flux} \, [\text{arbitrary}]"
emissivity_label() = L"\varepsilon (r) \, \, [\text{arbitrary}]"
flat_lamppost_label() = L"I_e(r,h)"

function mylimits!(ax; lim=30)
    limits!(ax, -lim, lim, -lim, lim)
end

function julia_colors(args...)
    colors = []
    for arg in args
        push!(colors, julia_color(arg))
    end
    return colors
end

function julia_color(s::Symbol)
    if s == :red
        color = RGB(0.796, 0.235, 0.2)
    elseif s == :blue
        color = RGB(0.251, 0.388, 0.847)
    elseif s == :green
        color = RGB(0.22, 0.596, 0.149)
    elseif s == :purple
        color = RGB(0.584, 0.345, 0.698)
    else
        throw(ArgumentError("Color not found"))
    end
    return color
end