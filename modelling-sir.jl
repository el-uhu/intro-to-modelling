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

# ╔═╡ 7cd44a22-91f0-11eb-056d-699740ca7da9
#Set up the working environment
begin
	using Pkg
	Pkg.activate(".")
	using Plots, PlutoUI,LaTeXStrings, DifferentialEquations
end

# ╔═╡ 3199bb4e-91ed-11eb-37fa-abed99588e6b
md"""
# Epidemics - The SIR Model
- developed by *Kermack* and *McKendric* in the 1930s to describe the spread of malaria
- describes the spread of a disease from a population of infected individuals over time
- The total population is constant and is divided into three groups: *susceptible (S), infected (I) and recovered (R)*
- immune and deceased individuals are "lumped" together into group R
- only susceptible individuals can get the disease
- the incubation period is negligible - infected individuals are infectious right away

$$S \xrightarrow{r} I \xrightarrow{a} R$$

This gives rise to the following set of differential equations:

$$\begin{aligned}
	\frac{dS}{dt} = -rSI\\
	\frac{dI}{dt} = rSI - aI\\
	\frac{dR}{dt} = aI
\end{aligned}$$

S, I & R represent parts of a constant total population, hence the following two relations hold

$$S(t) + I(t) + R(t) = N$$

$$\frac{dS}{dt} + \frac{dI}{dt} + \frac{dR}{dt} = 0$$

> If the latter relationship does not immediately make sense to you, pause for a second to figure it out.

In order to make things a bit more comparable, we'll consider the total population to be normalised. Hence $N=1$, and values for $S$, $I$, and $R$ correspond to fractions of the population.

## Finding the right parameters
Once we have formulated a model - establishing a way how things depend on each other - we need to find the right parameters, and thereby establish how strong these links are.

The best way to do this is to look at real data. Let us try to parametrise the model to roughly mimic the dynamics of COVID-19. We know, that the base reproduction number, i.e. the number of individuals infected by a single infected person, is on the order of $3$, if no interventions (masks, lockdowns, etc.) are in place. This base reproduction number falls right out of our model. (In fact it was first defined based on a similar model). It is given by the following relationship:

$$R_0 = \frac{rS_0}{a}$$

If we have a rough idea of the fractions of the population that is either infected ($I_0$) or resistant ($R_0$), we can easily determine the fraction of susceptible individuals ($S_0$).

The parameters $r$ and $a$ are harder to determine. However, if we have an idea of the amount of time infected individuals remain infectious on average, we can estimate the recovery rate $r$ using the following relationship:

$$t_{infectious} = \frac{1}{a}$$

>  By thinking about what the equations in the model mean, convince yourself that the relationship between our parameter $a$ and the average infectious time holds
"""

# ╔═╡ 1fc5f952-91ff-11eb-3366-9f477c640915
md"""
The code below implements the SIR-model and plots the output. Parameters can be adjusted using the sliders above the graphs. The simulation, as well as values for $R_0$ and $t_{infectious}$ are updated accordingly.

> **Exercise 1 - Understanding the model:** Try to paramterise the model to capture the dynamics of COVID-19 without any interventions. Start by changing $a$ and $r$ and observe the effect on the overall dynamics (as shown in the timecourse plot), as well as on the base reproduction rate and the infectious period. - Use an average infectious period of 10 days and a base reproduction rate of approximately 3.5 to guide your parametrisation.
>
> - How strong is the effect of $r$ and $a$ on the base reproduction number?
> - What is the effect of a higher proportion of infected individuals at the start on the dynamics of the outbreak and $R_0$?
> - Assuming a starting population of infectious individuals of 1%, how long does it take until the outbreak peaks? Roughly how large is the fraction of the population that has recovered at the end?
> - Assuming a case mortality (percentage of people with the disease that die) of 2%, what would be your estimate of the total number of fatalities at the end of the outbreak?
> - Research online to try to come up with reasonable estimates for the fraction of people currently infected and the number of recovered people (including vaccinations) to be used as $I(0)$ and $R(0)$ respectively
"""

