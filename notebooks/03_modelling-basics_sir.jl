### A Pluto.jl notebook ###
# v0.14.0

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
	Pkg.activate("..")
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

The parameters $r$ and $a$ are harder to determine. However, if we have an idea of the amount of time infected individuals remain infectious on average, we can estimate the recovery rate $a$ using the following relationship:

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

| Parameter         | Value                  |
|-------------------|------------------------|
 transmission rate $r$ | $(@bind r Slider(0:0.005:1, default=0.125, show_value=true)) |
| recovery rate $a$ | $(@bind a Slider(0:0.001:0.25, default=0.1, show_value=true)) |
| initial number of infected $I(0)$ | $(@bind I0 Slider(0.0001:0.001:0.1, default=0.01, show_value=true)) |
| initial number of resistant $R(0)$ | $(@bind R0 Slider(0:0.001:0.1, default=0,show_value=true)) |
| timespan $t_{max}$ | $(@bind tmax Slider(10.0:10.0:2000.0, default=100.0,show_value=true)) days |
| zoom y-axis | $(@bind ymax Slider(0.05:0.05:1.0, default=1.0,show_value=true)) |
| Population size             | $(@bind popsize NumberField(500000:10000000000, default=9044650)) |
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
	
	simplot = plot(sol.t, [sol[3,:] + sol[2,:] + sol[1,:] sol[3,:] + sol[2,:] sol[2,:]],
		fill = true, 
		color = ["gray89" "paleturquoise3" "lightcoral"], 
		label = ["S(t)" "R(t)" "I(t)"], 
		xlabel = "t / days", 
		title = "Timecourse", 
		xlims = (0, tmax), 
		ylims = (0, ymax))
	
	phaseplot1 = plot(sol, vars = (1,2), 
		xlabel = "S(t)", 
		ylabel = "I(t)", 
		label = "", 
		title = "Phaseplanes", 
		xlims = (0,ymax), 
		ylims = (0,ymax), 
		color = "skyblue4")
	
	phaseplot2 = plot(sol, vars = (3,2), 
		xlabel = "R(t)", 
		ylabel = "I(t)", 
		label = "", 
		xlims = (0,ymax), 
		ylims = (0,ymax), 
		color = "skyblue4")
	
	phaseplot = plot(phaseplot1, phaseplot2, layout = (2,1))
	
	#plot(simplot, phaseplot, layout = (1, 2),fontfamily="Computer Modern")
	plot(simplot,fontfamily="Computer Modern")
end

# ╔═╡ 0a8e0895-2de8-435e-827c-fb216ab07f10
function getres(solution, i, t, p)
	v = solution(t)[i]*p
	return round(maximum([0.0 v]))
end

# ╔═╡ 0b66bc58-91fa-11eb-24f1-7f9f839a6cbf
md"""
Base reprodution rate = $(round((r*(1-I0-R0)/a), sigdigits = 3)), 
Infectious period = $(round(1/a, sigdigits = 3))

| t(days)   | I(t)   | R(t)    |
|-----------|--------|---------|
| 0         | $(getres(sol, 2, 0, popsize)) | $(getres(sol, 3, 0, popsize)) |
| $tmax     | $(getres(sol, 2, tmax, popsize)) | $(getres(sol, 3, tmax, popsize)) |
"""

# ╔═╡ Cell order:
# ╟─7cd44a22-91f0-11eb-056d-699740ca7da9
# ╟─3199bb4e-91ed-11eb-37fa-abed99588e6b
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
# ╟─0a8e0895-2de8-435e-827c-fb216ab07f10
