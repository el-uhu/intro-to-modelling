using Plots, PlutoUI, LaTeXStrings, DifferentialEquations, DataFrames, DataFramesMeta, CSV, StatsPlots, Dates

covid_data = DataFrame(CSV.File(download("https://covid.ourworldindata.org/data/owid-covid-data.csv")));

locations = ["Austria"];

D = covid_data[in.(covid_data.location, Ref(locations)), :];

dataplot = @df D plot(cols(Symbol("date")), cols([Symbol(y) for y in ["total_cases"]]), 
group = (:location),
labels = reshape(["$l, $y" for y in ydata for l in locations], 1, :),
fontfamily = "ComputerModern",
legend = :topleft)

plot(dataplot)