# ╔═╡ bfe81088-9203-11eb-162b-f373131bc105
md"""
> **Exercise 2 - Lowering $R_0$:** The current base reproduction rate in Austria is estimated to be slightly above 1. Change the transmission rate accordingly.
>
> - How has the change affected the dynamics of the outbreak (time to peak, fraction of population that has recovered, fraction of the population infected at peak, estimated number of fatalities)?
"""

# ╔═╡ e574a398-9203-11eb-0006-c38430911ee1
md"""
>**Exercise 3 - Intensive Care:** Roughly 1.5% of cases need to be treated in intensive care. Roughly 2500 beds in intensive care units are available, of which roughly 1000 beds can be made available to treat COVID-19 patients. This translates to approximately 0.0001 ICU beds per capita. 
>
> - Assuming that the recovery rate of ICU patients is unchanged, what will be the demand for ICU beds at the peak of the outbreak with a base reproduction number of 1.17? How does this compare to the ICU bed capacity estimated above?
> - How low would $R_0$ need to be in order not to overwhelm ICU capacity?
> - Give five reasons why this scenario might be an oversimplification? Make an educated guess, as to whether you're likely to over- or underestimate the number of patients needing ICU-care.
"""

# ╔═╡ ac0c0230-91f0-11eb-057d-2103908afe51
md""" ## Simulation
*Change the sliders to adjust the corresponding values*:
- transmission rate $r$ $(@bind r Slider(0:0.005:1, default=0.125, show_value=true))
- recovery rate $a$ $(@bind a Slider(0:0.001:0.25, default=0.1, show_value=true))
- initial number of infected $I(0)$ $(@bind I0 Slider(0.0001:0.001:0.1, default=0.01, show_value=true))
- initial number of resistant $R(0)$ $(@bind R0 Slider(0:0.001:0.1, default=0,show_value=true))
- timespan $t_{max}$ $(@bind tmax Slider(10.0:10.0:2000.0, default=100.0,show_value=true)) days
- zoom y-axis $(@bind ymax Slider(0.05:0.05:1.0, default=1.0,show_value=true))
"""

# ╔═╡ 0b66bc58-91fa-11eb-24f1-7f9f839a6cbf
md"""
Base reprodution rate = $(round((r*(1-I0-R0)/a), sigdigits = 3)), 
Infectious period = $(round(1/a, sigdigits = 3))

Scaled for Austria (9M): I(0): $(I0 * 9000000), R(0): $(R0 * 9000000)
"""

# ╔═╡ a5f6c71c-920a-11eb-09e9-098f52c01f11
md"""
!!! danger "Beware!"

    The blocks below are used to specify the model. Feel free to play around with them, but proceed with care!
"""

# ╔═╡ 618d69dc-91f1-11eb-211f-d7548bf4a306
function sir!(du,u,p,t)
	du[1] = -p[1] * u[1] * u[2]
	du[2] = p[1] * u[1] * u[2] - p[2] * u[2]
	du[3] = p[2] * u[2]
end

# ╔═╡ 9a4c2f80-91f1-11eb-2b14-1784007ca92c
p = [r, a]

# ╔═╡ a6c393c8-91f1-11eb-0be0-99d47c2b207f
u0 = [1.0 - I0 - R0, I0, R0]

# ╔═╡ eccbab9e-91f1-11eb-19b2-d733609880d0
tspan = (0.0, 2000)

# ╔═╡ f2abe15a-91f1-11eb-17c2-e99b8b67502f
prob = ODEProblem(sir!,u0,tspan,p)

# ╔═╡ 4c7f9b82-91f1-11eb-0064-e70bb182dae0
begin
	sol = solve(prob, dt=1.0, dense = true)
	
	simplot = plot(sol.t, [sol[3,:] + sol[2,:] + sol[1,:] sol[3,:] + sol[2,:] sol[2,:]], fill = true, color = ["gray89" "paleturquoise3" "lightcoral"], fillalpha = 0.4, label = ["S(t)" "R(t)" "I(t)"], xlabel = "t / days", title = "Timecourse", xlims = (0, tmax), ylims = (0, ymax))
	
	phaseplot1 = plot(sol, vars = (1,2), xlabel = "S(t)", ylabel = "I(t)", label = "", title = "Phaseplanes", xlims = (0,ymax), ylims = (0,ymax), color = "skyblue4")
	
	phaseplot2 = plot(sol, vars = (3,2), xlabel = "R(t)", ylabel = "I(t)", label = "", xlims = (0,ymax), ylims = (0,ymax), color = "skyblue4")
	
	phaseplot = plot(phaseplot1, phaseplot2, layout = (2,1))
	
	plot(simplot, phaseplot, layout = (1, 2),fontfamily="Computer Modern")
