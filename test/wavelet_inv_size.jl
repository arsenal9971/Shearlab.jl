n = 512;

f = rand(n,n);

h = filt_gen(WT.db2)

g = cat(0, h[length(h):-1:2], dims=1) .* ( (-1).^(1:length(h)) );

Jmax = round(Int64,log2(n))-1;
Jmin = 1;
fW = copy(f);

for j=Jmax:-1:Jmin
    A = fW[1:2^(j+1),1:2^(j+1)];
    for d=1:2
        Coarse = subsampling(cconvol(A,h,d),d);
        Detail = subsampling(cconvol(A,g,d),d);
        A = cat(Coarse, Detail,dims=d);
    end
    fW[1:2^(j+1),1:2^(j+1)] = A;
    j1 = Jmax-j;
end

f1 = copy(fW);

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
        Coarse = cconvol(upsampling(Coarse,d),Shearlab.reverse(h),d);
        Detail = cconvol(upsampling(Detail,d),Shearlab.reverse(g),d);
        A = Coarse + Detail;
        j1 = Jmax-j;
    end
    f1[1:2^(j+1),1:2^(j+1)] = A;
end

@test size(f1) == size(f)
