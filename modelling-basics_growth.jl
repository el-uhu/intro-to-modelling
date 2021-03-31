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

# ╔═╡ 89fcfe1c-913a-11eb-1b04-0d87fd8dbcbe
#Set up the working environment
begin
	using Pkg
	Pkg.activate(".")
	using Plots, PlutoUI,LaTeXStrings
end

# ╔═╡ 9f7c1628-9139-11eb-0d69-f910a995eca7
md"""## Differential Equations

When modelling growth, we rely on **differential equations** that describe the change in some variable $y$ with respect to some other variable $x$.

$$\frac{dy}{dx} = f(y)$$

Here, $\frac{dy}{dx}$ represents the **rate of change in $y$ with respect to $x$**, and $f(y)$ is some function that depends on $y$. 

Solving differential equations to obtain a function that expresses $y$ in terms of $x$ can be relatively straight-forward, but this is generally not the case. So why bother? It turns out that in the natural world for many processes *it tends to be much easier to describe what the change in some quantity depends on*, rather than coming up with an *explicit* formula how $y$ changes as $x$ varies proves difficult.

To make the mathematical language a bit less abstract, let us rewrite the equation above, so that the the variables more directly correspond to what we are talking about when modelling growth:

$$(1)\frac{dP}{dt} = f(P)$$

Here, $\frac{dP}{dt}$ denotes the growth rate of some population $P$ over time, which depends on the population size $P$ in a yet-to-be specified manner $f(P)$."""


# ╔═╡ babc9748-9139-11eb-0da1-0d942d591481
md"""## The simplest possible case

To familiarise ourselves with growth models, let's look at a very simple model, while ignoring the fact that the model does not make sense when modelling biological populations.

$$(2)\frac{dP}{dt} = r$$

Here, our growth rate $\frac{dP}{dt}$  is constant and equal to a growth rate constant $r$.

### Rate Plots
A useful and simple trick to understand how systems described by differential equations behave involves looking at the **rate plot**, where we plot how $\frac{dP}{dt}$  changes as the population size $P$ varies.

> **Exercise:** Sketch a rate plot for the system described by equation (2)."""

# ╔═╡ ee2bb580-9145-11eb-2bc2-dbd9aae68be9
md"""
Since the rate of growth is constant,  changes by the same amount in the same timespan, regardless of how much time has already passed. Thus the graph of  versus  is a straight line that intersects the y-Axis at  and grows with a slope of .
"""

# ╔═╡ 001fc24a-9146-11eb-39b9-955dac6bcf58
md"""
### Solving a simple differential equation
Nice - We've analysed a simple differential equation using a rate plot and deduced an approximate plot of $P$ over time from it. Now on to the somewhat harder part - solving the differential equation mathematically...

In general, differential equations can be solved by separating the variables ($P$ and $t$ in our case) and then integrating both sides with respect to the variables. If you're unfamiliar with integration, but are familiar with differentiation, as taught in highschool, it should suffice to say that integration is essentially differentiation in reverse.

Upon separating our variables in equation (2), we get

$$(3) \int dP = r \int dt $$

Doing differentiation in reverse for each side, we find

$$(4) P + C_1 = rt + C_2 $$

We find the derivative of a variable by lowering its exponent by 1. 

$$(5) f(x) = x^n, f'(x) = x^{n-1}$$

Hence, integrating the expression above (which can be viewed as containing $P^0=1$ and $t^0=1$, respectively) with respect to some variable amounts to raising the exponents of our "invisible" variables by 1. You may wonder where the two constants come from. They need to be included, because constants disappear in differentiation and this needs to be accounted for by creating them in the course of integration. However, we don't need to worry too much about the constants for now. In fact, they behave a bit like plasticine and can be liberally lumped together for now, as we only need to determine the constant we're left with once we're done with our arithmetic.

By absorbing $C_1$ into $C_2$, we get a new constant $C = C_1 - C_2$, and equation (4) rearranges to 

$$(6) P(t) = rt + C $$

Voilá, here's an equation for a straight line!

To figure out the value of our constant $C$, we need one more trick: We set $P(0)=P_0$ and $t=0$, and we get

$$(7) P_0 = C$$

Hence our final equation is

$$(8) P(t) = rt + P_0$$
"""

