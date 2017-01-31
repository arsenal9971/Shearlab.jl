# Submodule to compute the coefficients of shearlet recovery and decoding in 2D

##############################################################################
## Function that compute the coefficient matrix of the Shearlet Transform of
## some array
"""
...
SLsheardec2D(X,shearletSystem) compute the coefficient matrix of the Shearlet
transform of the array X
...
"""
function SLsheardec2D(X,shearletSystem)
    # As there is no cuda implementation yet
    coeffs = zeros(size(shearletSystem.shearlets))+im*zeros(size(shearletSystem.shearlets));
    # The fourier transform of X
    Xfreq = fftshift(fft(ifftshift(X)));
    #compute shearlet coefficients at each scale
    #not that pointwise multiplication in the fourier domain equals convolution
    #in the time-domain
    for j = 1:shearletSystem.nShearlets
        coeffs[:,:,j] = fftshift(ifft(ifftshift(Xfreq.*conj(shearletSystem.shearlets[:,:,j]))));  
    end
    coeffs
end

##############################################################################
## Function that recovers the image with the Shearlet transform with some shearletSystem
"""
...
SLshearrecc2D(coeffs,shearletSystem) function that recovers the image with the Shearlet transform with some shearletSystem
...
"""
function SLshearrec2D(coeffs,shearletSystem)
    # Initialize reconstructed data
    X = zeros(size(coeffs,1),size(coeffs,2))+im*zeros(size(coeffs,1),size(coeffs,2));

    for j = 1:shearletSystem.nShearlets
        X = X+fftshift(fft(ifftshift(coeffs[:,:,j]))).*shearletSystem.shearlets[:,:,j];
    end
    real(fftshift(ifft(ifftshift((1./shearletSystem.dualFrameWeights).*X))))
end
