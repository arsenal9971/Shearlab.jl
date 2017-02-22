module Shearlab

using Images
using Wavelets
using PyPlot

export 
			WT, filt_gen, resize_image, load_image, imageplot, 
			rescale, plot_wavelet,subsampling, upsampling, 
			cconvol, reverse, clamp, perform_wavorth_transform, snr,
			padarray, fliplr, upsample, fix, dshear, checkfiltersizes, Filterconfigs, 
			Filterswedgebandlow, getwedgebandpasslowpassfilters2D, Preparedfilters,
			preparefilters2D, getshearletidxs2D, Shearletsystems2D, getshearletsystem2D,
			 sheardec2D, shearrec2D

include("./util/operations.jl")
include("./util/getshearlets2D.jl")
include("./2D/shearletdecrec.jl")
include("./fast_wavelet/filters.jl")
include("./fast_wavelet/operations_wavelet.jl")
include("./fast_wavelet/imaging.jl")

# Alias for functions to have same names as in ShearLab3D
const SLupsample = upsample
const SLdshare = dshear
const SLcheckFilterSizes = checkfiltersizes 
const SLWedgeBandpassAndLowpassFilters2D = getwedgebandpasslowpassfilters2D
const SLprepareFilters2D = preparefilters2D
const SLgetShearletIdxs2D = getshearletidxs2D
const SLgetShearletSystem2D = getshearletsystem2D
const SLsheardec2D = sheardec2D
const SLshearrec2D = shearrec2D

end #module
