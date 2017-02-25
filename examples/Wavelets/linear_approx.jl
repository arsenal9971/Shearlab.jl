# Example that performes a Linear 2-D Wavelet Approximation ,

#import libraries
using Shearlab
using PyPlot
using Images

n = 1024;
name = "./../../data_samples/boat.bmp";
f = load_image(name, n);
f = rescale(sum(f,3));
f = f[:,:,1];

Jmax = round(Int64,log2(n))-1;
Jmin = 1;

# Initialize the approximation.
eta = 4;
fWLin = zeros(n,n);
fWLin[1:round(Int64, n/eta),1:round(Int64, n/eta)] = fW[1:round(Int64, n/eta),1:round(Int64, n/eta)];

# Perform and display the approximation
min = 1;
# forward transform
fW = perform_wavortho_transf(f,Jmin,+1,h);
# linear approximation
eta = 4;
fWLin = zeros(n,n);
fWLin[1:round(Int64, n/eta),1:n/round(Int64, n/eta)] = fW[1:n/round(Int64, n/eta),1:round(Int64, n/eta)];
# backward transform
fLin = perform_wavortho_transf(fWLin,Jmin,-1,h);
elin = snr(f,fLin);
# display
clf;
imageplot(f, "Original", 1,2,1);
u = @sprintf("Linear, SNR=%.3f", elin);
imageplot(FWT.clamp(fLin), u, 1,2,2);
