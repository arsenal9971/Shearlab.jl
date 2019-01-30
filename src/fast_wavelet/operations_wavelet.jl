# Submodule for basic wavelets operations


###################################################
# Function that remove empty trailing dimensions
function trim_dim(x)
	if size(x,3)==1
		x = x[:,:,1];
		if size(x,2)==1
			x = x[:,1];
		end
	end
	return x;
end # trim_dim

###################################################
# Function that make a subsampling of an array
# along dimension d
"""
...
subsampling(x,d=1,p=2) subsampling of an array x, along dimension d, by a
factor of p, for d≤3
...
"""
function subsampling(x,d=1,p=2)
	if d==1
	        y = x[1:p:end,:,:];
	elseif d==2
	        y = x[:,1:p:end,:];
	elseif d==3
	        y = x[:,:,1:p:end];
	else
	        error("Not implemented");
	end
	y = trim_dim(y);
	return y;
end # subsampling

###################################################
# Function that make a upsampling of an array
# along dimension d
"""
...
upsampling(x,d=1,p=2) upsampling of an array x, along dimension d, by a
factor of p, for d≤3
...
"""
function upsampling(x,d=1,p=2)
	if d==1
	        y = zeros(p*size(x,1),size(x,2),size(x,3));
	        y[1:p:end,:,:] = x;
	elseif d==2
	        y = zeros(size(x,1),p*size(x,2),size(x,3));
	        y[:,1:p:end,:] = x;
	elseif d==3
	        y = zeros(size(x,1),size(x,2),p*size(x,3));
	        y[:,:,1:p:end] = x;
	else
	        error("Not implemented");
	end
	y = trim_dim(y);

	return y;
end # upsampling


###################################################
# Function to compute the spatial domain circular
# convolution of two signals
"""
...
cconv(x,h,d=1) circular convolution along dimension d, of
signals x and h
...
"""
function cconvol(x,h,d=1)
	#   If p=length(h) is odd then h((p+1)/2) corresponds to the zero position.
	#   If p is even, h(p/2) corresponds to the zero position.
	if d==2
	    return ( cconvol( x',h, 1 )' );
	elseif d==3
		# permute do not exists in python
	    return permute( cconvol( permute(x,[3, 2, 1]),h), [3 2 1]);
	end
	p = length(h);
	if mod(p,2)==0
	    pc = p/2;
	else
	    pc = (p+1)/2;
	end
	y = zeros(size(x));
	for i=1:length(h)
	    y = y + h[i]*circshift(x,i-pc);
	end
	return y;
end # cconvol


#####################################
# Function that computes the mirror
# filter
"""
...
mirror(h::Array) computes the mirror filter of h[n], namely
g[n] = (-1)^(1-n) h[1-n]
...
"""
function mirror(h)
	# cat(1, 0, h[length(h):-1:2]) .* ( (-1).^(0:(length(h)-1)) )
        h.*(-1).^(0:(length(h)-1))
end #mirror

#####################################
# Function that clamps a value
"""
...
clamp(x::Array, a=0,b=1) clamps a value in [a,b](=[0,1] by default)
...
"""
function clamp(x,a=0,b=1)
	y = max(x,a);
	y = min(y,b);
	return y;

end # clamp

#########################################
# Function to subselect dimensions in an
# array
function subselectdim(f,sel,d)
	g = [];
	if d==1
	    g = f[sel,:,:];
	elseif d==2
	    g = f[:,sel,:];
	elseif d==3
	    g = f[:,:,sel];
	end
	return trim_dim(g);
end


#########################################
# Function to assign value to elements
# of an array
function subassign(f,sel,g)
	d = ndims(f);
	if d==1
	    f[sel] = g;
	elseif d==2
	    f[sel,sel] = g;
	elseif d==3
	    f[sel,sel,sel] = g;
	end
	return f;
end # subassign


#########################################
# Function to select elements of an array
function subselect(f,sel)
	d = ndims(f)
    if d==1
        return f[sel];
    elseif d==2
        return f[sel,sel];
    elseif d==3
        return f[sel,sel,sel];
	end
	return [];
end


##############################################################
# Function to perform wavelet orthognal transform of a signal
# f0, with Jmin minimum scale, dir dirección, and h a filter
"""
...
perform_wavortho_transform(f0:::Array, Jmin:::int,dir,h) computes
the wavelet transform of a signal f0, with Jmin as the minimum
scale in the direction dir∈{-1,1}
...
"""
function perform_wavortho_transf(f0,Jmin,dir,h)

	n = size(f0,1);
	Jmax = round(Int64,log2(n))-1;

	g = [0; h[length(h):-1:2]] .* (-1).^(1:length(h));

	f = copy(f0)
	if dir==1
	    ### FORWARD ###
	    for j=Jmax:-1:Jmin
	        sel = 1:2^(j+1);
	        a = subselect(f,sel);
	        for d=1:ndims(f)
	            a = cat(d, subsampling(cconvol(a,h,d),d), subsampling(cconvol(a,g,d),d) );
	        end
	        f = subassign(f,sel,a);
	    end
	else
	    ### FORWARD ###
	    for j=Jmin:Jmax
	        sel = 1:2^(j+1);
	        a = subselect(f,sel);
	        for d=1:ndims(f)
	            w = subselectdim(a,2^j+1:2^(j+1),d);
	            a = subselectdim(a,1:2^j,d);
	            a = cconvol(upsampling(a,d),reverse(h),d) + cconvol(upsampling(w,d),reverse(g),d);
	        end
	        f = subassign(f,sel,a);
	    end
	end
	return f;
end # perform_wavortho_transf

#####################################################
# Function that computes the signal to noise radio
"""
...
snr(x::Array,y:::Array) computes the siganl to noise radio
of a original clean signal x and a denoised signal y
...
"""
function snr(x,y)
	return 20*log10(norm(x[:])/norm(x[:]-y[:]));
end # snr