# ╔═╡ ad08de50-913d-11eb-3f87-fb27a282bdb3
md"""### Interactive Simulation
*Change the sliders to adjust the corresponding values*:
- growth rate constant ($r$) $(@bind r_0 Slider(-0.5:0.01:0.5, default=0.01, show_value=true))
- initial population size($P_0$) $(@bind P0_0 Slider(0:5:100, default=20, show_value=true))
"""

# ╔═╡ f58d273e-9139-11eb-0fe0-b11e90166682
begin
	# Our differential equation 
	dPdt_0(P, r) = r
	# A vector holding different population size values
	population_0 = 0:0.5:100
	# A vector holding our growth rate values for different population sizes
	growthrate_0 = [dPdt_0(p,r_0) for p in population_0]
	
	# The solution to our differential equation
	P_0(t, r, P0) = P0 + r*t
	# A vector holding values for different timepoints
	time_0 = 0:0.5:50
	# A vector holding our simulated population sizes
	sim_pop_0 = [P_0(t,r_0,P0_0) for t in time_0]
	
	
	rateplot_0 = plot(population_0, growthrate_0,
				xlims = (0,100), 
				ylims = (-1.2, 1.2), 
				title = "Rateplot",
				label = "",
				xlabel = "P", ylabel = L"$\frac{dP}{dt}$")
	simplot_0 = plot(time_0, sim_pop_0, 
				color = "red",
				ylims = (0,100), 
				title = "Simulation",
				label = "",
				xlabel = "t", ylabel = "P")
	plot(rateplot_0, simplot_0, layout = (1, 2),fontfamily="Computer Modern")
end

# ╔═╡ aa53e7e0-913d-11eb-32ab-4fc1ce2b72ab
md"""
## 2. A more realistic case

The growth of most biological populations will at the very least depend on the number of individuals already present. After all, having twice as many bacteria that could potentially divide, we'd expect the growth rate to increase accordingly. To capture this relationship, we can write

$$(9) \frac{dP}{dt} = rP$$

> **Exercise:** Sketch a rate plot for the system described by equation (9).

From our rate plot, we can see that in this case, the growth rate increases linearly as our population grows. 

> **Exercise:** Try to sketch a plot that shows how $P$ changes over time $t$, starting from an arbitrarily chosen initial population size $P_0$.

Maybe you were able to figure out that since the growth rate increases as $P$ grows, the growth of the population should accelerate in exponential manner. To get an explicit formula for $P(t)$, and double-check our intuition, let us use the methods we've learned above.

Separation of variables in equation (9) yields

$$(10) \int \frac{1}{P} dP = r \int dt$$

Integrating equation 10 (and maybe consulting a trusty resource for common antiderivatives to find $\int \frac{1}{x} dx = ln(x) + C$), we get

$$(11) ln(P) + C_1 = rt + C_2$$

Again, we can absorn $C_1$ and $C_2$ into a new constant $C = C_2 - C_1$ to obtain

$$(12) ln(P) = rt + C $$

Now, to extract our population size $P$ from the somewhat unyieldy $ln(P)$, we make use of the following identities $e^{ln(x)} = x$, $e^{a+b} = e^a \cdot e^b$ and obtain:

$$(13) P(t) = e^{rt + C} = e^C \cdot e^{rt}$$

Exploiting the plasticine-like qualities of our integration constant and settin $e^C = A$, we clean up equation (13) and get

$$(14) P(t) = A \cdot e^{rt}$$

To figure out the value of $A$, we employ the same trick as above and set $t = 0$ and $P(0) = P_0$.

$$(15) P_0 = A \cdot e^{r \cdot 0} = A$$

Hence our solution to equation (9) is

$$(16) P(t) = P_0 \cdot e^{rt}$$

This equation ought to look familiar. It is the equation for exponential growth (and decay, if $r<0$) and abounds in science (e.g. radioactive decay). Yet, to model populations in biology, it is of very limited use, as it suggests a world of unlimited resources. Eventually, any population is going to encounter limiting factors - it may run out of space or food, or may find itself fall prey to predators or parasites.
"""

