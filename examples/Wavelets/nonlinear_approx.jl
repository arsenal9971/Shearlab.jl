# Example that performes a NonLinear 2-D Wavelet Approximation
#import libraries
using Shearlab
using FWT
using PyPlot
using Images

n = 1024;
name = "./../../data_samples/boat.bmp";
f = load_image(name, n);
f = rescale(sum(f,3));
f = f[:,:,1];

Jmax = round(Int64, n/eta);
Jmin = 1;

# Display the threshold coefficients
		
clf;
subplot(1,2,1);
plot_wavelet(fW,Jmin);
title("Original coefficients");
subplot(1,2,2);
plot_wavelet(fWT,Jmin);
title("Thresholded coefficients");

# number of kept coefficients
m = round(n^2/16);
# compute the threshold T
Jmin = 1;
fW = FWT.perform_wavortho_transf(f,Jmin,+1, h);
# select threshold
v = sort(abs.(fW[:]));
if v[1]<v[n^2]
    v = FWT.reverse(v);
end
# inverse transform
T = v[round(Int64,m)];
fWT = fW .* (abs.(fW).>T);
# inverse
fnlin = FWT.perform_wavortho_transf(fWT,Jmin,-1, h);
# display
clf;
u1 = @sprintf("Linear, SNR=%.3fdB", snr(f,fLin));
u2 = @sprintf("Non-linear, SNR=%.3fdB", snr(f,fnlin));
imageplot(FWT.clamp(fLin),u1, 1,2,1 );
imageplot(clamp(fnlin),u2, 1,2,2 );
