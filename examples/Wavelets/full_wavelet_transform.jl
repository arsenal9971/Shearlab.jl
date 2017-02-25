# Example that computes the full forward wavelet transform using all the
#import libraries
using Shearlab
using PyPlot
using Images

n = 1024;
name = "./../../data_samples/boat.bmp";
f = load_image(name, n);
f = rescale(sum(f,3));
f = f[:,:,1];

# filter call
h=filt_gen(WT.db2)
# high pass filter
g = cat(1, 0, h[length(h):-1:2]) .* ( (-1).^(1:length(h)) )
g = cat(1, 0, h[length(h):-1:2]) .* ( (-1).^(1:length(h)) )

# Perform of the wavelet transform
Jmax = round(Int64,log2(n))-1;
Jmin = 1;
fW = copy(f);
clf;
for j=Jmax:-1:Jmin
    A = fW[1:2^(j+1),1:2^(j+1)];
    for d=1:2
        Coarse = subsampling(cconvol(A,h,d),d);
        Detail = subsampling(cconvol(A,g,d),d);
        A = cat(d, Coarse, Detail );
    end
    fW[1:2^(j+1),1:2^(j+1)] = A;
    j1 = Jmax-j;
    if j1<4
        imageplot(A[1:2^j,2^j+1:2^(j+1)], "Horizontal, j=$j", 3,4, j1 + 1);
        imageplot(A[2^j+1:2^(j+1),1:2^j], "Vertical, j=$j", 3,4, j1 + 5);
        imageplot(A[2^j+1:2^(j+1),2^j+1:2^(j+1)], "Diagonal, j=$j", 3,4, j1 + 9);
    end
end
