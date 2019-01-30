n = 512;

f = rand(n,n);

h = filt_gen(WT.db2)

g = [0, h[length(h):-1:2]...] .* ( (-1).^(1:length(h)));

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

@test size(fW) == size(f)
