# Submodule to compute the coefficients of shearlet in serial in 2D and its reconstruction

# Type for the shearlet serial prepared filters

struct Serialpreparedfilters
		Xfreq
		Xrec
		preparedFilters
		dualFrameWeightsCurr
		shearletIdxs
end

##############################################################################
## Function that prepare the serial shearlet transform

"""
...
prepareserial2D(X,nScales,shearLevels = ceil.((1:nScales)/2), full = 0,
directionalFilter = filt_gen("directional_shearlet") , quadratureMirrorFilter = filt_gen("scaling_shearlet"))
...
"""
function prepareserial2D(X,nScales,shearLevels = ceil.((1:nScales)/2), full = 0,
directionalFilter = filt_gen("directional_shearlet") , quadratureMirrorFilter = filt_gen("scaling_shearlet"))
		shearLeveles = map(Int,shearLevels)
		# Compute the fft transform
		Xfreq = fftshift(fft(ifftshift(X)));
		# Compute prepared filters
		preparedFilters = preparefilters2D(size(X,1),size(X,2),nScales,shearLevels,directionalFilter,quadratureMirrorFilter)
		# Compute dual frames
		dualFrameWeightsCurr = zeros(size(X));
		Xrec = zeros(size(X));
		# Compute the indices
		shearletIdxs = getshearletidxs2D(shearLevels,full);

		# Assign values to the type
		return Serialpreparedfilters(Xfreq, Xrec, preparedFilters, dualFrameWeightsCurr, shearletIdxs)
end #prepareserial2D

# Type for the 2D serial sheralet decompostion
struct Sheardecserial2D
		coeffs
		shearlet
		dualFrameWeightsNew
		RMS
end

##############################################################################
## Function that decompose a signal in frequency domain in serial
"""
...
sheardecserial2D(Xfreq, ShearletIdx, preparedFilters, dualFrameWeightsCurr) decompose a signal in frequency domain in serial
...
"""
function sheardecserial2D(Xfreq, shearletIdx, preparedFilters, dualFrameWeightsCurr)
		# Compute the serial decomposition
		Shearlets2D = Shearlab.getshearlets2D(preparedFilters,shearletIdx);
		shearlet = Shearlets2D.shearlets;
		RMS = Shearlets2D.RMS;
		dualFrameWeights = Shearlets2D.dualFrameWeights;
		dualFrameWeightsNew = dualFrameWeightsCurr+dualFrameWeights;
		coeffs = fftshift(ifft(ifftshift(conj(shearlet).*Xfreq)));
		return Sheardecserial2D(coeffs, shearlet, dualFrameWeightsNew, RMS)
end # sheardecserial2D

##############################################################################
## Function that makes the serial recovery
"""
...
shearrecserial2D(coeffs, shearlet, Xrec) serial recovery of coefficients with certain shearlet
...
"""
function shearrecserial2D(coeffs, shearlet, Xrec)
		return Xrec+fftshift(fft(ifftshift(coeffs))).*shearlet;
end # shearrecserial2D

##############################################################################
## Function that finishes the serial recovery
"""
...
finishserial2D(Xrec,dualFrameWeightsCurr) serial recovery of coefficients with certain shearlet
...
"""
function finishserial2D(Xcurr, dualFrameWeights)
		return fftshift(ifft(ifftshift((1 ./dualFrameWeights).*Xcurr)))
end # shearrecserial2D
