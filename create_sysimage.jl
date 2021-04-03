using PackageCompiler
create_sysimage([:Plots, :PlutoUI, :LaTeXStrings, :DifferentialEquations, :DataFrames, :DataFramesMeta, :CSV, :StatsPlots, :Dates];
                precompile_execution_file="warmup.jl",
                replace_default=true,
                cpu_target = PackageCompiler.default_app_cpu_target())