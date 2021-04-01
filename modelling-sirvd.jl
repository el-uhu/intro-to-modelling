### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 430d5134-92af-11eb-1fcc-d71f5216d62a
#Set up the working environment
begin
	using Pkg
	Pkg.activate(".")
	using Plots, PlutoUI,LaTeXStrings, DifferentialEquations
end

# ╔═╡ 5adc7e34-92af-11eb-2cfe-67899a4a0291
md"""
## Attempting a more realistic model

Next, we'll try to make the model more realistic by including **reinfection**, **vaccination** and **mortalitiy**.

##### Mortality
We'll only consider deaths of infected people at a mortality rate $m$: $$I \xrightarrow{m} D$$

##### Vaccination & Reinfection
To account for vaccination, we'll assume that
1. The rate of infection is different for vaccinated people $V$ and susceptible people $S$, represented by a *vaccination immunity factor*, $i_v < 1$

$$S \xrightarrow{r_s} I \xleftarrow{r_s \cdot i_v} V$$

2. Likewise, susceptible people $S$ and recovered people $R$ become infected at different rates, represented by an *recovered immunity factor*, $i_r < 1$ that lowers the infection risk

$$S \xrightarrow{r_s} I \xleftarrow{r_s \cdot i_r} R$$

3. We assume that recovered people $R$ and susceptible people $S$ are vaccinated at the same rate $v$ 

$$S \xrightarrow{v} V \xleftarrow{v} R$$

Taken together, this yields the following set of differential equations:

$$\begin{align}
	\frac{dS}{dt} = -rSI -vS\\
	\frac{dV}{dt} = vS + vR - i_v r VI\\
	\frac{dD}{dt} = mI\\
	\frac{dR}{dt} = aI - i_r rRI - vR\\
	\frac{dI}{dt} = rSI + i_r rRI + i_v r VI - mI - aI
\end{align}$$

"""

# ╔═╡ 7a19b238-92af-11eb-30fd-b189d06a0882
md""" ## Simulation
*Change the sliders to adjust the corresponding values*:

| parameter                   | value                     |
|-----------------------------|---------------------------|
| transmission rate $r$       | $(@bind r2 Slider(0:0.005:1, default=0.125, show_value=true)) |
| recovery rate $a$           | $(@bind a2 Slider(0:0.001:0.25, default=0.1, show_value=true))|
| rate of vaccination $v$     | $(@bind v2 Slider(0:0.0001:0.01, default=0.0008, show_value=true)) |
| mortality $m$               | $(@bind m2 Slider(0:0.0001:0.05, default=0.0006, show_value=true)) |
| % immunity recovered        | $(@bind ir Slider(0:1.0:100.0, default=60, show_value=true)) |
| % immunity vaccinated       | $(@bind iv Slider(0:1.0:100.0, default=90, show_value=true)) |
|  $I(0)$                     | $(@bind I02 Slider(0.0001:0.001:0.1, default=0.004, show_value=true)) |
|  $R(0)$                     | $(@bind R02 Slider(0:0.001:0.1, default=0.055,show_value=true)) |
| $V(0)$                      | $(@bind V02 Slider(0:0.001:0.1, default=0.048,show_value=true)) |
| $D(0)$                      | $(@bind D02 Slider(0:0.001:0.1, default=0.001,show_value=true)) |
| timespan $t_{max}$          | $(@bind tmax2 Slider(10.0:10.0:2000.0, default=100.0,show_value=true)) days | 
| zoom y-axis                 | $(@bind ymax2 Slider(0.001:0.001:1.0, default=1.0,show_value=true)) |
| Population size             | $(@bind popsize NumberField(500000:10000000000, default=9044650)) |
"""

# ╔═╡ 8f867f9a-92af-11eb-3671-43904aa74d8b
function getres(solution, i, t, p)
	v = solution(t)[i]*p
	return round(maximum([0.0 v]))
end

# ╔═╡ 96d8a5c2-92af-11eb-1d3f-9bdd035eafec
#S, I, R, V, D
function sirvd!(du,u,p,t)
	du[1] = -u[1] * ( p[1] * u[2] + p[3])
	du[2] = u[2] * (p[1] * (u[1] + p[5] * u[4] + p[4] * u[3]) - p[6] - p[2])
	du[3] = p[2] * u[2] - u[3] * ( p[1] * p[4] *  u[2] + p[3])
	du[4] = p[3] * (u[1] + u[3]) - u[4] * u[2] * p[1] * p[5]
	du[5] = p[6] * u[2]
end

