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

# ╔═╡ 04be2568-92b7-11eb-1d59-97cd595d320d
#Set up the working environment
begin
	using Pkg
	Pkg.activate("..")
	using Plots, PlutoUI, LaTeXStrings, DifferentialEquations, DataFrames, DataFramesMeta, CSV, StatsPlots, Dates, Flux, Optim, DiffEqFlux, DiffEqSensitivity
end

# ╔═╡ 39a8b108-92d0-11eb-2442-1f47a7e9b445
md"""
# Interactive exploration of the "Our World in Data" Covid-19 Dataset

More information: [https://github.com/owid/covid-19-data/tree/master/public/data](https://github.com/owid/covid-19-data/tree/master/public/data)
"""

# ╔═╡ 53479e94-92b7-11eb-2731-c7e03afeb549
# Download dataset
covid_data = DataFrame(CSV.File(download("https://covid.ourworldindata.org/data/owid-covid-data.csv")));

# ╔═╡ cd146c8a-92bb-11eb-2811-c541ca9cef7b
md"""
| Countries     | y-axis      |
|---------------|-------------|
| $(@bind locations MultiSelect(unique(covid_data.location), default=["Austria"])) | $(@bind ydata MultiSelect(names(covid_data), default=["total_cases"])) |
"""

# ╔═╡ 059abcfc-92b8-11eb-0bcc-6f688494a3cb
# Filter data for Austria
D = covid_data[in.(covid_data.location, Ref(locations)), :];

# ╔═╡ bef90d4e-92c8-11eb-2539-19bf3fc70791
md"""
| Plot range   | value                       |
|--------------|-----------------------------|
| xmin         | $(@bind xmn Slider(1:1:length(unique(D[!,"date"]))-1, default=0)) | 
| xmax         | $(@bind xmx Slider(1:1:length(unique(D[!,"date"]))-1, default=length(unique(D[!,"date"]))-1)) |
"""

# ╔═╡ 68b6d4b2-92cd-11eb-1d2e-5de1d1be1d95
begin
	xmin = minimum(D[!,"date"]) + Day(xmn);
	xmax = minimum(D[!,"date"]) + Day(xmx);
end;

# ╔═╡ b5dc1850-92c1-11eb-2934-6788cb4a2d6a
begin
	dataplot = @df D plot(cols(Symbol("date")), cols([Symbol(y) for y in ydata]), 
			group = (:location),
			xlims = (xmin, xmax),
			labels = reshape(["$l, $y" for y in ydata for l in locations], 1, :),
			fontfamily = "ComputerModern",
			legend = :topleft)

	plot(dataplot)
end

# ╔═╡ Cell order:
# ╟─39a8b108-92d0-11eb-2442-1f47a7e9b445
# ╠═04be2568-92b7-11eb-1d59-97cd595d320d
# ╠═53479e94-92b7-11eb-2731-c7e03afeb549
# ╠═059abcfc-92b8-11eb-0bcc-6f688494a3cb
# ╟─cd146c8a-92bb-11eb-2811-c541ca9cef7b
# ╟─bef90d4e-92c8-11eb-2539-19bf3fc70791
# ╟─68b6d4b2-92cd-11eb-1d2e-5de1d1be1d95
# ╠═b5dc1850-92c1-11eb-2934-6788cb4a2d6a