# ╔═╡ 008851e2-9147-11eb-3b1c-0ff07fd4e84f
md"""### Interactive Simulation
*Change the sliders to adjust the corresponding values*:
- growth rate constant ($r$) $(@bind r_1 Slider(-0.25:0.01:0.25, default=0.01, show_value=true))
- initial population size($P_0$) $(@bind P0_1 Slider(0:5:100, default=20, show_value=true))
"""

# ╔═╡ 20245898-9147-11eb-16cb-7320a2ffbe0d
begin
	# Our differential equation 
	dPdt_1(P, r) = r*P
	# A vector holding different population size values
	population_1 = 0:0.5:100
	# A vector holding our growth rate values for different population sizes
	growthrate_1 = [dPdt_1(p,r_1) for p in population_1]
	
	# The solution to our differential equation
	P_1(t, r, P0) = P0*exp(r*t)
	# A vector holding values for different timepoints
	time_1 = 0:0.5:50
	# A vector holding our simulated population sizes
	sim_pop_1 = [P_1(t,r_1,P0_1) for t in time_1]
	
	
	rateplot_1 = plot(population_1, growthrate_1,
				xlims = (0,100), 
				ylims = (-1.2, 1.2), 
				title = "Rateplot",
				label = "",
				xlabel = "P", ylabel = L"$\frac{dP}{dt}$")
	simplot_1 = plot(time_1, sim_pop_1, 
				color = "red",
				ylims = (0,100), 
				title = "Simulation",
				label = "",
				xlabel = "t", ylabel = "P")
	plot(rateplot_1, simplot_1, layout = (1, 2),fontfamily="Computer Modern")
end

# ╔═╡ 24f0552e-9148-11eb-1226-c326de038a70
md"""
## 3. The Logistic Model

Without being to explicit about the precise nature of our limiting factor, let us assume the population size be limited to a maximum number that can be supported in a given habitat. We call this the **carrying capacity, $K$**.

$$(17) \frac{dP}{dt} = rP(1-\frac{P}{K})$$


### Visual Analysis
If our population is close to $0$, it will won't "feel" any limiting effect and grow in a similar manner to the exponential model discussed above. As the population gets closer to the carrying capacity, the growth will begin to slow down.
"""


# ╔═╡ 3d7b3688-9148-11eb-3224-9b832c4692d9
md"""
*Change the sliders to adjust the corresponding values*:
- growth rate constant ($r$) $(@bind r_2 Slider(0:0.001:0.25, default=0.01, show_value=true))
- carrying capacity ($K$) $(@bind K_2 Slider(1:5:80, default=30, show_value=true))
- initial population size($P_0$) $(@bind P0_2 Slider(1:5:100, default=20, show_value=true))
"""

