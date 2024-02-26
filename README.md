# BosonStars

<div align="center">
  <img src="./plots/assets/SBS_mosaic.png" alt="Skylight Logo" width="600"/>
</div>


This repository contains the code for the production runs and plots in ["Thermal emission and line broadening from accretion disks around boson stars"](https://arxiv.org/) by J. L. Rosa, J. Pelle, and D. Perez.

It uses the open-source Julia package [Skylight.jl](https://github.com/joaquinpelle/Skylight.jl) for general-relativistic ray tracing and radiative transfer in arbitrary spacetimes.   

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

We recommend to create a dedicated Pkg environment for this project. You can do so by following these steps:

1. Clone the repository to your local machine
2. Open a terminal and navigate to the repository folder
3. Start Julia by typing `julia` in the terminal
4. Press `]` to enter the Pkg REPL mode
5. Type `activate BosonStars` to create a new project named `BosonStars`
6. Go back to the Julia REPL by pressing `Ctrl+C`
7. Import `Pkg` by typing `using Pkg`
8. Install the registered packages by typing `Pkg.add("CairoMakie")`, `Pkg.add("Colors")`, `Pkg.add("DelimitedFiles")`, `Pkg.add("Parameters")`, and `Pkg.add("Printf")`
9. Install Skylight following the instructions [here](https://joaquinpelle.github.io/Skylight.jl/dev/)

### How to run the code

The `main.jl` file contains a complete example with the parameters used in the preprint. You can run it by simply typing `julia main.jl` in the terminal. Or, from the Julia REPL `include("main.jl")` after activating the Pkg project with the required packages. The simulation data is saved in the `io` folder, whereas the resulting plots will be saved in the `plots` folder. The plotting functions can be run independently from the simulations once the data has been saved, which the `radiative_transfer` function does automatically. An example is in the `plots.jl` file, that can be run assuming the corresponding simulation data has been saved.

### Plot settings

Unfortunately, most of the plot attributes are tailored for the production runs of the preprint. These attributes, like aaxes limits, colorbar ticks, etc., are set inside the corresponding mosaic functions in the `src/mosaics.jl` file, and in the `src/plotattributes.jl` file. You may need to identify and customize these values from the source files to fit your needs.

### SLURM batch submission
There is also an example SLURM batch submission file. Particularly, it is the one used for the production runs on the Serafin supercomputer at [Centro de Computo de Alto Desempeño](https://ccad.unc.edu.ar/), Universidad Nacional de Cordoba. The standard output and error files are directed to the `logs` folder.

### Questions and issues

If you have any questions or issues, please do not hesitate to contact the repository owner or open an issue in this repository.