end

# ╔═╡ af81cf0a-9220-11eb-3ba9-e17dc6c8e46a
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

# ╔═╡ d0cc506c-9226-11eb-295c-39c46ae3c52d
md""" ## Simulation
*Change the sliders to adjust the corresponding values*:
- transmission rate $r$ $(@bind r2 Slider(0:0.005:1, default=0.125, show_value=true))
- recovery rate $a$ $(@bind a2 Slider(0:0.001:0.25, default=0.1, show_value=true))
- rate of vaccination $v$ $(@bind v2 Slider(0:0.0001:0.01, default=0.002, show_value=true))
- mortality $m$ $(@bind m2 Slider(0:0.001:0.25, default=0.002, show_value=true))
- % immunity recovered $i_r$ $(@bind ir Slider(0:1.0:100.0, default=90, show_value=true))
- % immunity vaccinated $i_v$ $(@bind iv Slider(0:1.0:100.0, default=90, show_value=true))
- initial number of infected $I(0)$ $(@bind I02 Slider(0.0001:0.001:0.1, default=0.004, show_value=true))
- initial number of recovered $R(0)$ $(@bind R02 Slider(0:0.001:0.1, default=0.055,show_value=true))
- initial number of vaccinated $V(0)$ $(@bind V02 Slider(0:0.001:0.1, default=0.048,show_value=true))
- initial number of dead $D(0)$ $(@bind D02 Slider(0:0.001:0.1, default=0.001,show_value=true))
- timespan $t_{max}$ $(@bind tmax2 Slider(10.0:10.0:2000.0, default=100.0,show_value=true)) days
- zoom y-axis $(@bind ymax2 Slider(0.05:0.05:1.0, default=1.0,show_value=true))
"""

# ╔═╡ 186376c0-922f-11eb-2dde-8b4c16086b66
md"""
Population size = $(@bind popsize NumberField(500000:10000000000, default=9044650))
"""

# ╔═╡ 4684bde2-9233-11eb-231b-b3bdab1180b0
501116/popsize

# ╔═╡ 1b563284-9230-11eb-0e2a-378bf00144ef
function getres(solution, i, t, p)
	v = solution(t)[i]*p
	return round(maximum([0.0 v]))
end

# ╔═╡ c5daceee-9227-11eb-0bb4-19e3a2a5ca9e
#S, I, R, V, D
function sirvd!(du,u,p,t)
	du[1] = -u[1] * ( p[1] * u[2] + p[3])
	du[2] = u[2] * (p[1] * (u[1] + p[5] * u[4] + p[4] * u[3]) - p[6] - p[2])
	du[3] = p[2] * u[2] - u[3] * ( p[1] * p[4] *  u[2] + p[3])
	du[4] = p[3] * (u[1] + u[3]) - u[4] * u[2] * p[1] * p[5]
	du[5] = p[6] * u[2]
end

# ╔═╡ d1542720-9227-11eb-18a9-357d60270d93
p2 = [r2, a2, v2, (100 - ir)/100, (100 - iv)/100, m2]

# ╔═╡ d80c9de0-9227-11eb-28be-bf26f5194979
u02 = [1-I02-R02-V02-D02, I02, R02, V02, D02]

# ╔═╡ e32e0902-9227-11eb-0885-1199f01da570
tspan2 = (0.0, 2000)

# ╔═╡ e9840412-9227-11eb-0cbb-91d4b823cb40
prob2 = ODEProblem(sirvd!,u02,tspan2,p2)

