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

finished_run_message(runparams::AbstractRunParams) = finished_run_message(basename(runparams))
finished_run_message(name::AbstractString) = println("Finished run: $name")

function flat_lamppost(r, h)
    return h/(r^2+h^2)^(3/2)
end

function metric_difference(r, SBSspacetime::BosonStarSpacetime, BHspacetime::AbstractBlackHoleSpacetime)
    position = [0.0, r, π/2, 0.0]
    return abs.(metric(position, SBSspacetime) .- metric(position, BHspacetime))
end

function metric_diagonal_relative_error(r, SBSspacetime::BosonStarSpacetime, BHspacetime::AbstractBlackHoleSpacetime)
    position = [0.0, r, π/2, 0.0]
    gBS = metric(position, SBSspacetime)
    gBH = metric(position, BHspacetime)
    return [1.0-gBS[1,1]/gBH[1,1], 1.0-gBS[2,2]/gBH[2,2], 0.0, 0.0]
end

metric_diagonal_relative_error(6.0, SBSspacetime, BHspacetime)

function second_order_finite_difference!(df, f, x)
    df[1] = (f[2] - f[1])/(x[2] - x[1])
    for i in 2:length(f)-1
        df[i] = (f[i+1] - f[i-1])/(x[i+1] - x[i-1])
    end
    df[end] = (f[end] - f[end-1])/(x[end] - x[end-1])
    return nothing
end
