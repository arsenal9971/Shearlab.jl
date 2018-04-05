# Submodule to compute the coefficients of shearlet recovery and decoding in 2D


##############################################################################
## Function that compute the coefficient matrix of the Shearlet Transform of
## some array
"""
...
sheardec2D(X,shearletSystem) compute the coefficient matrix of the Shearlet
transform of the array X
...
"""
function sheardec2D(X,shearletSystem)
    #Read the GPU info of the system
    gpu = shearletSystem.gpu;
    if gpu == 1
        coeffs = AFArray(zeros(Complex{Float32},size(shearletSystem.shearlets)));
    else
        coeffs = zeros(Complex{Float64},size(shearletSystem.shearlets));
    end
    # The fourier transform of X
    Xfreq = fftshift(fft(ifftshift(X)));
    #compute shearlet coefficients at each scale
    #not that pointwise multiplication in the fourier domain equals convolution
    #in the time-domain
    for j = 1:shearletSystem.nShearlets
        coeffs[:,:,j] = fftshift(ifft(ifftshift(Xfreq.*conj(shearletSystem.shearlets[:,:,j]))));  
    end
    return coeffs
end # sheardec2D


##############################################################################
## Function that recovers the image with the Shearlet transform with some shearletSystem
"""
...
shearrec2D(coeffs,shearletSystem) function that recovers the image with the Shearlet transform with some shearletSystem
...
"""
function shearrec2D(coeffs,shearletSystem)
    # Initialize reconstructed data
    gpu = shearletSystem.gpu;
    if gpu == 1
        X = AFArray(zeros(Complex{Float32},size(coeffs,1),size(coeffs,2)));
    else
        X = zeros(Complex{Float64},size(coeffs,1),size(coeffs,2));
    end
    for j = 1:shearletSystem.nShearlets
        X = X+fftshift(fft(ifftshift(coeffs[:,:,j]))).*shearletSystem.shearlets[:,:,j];
    end
    return real(fftshift(ifft(ifftshift((1./shearletSystem.dualFrameWeights).*X))))
end# shearrec2D

##############################################################################
## Function that compute the array of the adjoint Shearlet Transform of
## some coefficients matrix
"""
...
sheardecadjoint2D(coeffs,shearletSystem) compute the adjoint of the decomposition operator
...
"""
function sheardecadjoint2D(coeffs,shearletSystem)
		# Initialize reconstructed data
    gpu = shearletSystem.gpu;
    if gpu == 1
        X = AFArray(zeros(Complex{Float32},size(coeffs,1),size(coeffs,2)));
    else
        X = zeros(Complex{Float64},size(coeffs,1),size(coeffs,2));
    end
    for j = 1:shearletSystem.nShearlets
        X = X+fftshift(fft(ifftshift(coeffs[:,:,j]))).*conj(shearletSystem.shearlets[:,:,j]);
    end
    return real(fftshift(ifft(ifftshift((1./shearletSystem.dualFrameWeights).*X))))

end # sheardecadjoint2D

##########################################################################################
## Function that compute the coefficient matrix of the adjoint inverse Shearlet Transform of
## some array
"""
...
shearrecadjoint2D(X,shearletSystem) compute the coefficient matrix of the adjoint inverse Shearlet
transform of the array X
...
"""
function shearrecadjoint2D(X,shearletSystem)
    #Read the GPU info of the system
    gpu = shearletSystem.gpu;
    if gpu == 1
        coeffs = AFArray(zeros(Complex{Float32},size(shearletSystem.shearlets)));
    else
        coeffs = zeros(Complex{Float64},size(shearletSystem.shearlets));
    end
    # The fourier transform of X
    Xfreq = fftshift(fft(ifftshift(X)));
    #compute shearlet coefficients at each scale
    #not that pointwise multiplication in the fourier domain equals convolution
    #in the time-domain
    for j = 1:shearletSystem.nShearlets
        coeffs[:,:,j] = fftshift(ifft(ifftshift(Xfreq.*shearletSystem.shearlets[:,:,j])));  
    end
    return coeffs
end # shearrecadjoint2D

