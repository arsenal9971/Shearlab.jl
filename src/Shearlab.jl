module Shearlab

using Images
using Wavelets
using PyPlot
#using ArrayFire
using DSP

export
			WT, filt_gen, resize_image, load_image, imageplot,
			rescale, plot_wavelet,subsampling, upsampling,
			cconvol, reverse, clamp, perform_wavorth_transform, snr,
			padarray, fliplr, upsample, fix, dshear, checkfiltersizes, Filterconfigs,
			Filterswedgebandlow, getwedgebandpasslowpassfilters2D, Preparedfilters,
			preparefilters2D, getshearletidxs2D, Shearletsystems2D, getshearletsystem2D,
			Shearlets2D, getshearlets2D,
			sheardec2D, shearrec2D,
			Serialpreparedfilters, prepareserial2D, Sheardecserial2D, sheardecserial2D,
			shearrecserial2D, finishserial2D,
			AFArray

include("util/operations.jl")
include("2D/getshearlets2D.jl")
include("2D/shearletdecrec2D.jl")
include("2D/shearletserialdecrec2D.jl")
include("fast_wavelet/filters.jl")
include("fast_wavelet/operations_wavelet.jl")
include("fast_wavelet/imaging.jl")

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
const SLprepareSerial2D = prepareserial2D
const SLgetShearlets2D = getshearlets2D
const SLsheardecSerial2D = sheardecserial2D
const SLshearrecSerial2D = shearrecserial2D
const SLfinishSerial2D = finishserial2D

end #module
