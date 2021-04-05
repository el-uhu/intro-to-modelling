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

# ╔═╡ 0e592c68-9167-11eb-30fd-efdb809f47f7
#Set up the working environment
begin
	using Pkg
	Pkg.activate("..")
	using Plots, PlutoUI,LaTeXStrings, DifferentialEquations
end

# ╔═╡ e81c951c-9166-11eb-1dd3-51fe9fcb57db
md"""
# Modelling Predator-Prey Dynamics - Coupled Differential Equations

So far, we've looked at a couple of simple models that described the growth or decline of a single population. Now, let's turn towards a more complicated scenario, modelling of **predator-prey** dynamics...

A famous and very simple model of pedator-prey dynamics is the so-called **Lotka-Volterra** model:

$$\begin{eqnarray} 
	\frac{dN}{dt} = N (a-bP)\\
	\frac{dP}{dt} = P (cN - d)
\end{eqnarray}$$

Here, $N$ represents the prey population and $P$ represents the population of predators.

Let us take a closer look at the assumptions baked into this model:
1. In the abesence of predators, the prey grows exponentially
2. Predation has the effect that it reduces the growth rate of the prey population in a manner that depends on $N$ and $P$.

3. If no prey is present, then the predator population declines in an exponential manner.

4. The growth rate of the predator depends on prey in a directly proportional manner.
"""

# ╔═╡ 4611ebd2-3a1e-4c62-80c7-e7dfc56483e6
md"""
> **Exercise - Equilibrium/Stability:** The given parameter set gives rise oscillating (regularly fluctuating) population of predators and prey.
> 1. Try to find one parameter set that gives rise to stable populations (equilibrium) of predators and prey by systematically varying the parameters.
> 2. What would equilibrium mean in terms of the differential equations that underlie the model?
> 3. Try to find the expressions for $N$ and $P$ that correspond to their equilibrium populations.
> 4. Equilibria can be stable or unstable, depending on how they respond to tiny changes in the parameters. What happens if any of the two initial condition deviates a little bit from the equilibrium condition?
> 5. In reality, population sizes, as well as the factors that are represented by the parameters are subject to stochastic (random) variation. This randomness is not represented in the model. Discuss the potential effects of randomness on real populations that would otherwise be well described by the model.
"""

# ╔═╡ 0c6eb46c-a03e-4950-abe6-368b85a4b55e
md"""
> **Exercise - Interspecies Relationships**: Unter certain parameters, the model gives results that appear strange at first sight- where predator populations vastly outnumber the prey population.
>
>1. Using the concept of energy flow in ecosystems, suggest why a predator population that vastly outnumbers the prey population is generally not what we would expect to see in an ecosystem
>2. Find a parameter set that gives you a predator population that is substantially larger than the prey population.
>3. Which other type of interspecies relationship could be adequately described by this model? Would the relative population sizes make more sense given this type of interspecies relationship?
"""

# ╔═╡ f1a68086-9169-11eb-2721-652c6732d36f
md""" ## Simulation
*Change the sliders to adjust the corresponding values*:

| Parameter               | Value                  |
|-------------------------|------------------------|
| prey growth constant $a$ | $(@bind a Slider(0:0.001:0.25, default=0.2, show_value=true)) |
| prey death constant $b$ | $(@bind b Slider(0:0.001:0.25, default=0.02, show_value=true)) |
| predator growth constant $c$ | $(@bind c Slider(0:0.001:0.25, default=0.005, show_value=true)) |
| predator death constant $d$ | $(@bind d Slider(0:0.001:0.25, default=0.1, show_value=true)) |
| initial prey population size $N_0$ | $(@bind N0 Slider(1:1:100, default=50, show_value=true)) |
| initial predator population size $P_0$ | $(@bind P0 Slider(1:1:100, default=10, show_value=true)) |
| simulation time $t_{max}$ | $(@bind tmax Slider(1:5:5000, default=100, show_value=true)) |
"""

# ╔═╡ 0f573286-916e-11eb-157e-1d0139bd363c
function lotkavolterra!(du,u,p,t)
	du[1] = u[1]*(p[1] - p[2]*u[2])
	du[2] = u[2]*(p[3]*u[1] - p[4])
end

# ╔═╡ 2400191e-916e-11eb-2d01-3b3a48757ff4
p = [a, b, c, d]

