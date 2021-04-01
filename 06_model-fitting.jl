### A Pluto.jl notebook ###
# v0.12.21

using Markdown
using InteractiveUtils

# ╔═╡ 9e5aea54-92de-11eb-0d56-63aaed548c40
#Set up the working environment
begin
	using Pkg
	Pkg.activate(".")
	using Plots, PlutoUI, LaTeXStrings, DifferentialEquations, DataFrames, DataFramesMeta, CSV, StatsPlots, Dates, Flux, Optim, DiffEqFlux, DiffEqSensitivity
end

# ╔═╡ b21a52aa-92de-11eb-1e35-9fe3a1669e69
# Download dataset
covid_data = DataFrame(CSV.File(download("https://covid.ourworldindata.org/data/owid-covid-data.csv")));

# ╔═╡ c2a44dba-92de-11eb-0ae9-b730b2c52e05
# Extract vaccination data for Austria in 2021
vdata = @linq covid_data |>
           where(:date .>= Date("2021-01-01")) |>
		   where(:location .== "Austria") |>
           select(:date, :total_vaccinations, :population)

# ╔═╡ c7513116-92de-11eb-26e7-6b3d34e7421f
# Calculate fraction of population vaccinated
vaccinated = vdata[!, :total_vaccinations][1:end-1] ./ vdata[!, :population][1:end-1]

# ╔═╡ c89a3036-92de-11eb-0c96-57ff3cd6ec35
function vmodel!(du, u, p, t)
	du[1] = p[1] * u[1]
end

# ╔═╡ d6038830-92de-11eb-1ae9-c19a041cc4a0
u0 = [0.00055]

# ╔═╡ de2ddf88-92de-11eb-322d-fb912473c558
tspan = (0.0, 88.0)

# ╔═╡ e313ac28-92de-11eb-3feb-21e174a352e5
tsteps = 0.0:1.0:88.0

# ╔═╡ e8485124-92de-11eb-02ac-7d66901e519e
prob = ODEProblem(vmodel!, u0, tspan, p)

# ╔═╡ f01c2e34-92de-11eb-188d-7951b0fac647
sol = solve(prob, Tsit5(), saveat = tsteps)

# ╔═╡ 00dc1ae0-92df-11eb-1029-4d4a11493aad
function loss(p)
	sol = solve(prob, Tsit5(), p=p, saveat = tsteps)
	loss = sum(([s[1] for s in sol.u] - vaccinated).^2)
	return loss, sol
end

# ╔═╡ ff838598-92de-11eb-0cef-9b64517b5f6c
callback = function (p, l, pred)
  display(l)
  plt = plot(pred, ylim = (0, 0.15))
  display(plt)
  # Tell sciml_train to not halt the optimization. If return true, then
  # optimization stops.
  return false
end

# ╔═╡ 14f81ab0-92df-11eb-2bf7-0193a6cb2ad0
result_ode = DiffEqFlux.sciml_train(loss, p,
                                    ADAM(0.1),
                                    cb = callback,
                                    maxiters = 100)

# ╔═╡ Cell order:
# ╠═9e5aea54-92de-11eb-0d56-63aaed548c40
# ╠═b21a52aa-92de-11eb-1e35-9fe3a1669e69
# ╠═c2a44dba-92de-11eb-0ae9-b730b2c52e05
# ╠═c7513116-92de-11eb-26e7-6b3d34e7421f
# ╠═c89a3036-92de-11eb-0c96-57ff3cd6ec35
# ╠═d6038830-92de-11eb-1ae9-c19a041cc4a0
# ╠═de2ddf88-92de-11eb-322d-fb912473c558
# ╠═e313ac28-92de-11eb-3feb-21e174a352e5
# ╠═e8485124-92de-11eb-02ac-7d66901e519e
# ╠═f01c2e34-92de-11eb-188d-7951b0fac647
# ╠═00dc1ae0-92df-11eb-1029-4d4a11493aad
# ╠═ff838598-92de-11eb-0cef-9b64517b5f6c
# ╠═14f81ab0-92df-11eb-2bf7-0193a6cb2ad0
