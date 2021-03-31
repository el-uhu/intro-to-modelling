# Introduction to Modelling
A repository of pluto.jl notebooks introducing fundamental concepts of mathematical modelling

## Installation

To access the exercises, follow the steps outlined below:

1. Install the julia programming language on your system. Choose the current stable release version (> v1.5) and the installer specific to your platform https://julialang.org/downloads/.
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
7-element Array{String,1}:
 ".git"
 "Manifest.toml"
 "Project.toml"
 "README.md"
 "modelling-basics_growth.jl"
 "modelling-predator-prey.jl"
 "modelling-sir.jl"
```

6. Press the key `]`, to activate julia's package manager. The prompt in the REPL should change to from `julia>` to `pkg>`.
7. Type in `activate .` (don't forget the `.`) and press `Enter` to load the dependencies. The prompt should change from `pkg>` to `(intro-to-modelling) pkg>`.
8. Type in `instantiate` to install the dependencies.

## Startup
1. Type in `include(start-notebooks.jl)` to load the dependencies (may take a while the first time you do it) and then launch a browser that takes you to the welcome page.
2. Select your desired notebook from the launcher.

