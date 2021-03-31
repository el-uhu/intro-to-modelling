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

# ╔═╡ 0e592c68-9167-11eb-30fd-efdb809f47f7
#Set up the working environment
begin
	using Pkg
	Pkg.activate(".")
	using Plots, PlutoUI,LaTeXStrings, DifferentialEquations
end

# ╔═╡ e81c951c-9166-11eb-1dd3-51fe9fcb57db
md"""
# Modelling Predator-Prey Dynamics - Coupled Differential Equations

So far, we've looked at a couple of simple models that described the growth or decline of a single population. Now, let's turn towards a more complicated scenario, modelling of **predator-prey** dynamics...

A famous and very simple model of pedator-prey dynamics is the so-called **Lotka-Volterra** model:

$$\begin{eqnarray} 
	\frac{dN}{dt} = N (a-bP)\\
	\frac{dP}{dt} = P (cP - d)
\end{eqnarray}$$

Here, $N$ represents the prey population and $P$ represents the population of predators.

Let us take a closer look at the assumptions baked into this model:
1. In the abesence of predators, the prey grows exponentially

> **Exercise:** Suggest a way to make the growth of the prey population more realistic

2. Predation has the effect that it reduces the growth rate of the prey population in a manner that depends on $N$ and $P$.

3. If no prey is present, then the predator population declines in an exponential manner.

4. The growth rate of the predator depends on prey in a directly proportional manner.
"""

# ╔═╡ f1a68086-9169-11eb-2721-652c6732d36f
md""" ## Visual analysis
*Change the sliders to adjust the corresponding values*:
- prey growth constant $a$ $(@bind a Slider(0:0.001:0.25, default=0.2, show_value=true))
- prey death constant $b$ $(@bind b Slider(0:0.001:0.25, default=0.02, show_value=true))
- predator growth constant $c$ $(@bind c Slider(0:0.001:0.25, default=0.005, show_value=true))
- predator death constant $d$ $(@bind d Slider(0:0.001:0.25, default=0.1, show_value=true))
- initial prey population size $N_0$ $(@bind N0 Slider(1:5:100, default=50, show_value=true))
- initial predator population size $P_0$ $(@bind P0 Slider(1:5:100, default=10, show_value=true))
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
tspan = (0, 200)

# ╔═╡ 33519b3e-916e-11eb-1cb5-7fbc17fba1d8
prob = ODEProblem(lotkavolterra!,u0,tspan,p)

# ╔═╡ 6c09dc9c-916a-11eb-1bff-fb5495955ad7
begin
	# Defining the system of ODEs in paramtetrised manner and using in-place notation 		(! after function name) to improve performance
	# u[1] = N, u[2] = P

	sol = solve(prob)
	simplot = plot(sol)
end

# ╔═╡ 382308d4-916e-11eb-3246-9fbd7b53a7ec


# ╔═╡ Cell order:
# ╟─0e592c68-9167-11eb-30fd-efdb809f47f7
# ╟─e81c951c-9166-11eb-1dd3-51fe9fcb57db
# ╟─f1a68086-9169-11eb-2721-652c6732d36f
# ╟─6c09dc9c-916a-11eb-1bff-fb5495955ad7
# ╠═0f573286-916e-11eb-157e-1d0139bd363c
# ╠═2400191e-916e-11eb-2d01-3b3a48757ff4
# ╟─2c79a5ea-916e-11eb-1abb-7933f2a1eae1
# ╟─2c7a590c-916e-11eb-227b-97d8098a22b3
# ╟─33519b3e-916e-11eb-1cb5-7fbc17fba1d8
# ╠═382308d4-916e-11eb-3246-9fbd7b53a7ec
