module Shearlab

using Images
using Wavelets
using PyPlot
push!(LOAD_PATH,pwd()*"/../../FWT.jl/src") # for julia 0.5 you need to put your path
using FWT

export Shear2D, DigitalShearing2D, padArray, filt_scales,fliplr, SLupsample, fix, SLdshear, SLgetWedgeBandpassAndLowpassFilters2D, SLcheckFilterSizes, SLprepareFilters2D,SLgetShearletSystem2D, SLsheardec2D,SLload_image, SLshearrecD


#include("./2D/DigitalShear2D.jl")
#include("./2D/ShearlabFilter2D.jl")
include("./2D/shearletDecRec.jl")
include("./Util/operations.jl")
include("./Util/getShearlets2D.jl")


end #module