# ╔═╡ 5fbb5af8-9148-11eb-0ade-b3fd39af29c1
begin
	# Our differential equation 
	dPdt_2(P, r, K) = r*P*(1- P/K)
	# A vector holding different population size values
	population_2 = 0:0.5:100
	# A vector holding our growth rate values for different population sizes
	growthrate_2 = [dPdt_2(p,r_2, K_2) for p in population_2]
	
	# The solution to our differential equation
	P_2(t, r, K,  P0) = K/((K-P0)/P0*exp(-r*K*t) + 1)
	# A vector holding values for different timepoints
	time_2 = 0:0.5:50
	# A vector holding our simulated population sizes
	sim_pop_2 = [P_2(t,r_2/K_2,K_2, P0_2) for t in time_2]
	
	
	rateplot_2 = plot(population_2, growthrate_2,
				xlims = (0,100), 
				ylims = (-1.2, 2.5), 
				title = "Rateplot",
				label = "",
				xlabel = "P", ylabel = L"$\frac{dP}{dt}$")
		plot!(rateplot_2, [K_2 for p in -2:3] , -2:3,
				color = "darkgrey",
				linestyle = :dash,
				label = "";
				annotatios = (K_2, 1, "P=K"))
		plot!(rateplot_2, population_2, [r_2 * p for p in population_2],
				color = "grey",
				linestyle = :dot,
				label = L"$\frac{dP}{dt} = rP$")

	
	
	simplot_2 = plot(time_2, sim_pop_2, 
				color = "red",
				ylims = (0,100), 
				title = "Simulation",
				label = "",
				xlabel = "t", ylabel = "P")
		plot!(simplot_2, time_2 , [K_2 for t in time_2],
				color = "darkgrey",
				linestyle = :dash,
				label = "",
				annotatios = ([40], [K_2], "P=K"))
	plot(rateplot_2, simplot_2, layout = (1, 2),fontfamily="Computer Modern")
end

# ╔═╡ 64b31f38-9149-11eb-11a0-718a61330e76
md"""
The corresponding rate plot looks like a prabola that crosses the x-axis at $P=0$ and $P=K$ and has a maximum at $P=\frac{K}{2}$. The x-crossings are important. Here, the growth rate is $0$, so they represent **equilibria**.  However, the two equilibria are not the same: Just to the right of $P=0$, the growth rate increases, so the equilibrium is **unstable**. The case for the equilibrium at $P=K$ is different: if $P<K$, the growth rate is positive, whereas the growth rate is negative if $P>K$. Consequently, the population will be attracted to $P=K$ from both sides. This is called a **stable equilibrium** - small fluctuations around $P=K$ will result in the population falling back to $P=K$.

Using the insight gained from the rate plot, we can infer the shape of the curve for $P(t)$. It will be *s-shaped* or *sigmoidal*, reflecting the change in growth rate around $P=\frac{K}{2}$, and level off around $P=K$.
"""

