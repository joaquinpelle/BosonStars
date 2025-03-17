include("src/BosonStars.jl")

function initcamera(; number_of_pixels_per_side = 1200)
    ABSmodels = ABS(1:3)
    BHmodel = BH()
    ABSrunset = CameraRunSet(models = ABSmodels,
                        inclinations = [5, 45, 85],
                        number_of_pixels_per_side = number_of_pixels_per_side,
                        observation_radius = 1000.0)

    BHrunset = CameraRunSet(models = BHmodel,
                        inclinations = [5, 45, 85],
                        number_of_pixels_per_side = number_of_pixels_per_side,
                        observation_radius = 1000.0)
    return ABSrunset, BHrunset
end

function transfercamera(; reltol=1e-6, abstol=1e-6)
    ABSrunset, BHrunset  = initcamera()
    radiative_transfer([ABSrunset, BHrunset]; reltol=reltol, abstol=abstol)
end

function initcorona(; number_of_packets = 5000000, number_of_radial_bins = 50)
    ABSmodels = ABS(1:3)
    BHmodel = BH()
    ABScorona_runset = CoronaRunSet(models = ABSmodels,
                        heights = [2.5, 5.0, 10.0],
                        spectral_index = 2.0,
                        number_of_packets = number_of_packets,
                        number_of_radial_bins = number_of_radial_bins)

    BHcorona_runset = CoronaRunSet(models = BHmodel,
                        heights = [2.5, 5.0, 10.0],
                        spectral_index = 2.0,
                        number_of_packets = number_of_packets,
                        number_of_radial_bins = number_of_radial_bins)
    return ABScorona_runset, BHcorona_runset
end

function maincorona(; reltol=1e-5, abstol=1e-5)
    ABScorona_runset, BHcorona_runset = initcorona()
    radiative_transfer([ABScorona_runset, BHcorona_runset]; reltol=reltol, abstol=abstol)
    emissiviy_profile_mosaic(ABScorona_runset, BHcorona_runset; figname = "plots/emissivity_mosaic.pdf")
    emissiviy_profile_mosaic_focused(ABScorona_runset, BHcorona_runset; figname = "plots/emissivity_mosaic_focused.pdf")
end

function plotlines(; number_of_energy_bins = 40)
    ABSrunset, BHrunset = initcamera() 
    ABScorona_runset, BHcorona_runset = initcorona()
    line_emission_mosaic(ABSrunset, BHrunset, ABScorona_runset, BHcorona_runset; number_of_energy_bins = number_of_energy_bins, figname = "plots/line_emission_mosaic.pdf")
end