# ╔═╡ 9c0dfe82-92af-11eb-3192-49c2deac6e9b
p2 = [r2, a2, v2, (100 - ir)/100, (100 - iv)/100, m2]

# ╔═╡ a1e4ca5e-92af-11eb-1c40-410a8d3abaca
u02 = [1-I02-R02-V02-D02, I02, R02, V02, D02]

# ╔═╡ ada6253e-92af-11eb-0e32-d9760ab88271
tspan2 = (0.0, 2000)

# ╔═╡ b08f47b2-92af-11eb-367b-979567aebb4d
prob2 = ODEProblem(sirvd!,u02,tspan2,p2)

# ╔═╡ 88b411f0-92af-11eb-2abf-151b2bfb313b
begin
	sol2 = solve(prob2, dt=1.0, dense = true)
	infected = sol2[2,:]*popsize
	dead = infected + sol2[5,:]*popsize
	recovered = dead + sol2[3,:]*popsize
	vaccinated = recovered + sol2[4,:]*popsize
	susceptible = vaccinated + sol2[1,:]*popsize
	icu = infected*0.015
	icu_cap = [1000 for t in sol2.t]
	
	
	sim_stackarea = plot(sol2.t, [susceptible, vaccinated, recovered, dead, infected, icu], 
				fill = true, 
				color = ["gray89" "skyblue3" "paleturquoise3" "gray39" "lightcoral" "maroon"], 
				fillalpha = 1, 
				label = ["S(t)" "V(t)" "R(t)" "D(t)" "I(t)" L"$I(t)_{icu}$"], 
				xlabel = "t / days", 
				title = "Timecourse (stacked area)", 
				xlims = (0, tmax2), 
				ylims = (0, ymax2*popsize))
	
	
	
	sim_timecourse = plot(sol2,
				color = ["gray89" "lightcoral" "paleturquoise3" "skyblue3" "gray39"], 
				label = ["S(t)" "I(t)" "R(t)" "V(t)" "D(t)"], 
				xlabel = "t / days", 
				title = "Timecourse", 
				xlims = (0, tmax2), 
				ylims = (0, ymax2))
	
	sim_rate_tc = plot(0:tmax2, sol2(0:tmax2, Val{1}, idxs=2),
				color = ["lightcoral"],
				label = [L"\frac{dI}{dt}"],
				xlabel = "t / days", 
				title = "New Infections",
				xlims = (0, tmax2))
	
	timecourses = plot(sim_timecourse, sim_rate_tc, layout = (2,1))
	
	plot(sim_stackarea, timecourses, layout = (1, 2),fontfamily="Computer Modern")
end

# ╔═╡ 7ec0712a-92af-11eb-2144-15d33af27c3d
md"""
| t (days) | I(t)                               | R(t)                               | V(t)                               | D(t)                               |
|----------|------------------------------------|------------------------------------|------------------------------------|------------------------------------|
| 0        | $(getres(sol2, 2, 0, popsize))     | $(getres(sol2, 3, 0, popsize))     | $(getres(sol2, 4, 0, popsize))     | $(getres(sol2, 5, 0, popsize))     |
| $tmax2   | $(getres(sol2, 2, tmax2, popsize)) | $(getres(sol2, 3, tmax2, popsize)) | $(getres(sol2, 4, tmax2, popsize)) | $(getres(sol2, 5, tmax2, popsize)) |

Base reprodution rate = $(round((r2*(1-I02-R02-V02-D02)/a2), sigdigits = 3)), 
Infectious period = $(round(1/a2, sigdigits = 3))

"""

# ╔═╡ 230527fa-92b3-11eb-308f-ffab3777029c
sol2(0:tmax2, Val{1}, idxs=2)

# ╔═╡ Cell order:
# ╠═430d5134-92af-11eb-1fcc-d71f5216d62a
# ╟─5adc7e34-92af-11eb-2cfe-67899a4a0291
# ╠═7a19b238-92af-11eb-30fd-b189d06a0882
# ╟─7ec0712a-92af-11eb-2144-15d33af27c3d
# ╟─88b411f0-92af-11eb-2abf-151b2bfb313b
# ╟─230527fa-92b3-11eb-308f-ffab3777029c
# ╟─8f867f9a-92af-11eb-3671-43904aa74d8b
# ╠═96d8a5c2-92af-11eb-1d3f-9bdd035eafec
# ╟─9c0dfe82-92af-11eb-3192-49c2deac6e9b
# ╟─a1e4ca5e-92af-11eb-1c40-410a8d3abaca
# ╟─ada6253e-92af-11eb-0e32-d9760ab88271
# ╟─b08f47b2-92af-11eb-367b-979567aebb4d
