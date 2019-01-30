#!/usr/bin/env julia

using Shearlab, Test
@time @testset "Wavelet Transform Size" begin include("wavelet_trans_size.jl") end
@time @testset "Wavelet Inverse Transform Size" begin include("wavelet_inv_size.jl") end
@time @testset "Shearlet Transform Size" begin include("shearlet_trans_size.jl") end
@time @testset "Shearlet Inverse Transform Size" begin include("shearlet_inv_size.jl") end