# ╔═╡ 6f8ed9ce-9149-11eb-2c08-1b1e1f3e3f5c
md"""
### Analytic solution
To obtain an explicit formula for $P(t)$, we need to marshall what we've learned so far, integrate, and brace ourselves for quite a bit of algebra...

To make our lives a bit easier, we rearrange the equation as follows

$$(18) \frac{dP}{dt} = r_{max}P(1-\frac{P}{K}) = r_{max}P(\frac{K}{K}-\frac{P}{K})= \frac{r_{max}}{K}P(K-P) = rP(K-P)$$

Next, we separate our variables:

$$(19) \int \frac{1}{P(K-P)} dP = r \int dt$$

To solve the integral on the left hand side, it helps to simplify the fraction using a *partial fraction decomposition*. Here we want to decompose our fraction $\frac{1}{P(K-P)}$ into two partial fractions of the form $\frac{A}{P} + \frac{B}{K-P}$, where $A$ and $B$ are constants that can be easily determined as follows:

$$\frac{A}{P} + \frac{B}{K-P} = \frac{1}{P(K-P)}$$

Multiply the two fractions on the left by $P$ and $(K-P)$ respectively to obtain a common denominator with the fraction on the right

$$\frac{A(K-P)}{P(K-P)} + \frac{BP}{P(K-P)} = \frac{1}{P(K-P)}$$
Multiply the whole expression by $P(K-P)$ and rearrange to find

$$AK + P(B-A) = 1 \rightarrow A,B = \frac{1}{K}$$

Hence,

$$\frac{1}{K} (\frac{1}{P} + \frac{1}{K-P}) = \frac{1}{P(K-P)}$$

Substituting the partial fraction decomposition into equation (19), we obtain
$$(20) \frac{1}{K} \int \frac{1}{P} + \frac{1}{K-P} dP = r \int dt$$

This way of rearranging our expression allows us to treat each fraction separately

$$(21) \frac{1}{K} (\int \frac{1}{P} dp + \int \frac{1}{K-P} dP) = r \int dt$$

###### Finding integrals by substitution
We already know how to integrate the first fraction - $\int \frac{1}{P} dP = ln(P) + C_1$, as well as the right hand side - $r \int dt = rt + C_2$. However, to integrate the second fraction, we need to use substitution. 
Let 

$$(22) u = K-P$$

It follows that 

$$(23)\frac{du}{dP} = -1 \rightarrow  du = -dP \rightarrow dP = - du$$

We substitute equations (21) and (23) into $\int \frac{1}{K-P} dP$ and obtain$-\int \frac{1}{u} du$, which can be easily integrated and gives $-ln(u) +C =-ln(K-P) + C_3$. Plugging our solved integrals into equation (21) and absorbing our various constants into a new constant $B$, we get

$$(24) \frac{1}{K}[ln(P) - ln(K-P)] = rt + B$$

Using the identity $ln(a) - ln(b) = ln(\frac{a}{b})$, this rearranges to

$$(25) ln(\frac{P}{K-P}) = rKt + B$$

Applying the exponential function to both sides yields

$$(26) \frac{P}{K-P} = e^{rKt + B} = e^{rKt} \cdot e^{B}$$

Let $A = e^B$:

$$(27) \frac{P}{K-P} = Ae^{rKt}$$

###### Finding the value of the constant A

Let $P_0 = P(0)$ and $t=0$:

$$(28) \frac{P_0}{K-P_0} = A$$

Hence,

$$(29) \frac{P}{K-P} = \frac{P_0}{K-P_0}e^{rKt}$$

###### Solve expression for P

$$(30) P(K-P_0) = P_0(K-P)e^{rKt} = P_0Ke^{rKt} - P_0Pe^{rKt}$$

Next, we collect the terms that depend on $P$:

$$(31) P(K-P_0) + P_0Pe^{rKt} = P_0Ke^{rKt}$$

$$(32) P[(K-P_0) + P_0e^{rKt}] = P_0Ke^{rKt}$$

$$(33) P = \frac{P_0Ke^{rKt}}{(K-P_0) + P_0e^{rKt}}$$

This can be rewritten as

$$(34) P(t) = \frac{K}{\frac{K-P_0}{P_0}e^{-rKt} + 1}$$

## Conclusion
And that is that. Solving differential equations this way is possible for some, but not all. The algebra gets hairy quite quickly, particularly, when looking at systems of differential equations, where differential equations for two or more variables depend on each other. In such instances, we obtain timecourses by simulating these systems numerically. More on this soon...

"""

# ╔═╡ Cell order:
# ╟─89fcfe1c-913a-11eb-1b04-0d87fd8dbcbe
# ╟─9f7c1628-9139-11eb-0d69-f910a995eca7
# ╟─babc9748-9139-11eb-0da1-0d942d591481
# ╟─ee2bb580-9145-11eb-2bc2-dbd9aae68be9
# ╟─001fc24a-9146-11eb-39b9-955dac6bcf58
# ╟─ad08de50-913d-11eb-3f87-fb27a282bdb3
# ╟─f58d273e-9139-11eb-0fe0-b11e90166682
# ╟─aa53e7e0-913d-11eb-32ab-4fc1ce2b72ab
# ╟─008851e2-9147-11eb-3b1c-0ff07fd4e84f
# ╟─20245898-9147-11eb-16cb-7320a2ffbe0d
# ╟─24f0552e-9148-11eb-1226-c326de038a70
# ╟─3d7b3688-9148-11eb-3224-9b832c4692d9
# ╠═5fbb5af8-9148-11eb-0ade-b3fd39af29c1
# ╟─64b31f38-9149-11eb-11a0-718a61330e76
# ╟─6f8ed9ce-9149-11eb-2c08-1b1e1f3e3f5c
