using Pkg 
Pkg.activate("BosonStars")
using CairoMakie
using Printf
using Colors
using DelimitedFiles
using Skylight
include("src/BosonStars.jl")

models = create_model_set(LBS_ids=1:3, SBS_ids = 1:3, BH = true)
params = RunSet(models = models, inclinations = [5, 45, 85], number_of_pixels_per_side = 1200, observation_radius = 1000.0)
make_runs(params; reltol=1e-6, abstol=1e-6)
corona_params = CoronaRunSet(models = models, heights = [2.5, 5.0, 10.0], spectral_index = 2.0, number_of_packets = 5000000, num_radial_bins = 50)
make_runs(corona_params; reltol=1e-5, abstol=1e-5)