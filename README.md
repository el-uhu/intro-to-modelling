# Introduction to Modelling Biological Systems
A repository of pluto.jl notebooks introducing fundamental concepts of mathematical modelling of biological systems.

To explore the notebooks, you can either choose the simple, yet somewhat less performant way and check them out via mybinder.org (links provided below), or install julia and the relevant packages on your local machine.

## Using mybinder.org

To explore the notebooks right in your browser, without having to install any additional software, simply click on the links below:

1. **Modelling Basics - Growth** - A brief introduction to the mathematics of differential equations, visual analysis via rateplots and simple growth models [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/el-uhu/intro-to-modelling/HEAD?urlpath=pluto/open?path=/home/jovyan/notebooks/01_modelling-basics_growth.jl)
2. **Modelling Basics - Interacting Populations: Predator-Prey** - A look at models of interacting populations using the Lotka-Volterra model [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/el-uhu/intro-to-modelling/HEAD?urlpath=pluto/open?path=/home/jovyan/notebooks/02_modelling-basics_predator-prey.jl)
3. **Modelling Basics . Epidemic Modelling: SIR Model** - An introduction to epidemic modelling using the classic SIR-Model by Kermack & McKendrick [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/el-uhu/intro-to-modelling/HEAD?urlpath=pluto/open?path=/home/jovyan/notebooks/03_modelling-basics_sir.jl)
4. **SIRVD Model** - An attempt at a more realistic SIR model: including mortality, reinfections and vaccinations [![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/el-uhu/intro-to-modelling/HEAD?urlpath=pluto/open?path=/home/jovyan/notebooks/04_modelling-sirvd.jl)

### Background on Implementation
[mybinder.org](https://mybinder.org/) is a deployment platform for interactive notebooks (mostly jupyter) and is run by the Binder Project. In making pluto.jl notebooks available via binder, I relied heavily on the work discussed in [this thread](https://discourse.julialang.org/t/hosting-interactive-pluto-notebook-on-web-github/47167). Whereas there are simpler methods to deploy pluto notebooks than the one I used here (such as [pluto-on-binder](http://pluto-on-binder.glitch.me/) by the designer of Pluto.jl), they generally work less well for computationally more complex notebooks.

In essence, the implementation works as follows:

1. I use `Dockerfile` to specify a reproducible computational environment (a docker container) that can be spawned on demand and allows you to interact with the underlying code as you explore the notebooks.
2. I use [repo2docker]() in conjunction with Github Actions to pre-build a custom docker image as specified by `Dockerfile`, which is referenced under `binder/Dockerfile` and reduces buildtimes substantially
3. Mybinder.org spawns the docker container on demand and serves static html, while allowing you to interact with the julia processes that underpin the notebook

## Installation

To access the exercises, follow the steps outlined below:

1. Install the julia programming language on your system. Choose the current stable release version (> v1.6) and the installer specific to your platform https://julialang.org/downloads/.
2. Download this folder as *.zip or via git clone (if you're familiar with the latter)
3. Extract the contents of this folder
4. Open the interactive Julia-REPL (console) and change the working directory to the location of the extracted files:
   
```julia
cd("path/to/intro-to-modelling")
```

> :warning: If you are finding it difficult to find the path, you can use the command `pwd()` within the julia REPL to display your current working directory as a starting point.

5. Double-check if you're in the correct directory using the command `readdir()`. - It should display the following contents:

```
julia> readdir()
14-element Vector{String}:
 ".git"
 ".github"
 "Dockerfile"
 "LICENSE"
 "Manifest.toml"
 "Project.toml"
 "README.md"
 "binder"
 "environment.yml"
 "notebooks"
 "plutoserver"
 "postBuild"
 "runpluto.sh"
 "setup.py"
```

## Startup
1. Enter the following commands into the REPL
```julia
using Pluto

Pluto.run()
```

2. Select your desired notebook from the launcher, by specifiying the path to it: `notebooks/01_modelling-basics_growth.jl`or similar.
```
notebooks/
├── 01_modelling-basics_growth.jl
├── 02_modelling-basics_predator-prey.jl
├── 03_modelling-basics_sir.jl
├── 04_modelling-sirvd.jl
```
