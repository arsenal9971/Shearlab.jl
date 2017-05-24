# Submodule for imaging functions 

#######################################
# Function to resize an array representation
# of an image to a certain number of pixeles
function resize_image(f, N)
  if size(f,1) > size(f,2)
		f = reshape(f,size(f,2),size(f,1),size(f,3));
  end
	P = size(f,1);
	# add 1 pixel boundary
	g = f;
	g = cat(2, g, reshape(g[:,1,:],size(g,1),1,size(g,3)));
  g = cat(1, g, reshape(g[1,:,:],1,size(g,2),size(g,3)));
	# interpolate
	t = linspace(1,P,N);
	ti = round(Int64,floor(t)) ; tj = round(Int64,ceil(t));
	fi = round(Int64,t-floor(t)); fj = 1-fi;
	h = zeros(N,N,size(f,3));
	for s in 1:size(f,3)
	    h[:,:,s] = g[ti,ti,s] .* (fj*fj') + g[tj,tj,s] .* (fi*fi') + g[ti,tj,s] .* (fj*fi') + g[tj,ti,s] .* (fi*fj');
	end
	return h;
end # resize_image


#######################################
# Function that load an image in a local path
# and resize it to a certain number of pixeles
"""
...
load_image(path::string,pixels::int) load an image in a local path 
with N=nxn pixeles
...
"""
function load_image(name,n,gpu=0)
		if gpu == 0
   			# Load image
   			f = Images.load(name);
   			# Read the old size of f
    		old_size = size(f)
    		# Size in y
   			m = round(Int64,n*old_size[2]/old_size[1])
				resized_name = split(name,"/")
				resized_name = "resized_"*resized_name[size(resized_name)[1]]
    		Images.save(resized_name,imresize(f,(n,m)))
    		f = convert(Array{Float64},PyPlot.imread(resized_name));
    		rm(resized_name)
		else 
				f = PyPlot.imread(name);
				f = resize_image(f, n);
		end
		return f;
end

#######################################
# Function that show the image associated
# to a nxn array
"""
...
imageplot(g::Array,title::str="", a=-1, b=-1, c=-1) show the image
associated to a nxn array, with title coordinates in multiplo (a,b,c)
...

"""
function imageplot(g, str="", a=-1, b=-1, c=-1)
	if size(g,3)==1
		# special for b&w images.
		g = g[:,:,1];
	end
	if c>0
		subplot(a,b,c);
	end
	imshow(g, interpolation="nearest")
	set_cmap("gray")
	axis("off")
	if str!=""
		title(str);
	end
end #imageplot


#####################################
# Function that rescales date in a,b
"""
...
rescale(x::Array,a=0,b=1) rescales data in 
[a,b]
...
"""
function rescale(x,a=0,b=1)
	m = minimum(x[:]);
	M = maximum(x[:]);

	if M-m<1e-10
	    y = x;
	else
	    y = (b-a) * (x-m)/(M-m) + a;
	end
	return y;

end ## rescale

#####################################################
# Function that rescales a wavelet transform in an array A
function rescaleWav(A)
    v = maximum( abs(A[:]) );
    B = copy(A)
    if v > 0
        B = .5 + .5 * A / v;
    end
    return B;
end

#####################################################
# Function that makes a plot of wavelet coefficients
"""
...
plot_wavelet(fW::Array, Jmin=0) plot of the wavelet
transform with the transformed image data fW an the 
minimum scale
...
"""
function plot_wavelet(fW, Jmin=0)
    n = size(fW,1);
    Jmax = round(Int64,log2(n)) - 1;
    U = copy(fW);
    for j = Jmax:-1:Jmin
    	L = 1:2^j; H = (2^j)+1:2^(j+1);
        U[L,H] = rescaleWav( U[L,H] );
        U[H,L] = rescaleWav( U[H,L] );
        U[H,H] = rescaleWav( U[H,H] );
    end
    # coarse scale
    L = 1:2^Jmin;
    U[L,L] = rescale(U[L,L]);
    # plot underlying image
    imageplot(U);
    # display crosses
    for j=Jmax:-1:Jmin
        plot([0, 2^(j+1)], [2^j, 2^j], "r");
        plot([2^j, 2^j], [0, 2^(j + 1)], "r");
    end
    # display box
    plot([0, n], [0, 0], "r");
    plot([0, n], [n, n], "r");
    plot([0, 0], [0, n], "r");
    plot([n, n], [0, n], "r");
    return U;

end # plot_wavelet