# ╔═╡ 2c79a5ea-916e-11eb-1abb-7933f2a1eae1
u0 = [N0, P0]

# ╔═╡ 2c7a590c-916e-11eb-227b-97d8098a22b3
tspan = (0, tmax)

# ╔═╡ 33519b3e-916e-11eb-1cb5-7fbc17fba1d8
prob = ODEProblem(lotkavolterra!,u0,tspan,p)

# ╔═╡ 6c09dc9c-916a-11eb-1bff-fb5495955ad7
begin
	# Defining the system of ODEs in paramtetrised manner and using in-place notation 		(! after function name) to improve performance
	# u[1] = N, u[2] = P

	sol = solve(prob)
	simplot = plot(sol, labels = ["N(t)" "P(t)"])
	phaseplot = plot(sol, vars = (1,2), xlabel = "N(t)", ylabel = "P(t)")
	plot(simplot, phaseplot, layout = (1, 2),fontfamily="Computer Modern")
end

# ╔═╡ 6acb8812-fd98-492b-ae20-38efd9cf8cba
md"""
#### Notebook options
Show solutions: $(@bind show_solutions CheckBox(default=false))
"""

# ╔═╡ 3bb1ca46-0993-47bf-9ba7-ad65185bac96
begin 
	if show_solutions == true
md"""
!!! tip "Solution"

	**1.** A simple equilibrium can be found by setting any of the two growth rate constants to zero. This would correspond to the extinction of the two populations.

	**2.** In terms of the equations, equilibrium corresponds to a situation where neither of the two populations grows or declines, hence both expressions ($\frac{dN}{dt}$ and $\frac{dP}{dt}$) are zero:

	$$\begin{eqnarray} 
		\frac{dN}{dt} = 0 = N (a-bP)\\
		\frac{dP}{dt} = 0 = P (cN - d)
	\end{eqnarray}$$

	**3.** Using the insight from above and solving for $N$ and $P$, we find:

	$$\{N_{eq,1} = 0, P_{eq,1} = 0\}$$
	
	and
	
	$$\{N_{eq,2} = \frac{d}{c}, P_{eq,2} = \frac{a}{b}\}$$
	
	**4.** Tiny deviations instantly give rise to oscillations around the equilibrium point. The populations never reach equilibrium.

	**5.** Due to the tendency of the populations to oscillate around the non-zero equilibrium, we would not expect to see non-oscillation populations.
"""
	end
end

# ╔═╡ f6a109fd-232e-42b6-a2c2-88c7eb9befce
begin
	if show_solutions == true
md"""
!!! tip "Solution"
	**1.** Since only a fraction of the energy is transfered from lower to higher trophic levels, the situation described by the model does not reflect expected population sizes for typical predator-prey relationships.
	**2.** Many combinations work, e.g. $a$ = 0.2, $b$ = 0.02, $c$ = 0.2, $d$ = 0.2, $N_0$ = 10, $P_0$ = 40
	**3.** Another antagonistic (-/-) relationship that could be described by this model is parasitism. In this case the relative population sizes would make more sense.
"""
	end
end

# ╔═╡ Cell order:
# ╟─0e592c68-9167-11eb-30fd-efdb809f47f7
# ╟─e81c951c-9166-11eb-1dd3-51fe9fcb57db
# ╟─4611ebd2-3a1e-4c62-80c7-e7dfc56483e6
# ╟─3bb1ca46-0993-47bf-9ba7-ad65185bac96
# ╟─0c6eb46c-a03e-4950-abe6-368b85a4b55e
# ╟─f6a109fd-232e-42b6-a2c2-88c7eb9befce
# ╟─f1a68086-9169-11eb-2721-652c6732d36f
# ╠═6c09dc9c-916a-11eb-1bff-fb5495955ad7
# ╟─0f573286-916e-11eb-157e-1d0139bd363c
# ╟─2400191e-916e-11eb-2d01-3b3a48757ff4
# ╟─2c79a5ea-916e-11eb-1abb-7933f2a1eae1
# ╟─2c7a590c-916e-11eb-227b-97d8098a22b3
# ╟─33519b3e-916e-11eb-1cb5-7fbc17fba1d8
# ╟─6acb8812-fd98-492b-ae20-38efd9cf8cba
