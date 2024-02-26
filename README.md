# BosonStars

Production runs and plots for the paper ["Thermal emission and line broadening from accretion disks around boson stars"](link here) by J. L. Rosa, J. Pelle, and D. Perez.

We used the open-source Julia package [Skylight.jl](https://github.com/joaquinpelle/Skylight.jl) for general-relativistic ray tracing and radiative transfer in arbitrary spacetimes.   

If you find this code useful for your own work, we kindly request to cite our paper.

#### How to run the code

The `main.jl` contains a complete example with the parameters used in the paper. You can run it by simply typing `julia main.jl` in the terminal. The simulation data is saved in the `io` folder, whereas the resulting plots will be saved in the `plots` folder. The plotting functions can be run independently of the simulations once the data has been saved, as for example in the `plots.jl` file.

#### Plot settings
Keep in mind that most of the plot settings are tailored for the production runs of the paper. These settings, like axes scales, axes limits, colorbar ticks, etc. are set inside the corresponding mosaic functions in the `mosaics.jl` file. You may need to customize the values from there to fit your needs.

#### SLURM batch submission
There is also an example SLURM batch submission file, used for running this code on the Serafin supercomputer at [Centro de Computo de Alto Desempeño](https://ccad.unc.edu.ar/), Universidad Nacional de Cordoba. The standard output and error files are directed to the `logs` folder.

#### Questions and issues

If you have any questions or issues, please do not hesitate to contact the repository owner or open an issue in this repository.

#TODO remove Revise and Pkg environment