# ╔═╡ c3ed3914-9227-11eb-0454-913918c3e700
begin
	sol2 = solve(prob2, dt=1.0, dense = true)
	infected = sol2[2,:]
	dead = infected + sol2[5,:]
	recovered = dead + sol2[3,:]
	vaccinated = recovered + sol2[4,:]
	susceptible = vaccinated + sol2[1,:]
	
	
	simplot21 = plot(sol2.t, [susceptible, vaccinated, recovered, dead, infected], 
				fill = true, 
				color = ["gray89" "skyblue3" "paleturquoise3" "gray39" "lightcoral"], 
				fillalpha = 0.4, 
				label = ["S(t)" "V(t)" "R(t)" "D(t)" "I(t)"], 
				xlabel = "t / days", 
				title = "Timecourse (area)", 
				xlims = (0, tmax2), 
				ylims = (0, ymax2))
	
	simplot22 = plot(sol2,
				color = ["gray89" "lightcoral" "paleturquoise3" "skyblue3" "gray39"], 
				fillalpha = 0.4, label = ["S(t)" "I(t)" "R(t)" "V(t)" "D(t)"], 
				xlabel = "t / days", 
				title = "Timecourse (area)", 
				xlims = (0, tmax2), 
				ylims = (0, ymax2))
	
	plot(simplot21, simplot22, layout = (1, 2),fontfamily="Computer Modern")
end

# ╔═╡ fccfb44a-922d-11eb-05d8-9b378316a417
md"""
| t (days) | I(t)                               | R(t)                               | V(t)                               | D(t)                               |
|----------|------------------------------------|------------------------------------|------------------------------------|------------------------------------|
| 0        | $(getres(sol2, 2, 0, popsize))     | $(getres(sol2, 3, 0, popsize))     | $(getres(sol2, 4, 0, popsize))     | $(getres(sol2, 5, 0, popsize))     |
| $tmax2   | $(getres(sol2, 2, tmax2, popsize)) | $(getres(sol2, 3, tmax2, popsize)) | $(getres(sol2, 4, tmax2, popsize)) | $(getres(sol2, 5, tmax2, popsize)) |

Base reprodution rate = $(round((r2*(1-I02-R02-V02-D02)/a2), sigdigits = 3)), 
Infectious period = $(round(1/a2, sigdigits = 3))

"""

# ╔═╡ Cell order:
# ╟─7cd44a22-91f0-11eb-056d-699740ca7da9
# ╠═3199bb4e-91ed-11eb-37fa-abed99588e6b
# ╟─1fc5f952-91ff-11eb-3366-9f477c640915
# ╟─bfe81088-9203-11eb-162b-f373131bc105
# ╟─e574a398-9203-11eb-0006-c38430911ee1
# ╟─ac0c0230-91f0-11eb-057d-2103908afe51
# ╟─0b66bc58-91fa-11eb-24f1-7f9f839a6cbf
# ╟─4c7f9b82-91f1-11eb-0064-e70bb182dae0
# ╟─a5f6c71c-920a-11eb-09e9-098f52c01f11
# ╟─618d69dc-91f1-11eb-211f-d7548bf4a306
# ╟─9a4c2f80-91f1-11eb-2b14-1784007ca92c
# ╟─a6c393c8-91f1-11eb-0be0-99d47c2b207f
# ╟─eccbab9e-91f1-11eb-19b2-d733609880d0
# ╟─f2abe15a-91f1-11eb-17c2-e99b8b67502f
# ╟─af81cf0a-9220-11eb-3ba9-e17dc6c8e46a
# ╟─d0cc506c-9226-11eb-295c-39c46ae3c52d
# ╟─186376c0-922f-11eb-2dde-8b4c16086b66
# ╟─fccfb44a-922d-11eb-05d8-9b378316a417
# ╟─c3ed3914-9227-11eb-0454-913918c3e700
# ╠═4684bde2-9233-11eb-231b-b3bdab1180b0
# ╟─1b563284-9230-11eb-0e2a-378bf00144ef
# ╟─c5daceee-9227-11eb-0bb4-19e3a2a5ca9e
# ╟─d1542720-9227-11eb-18a9-357d60270d93
# ╟─d80c9de0-9227-11eb-28be-bf26f5194979
# ╟─e32e0902-9227-11eb-0885-1199f01da570
# ╟─e9840412-9227-11eb-0cbb-91d4b823cb40
