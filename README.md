# BosonStars

<div align="center">
  <img src="./plots/assets/SBS_mosaic.png" alt="Skylight Logo" width="600"/>
</div>


This repository contains the code for the production runs and plots in ["Relativistic thermal emission and line broadening from accretion disks around boson stars"](https://arxiv.org/) by J. L. Rosa, J. Pelle, and D. Perez.

It uses the open-source Julia package [Skylight](https://github.com/joaquinpelle/Skylight.jl) for general-relativistic ray tracing and radiative transfer in arbitrary spacetimes.   

If you find this codebase useful for your own work, we kindly request to cite our preprint.

### Requirements

The code requires Julia (version at least 1.6), and the following Julia packages to be installed:

- CairoMakie
- Colors
- DelimitedFiles
- Parameters
- Printf
- Skylight 

### Installation

We recommend to create a dedicated Pkg project for this code. You can do so by following these steps:

1. Clone this repository and the [Skylight repository](https://github.com/joaquinpelle/Skylight.jl) to your local machine
2. Open a terminal and navigate to this repository's folder
3. Start Julia by typing `julia` in the terminal
4. Press `]` to enter the Pkg REPL mode
5. Type `activate <ProjectName>` to create a new project replacing `<ProjectName>` with the name of your choice
6. Install the registered packages by typing `add CairoMakie`, `add Colors`, `add DelimitedFiles`, `add Parameters`, and `add Printf`
7. Add Skylight by typing `dev <PathToSkylight>` in the Pkg REPL mode, where `<PathToSkylight>` is the path to the cloned Skylight repository

### How to run the code

The `main.jl` file contains a complete example with the parameters used in the preprint. You can run it by simply typing `julia --project=<ProjectName> main.jl` in the terminal where `<ProjectName>` is the project created in the previous step. Or, from the Julia REPL, `using Pkg`, `Pkg.activate("<ProjectName>")`, and `include("main.jl")`. The Skylight package supports multithreading, so you can take advantage of this by adding the option `julia -t=N`, where `N` is the number of threads to use, or by setting the `JULIA_NUM_THREADS` bash environment variable to `N`. 

The `radiative_transfer` function runs the simulations and automatically saves the data in the `io` folder. On the other hand, the resulting plots will be saved in the `plots` folder. The plotting functions can be run independently from the simulations once the data has been saved. As an example, see the `plots.jl` file, that can be executed independently, assuming the corresponding simulation data has been saved already. This is useful for re-processing high-resolution data without having to re-run it.

### Plot settings

Unfortunately, most of the plot attributes are tailored for the production runs of the preprint. These attributes, like axes limits, colorbar ticks, etc., are set inside the corresponding mosaic functions in the `src/plots.jl` file, and in the `src/plotattributes.jl` file. You may need to identify and customize these values from the source files to fit your own needs.

### SLURM batch submission
There is also an example SLURM batch submission file. Particularly, it is the one used for the production runs on the Serafin supercomputer at [Centro de Computo de Alto Desempeño](https://ccad.unc.edu.ar/), Universidad Nacional de Cordoba. The standard output and error files are directed to the `logs` folder.

### Questions and issues

If you have any questions or issues, please do not hesitate to contact the repository owner or open an issue in this repository.
