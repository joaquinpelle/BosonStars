# BosonStars

Production runs and plots for the paper ["Thermal emission and line broadening from accretion disks around boson stars"](link here) by J. L. Rosa, J. Pelle, and D. Perez.

We used the open-source Julia package [Skylight.jl](https://github.com/joaquinpelle/Skylight.jl) for general-relativistic ray tracing and radiative transfer in arbitrary spacetimes.   

If you find this code useful for your own work, we kindly request to cite our paper.

### How to run the code

The `main.jl` contains a complete example with the parameters used in the paper. You can run it by simply typing `julia main.jl` in the terminal. The simulation data is saved in the `io` folder, whereas the resulting plots will be saved in the `plots` folder. The plotting functions can be run independently of the simulations once the data has been saved, as for example in the `plots.jl` file.

There is also an example SLURM batch submission file, used for running this code on the Serafin supercomputer at [Centro de Computo de Alto Desempeño, Universidad Nacional de Cordoba](https://ccad.unc.edu.ar/). The standard output and error files are directed to the `logs` folder.

#TODO remove includet from Revise package