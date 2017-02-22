# Example that computes the full inverse wavelet transform using all the 
# scales from Jmin=1, to Jmax=log2(n)-1 the coarsest scale

#push path 
push!(LOAD_PATH,pwd()*"/src") # for julia 0.4 you need to put your path
#import libraries
using FWT
using PyPlot
using Images

n = 1024;
name = "data_samples/ernst_reuter_haus.bmp";
f = load_image(name, n);
f = rescale(sum(f,3));
f = f[:,:,1];

# filter call 
h=filt_gen(WT.db2)
# high pass filter
g = cat(1, 0, h[length(h):-1:2]) .* ( (-1).^(1:length(h)) )


# First compute wavelet transform 
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

# Now the inverse

f1 = copy(fW);
clf;
for j=Jmin:Jmax
    A = f1[1:2^(j+1),1:2^(j+1)];
    for d=1:2
        if d==1
            Coarse = A[1:2^j,:];
            Detail = A[2^j+1:2^(j+1),:];
        else
            Coarse = A[:,1:2^j];
            Detail = A[:,2^j+1:2^(j+1)];                
        end
        Coarse = cconvol(upsampling(Coarse,d),FWT.reverse(h),d);
        Detail = cconvol(upsampling(Detail,d),FWT.reverse(g),d);
        A = Coarse + Detail;
        j1 = Jmax-j;
        if j1>0 && j1<5
            imageplot(A, "Partial reconstruction, j=$j", 2,2,j1);
        end
    end
    f1[1:2^(j+1),1:2^(j+1)] = A;
end
