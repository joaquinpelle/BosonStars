include("src/BosonStars.jl")

ABSmodels = ABS(1:3)
BHmodel = BH()

ABSrunset = CameraRunSet(models = ABSmodels,
                    inclinations = [5, 45, 85],
                    number_of_pixels_per_side = 1200,
                    observation_radius = 1000.0)

BHrunset = CameraRunSet(models = BHmodel,
                    inclinations = [5, 45, 85],
                    number_of_pixels_per_side = 1200,
                    observation_radius = 1000.0)

radiative_transfer([ABSrunset, BHrunset]; reltol=1e-6, abstol=1e-6)

ABScorona_runset = CoronaRunSet(models = ABSmodels,
                    heights = [2.5, 5.0, 10.0],
                    spectral_index = 2.0,
                    number_of_packets = 5000000,
                    number_of_radial_bins = 50)

BHcorona_runset = CoronaRunSet(models = BHmodel,
                    heights = [2.5, 5.0, 10.0],
                    spectral_index = 2.0,
                    number_of_packets = 5000000,
                    number_of_radial_bins = 50)

radiative_transfer([ABScorona_runset, BHcorona_runset]; reltol=1e-5, abstol=1e-5)

emissiviy_profile_mosaic(SBScorona_runset, BHcorona_runset; figname = "plots/emissivity_mosaic.pdf")
emissiviy_profile_mosaic_focused(SBScorona_runset, BHcorona_runset; figname = "plots/emissivity_mosaic_focused.pdf")

line_emission_mosaic(SBSrunset, BHrunset, SBScorona_runset, BHcorona_runset; number_of_energy_bins = 40, figname = "plots/line_emission_mosaic.pdf")