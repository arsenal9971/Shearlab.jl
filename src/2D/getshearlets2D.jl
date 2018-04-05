# Submodule that constructs the system of Shearlets in 2D of size rows x cols


######################################################################
## ype of Filterconfigsuration to check the sizes
immutable Filterswedgebandlow
    wedge::AbstractArray
    bandpass::AbstractArray
    lowpass::AbstractArray
end

#######################################################################
# Function that generates the whole Shearlet System filters (wedge, bandpass and lowpass) of size rows x cols
"""
...
getwedgebandpasslowpassfilters2D(rows,cols,directionalFilter = filt_gen("directional_shearlet"), scalingFilter = filt_gen("scaling_shearlet"),gpu = 0)
generates the Wedge, Bandpass and LowspassFilter of size rows x cols
...
"""
function getwedgebandpasslowpassfilters2D(rows::Int,cols::Int,shearLevels,directionalFilter = filt_gen("directional_shearlet"),scalingFilter = filt_gen("scaling_shearlet"),waveletFilter = mirror(scalingFilter),
                                                   scalingFilter2 = scalingFilter,gpu = 0)
    FFTW.set_num_threads(Sys.CPU_CORES)
    # Make shearLevels integer
    shearLevels = map(Int,shearLevels);
    # The number of scales
    NScales = length(shearLevels);

    # Initialize the bandpass and wedge filter
    # Bandpass filters partion the frequency plane into different scales
    if gpu == 1
        bandpass = zeros(Float32,rows,cols,NScales);
        bandpass = AFArray(bandpass+im*zeros(bandpass));
    else
        bandpass = zeros(Float64,rows,cols,NScales);
        bandpass = bandpass+im*zeros(bandpass);
    end

    # Wedge filters partition the frequency plane into different directions
    wedge = Array{Any}(1,round(Int64,maximum(shearLevels)+1));

    # normalize the directional filter directional filter
    if gpu == 1
        directionalFilter = AFArray(convert(Array{Float32},directionalFilter/sum(abs.(directionalFilter[:]))));
    else
        directionalFilter = directionalFilter/sum(abs.(directionalFilter[:]));
    end

    # Compute 1D high and lowpass filters at different scales

    # filterHigh{NScales} = g, and filterHigh{1} = g_J (analogous with filterLow)
    filterHigh = Array{Any}(1,NScales);
    filterLow = Array{Any}(1,NScales);
    filterLow2 = Array{Any}(1,round(Int64,maximum(shearLevels)+1));

    # Initialize wavelet highpass and lowpass filters
    if gpu == 1
        filterHigh[size(filterHigh,2)] = AFArray(convert(Array{Float32},waveletFilter));
        filterLow[size(filterLow,2)] = AFArray(convert(Array{Float32},scalingFilter));
        filterLow2[size(filterLow2,2)] = AFArray(convert(Array{Float32},scalingFilter2));

        # Lets compute the filters in the other scales
        for j = (size(filterHigh)[2]-1):-1:1
            filterLow[j] = convolve(filterLow[size(filterLow,2)],upsample(filterLow[j+1],1,1,1))
            filterHigh[j] = convolve(filterLow[size(filterLow,2)],upsample(filterHigh[j+1],1,1,1))
        end

        # Lets compute the filters in the other scales
        for j=(size(filterLow2)[2]-1):-1:1
            filterLow2[j] = convolve(filterLow2[size(filterLow2,2)],upsample(filterLow2[j+1],1,1,1))
        end
        # Construct the bandpassfilter
        # Need to convert first to complex array since
        for j = 1:size(filterHigh,2)
           bandpass[:,:,j] = -fftshift(fft(ifftshift(padarray(filterHigh[j],[rows,cols],1))));
        end
    else
        filterHigh[size(filterHigh,2)] = waveletFilter;
        filterLow[size(filterLow,2)] = scalingFilter;
        filterLow2[size(filterLow2,2)] = scalingFilter2;

        # Lets compute the filters in the other scales
        for j = (size(filterHigh)[2]-1):-1:1
            filterLow[j] = conv(filterLow[size(filterLow,2)],upsample(filterLow[j+1],1,1))
            filterHigh[j] = conv(filterLow[size(filterLow,2)],upsample(filterHigh[j+1],1,1))
        end

        # Lets compute the filters in the other scales
        for j=(size(filterLow2)[2]-1):-1:1
            filterLow2[j] = conv(filterLow2[size(filterLow2,2)],upsample(filterLow2[j+1],1,1))
        end

        # Construct the bandpassfilter
        # Need to convert first to complex array since
        for j = 1:size(filterHigh,2)
           bandpass[:,:,j] = fftshift(fft(ifftshift(padarray(filterHigh[j],[rows,cols]))));
        end
    end



    ## construct wedge filters for achieving directional selectivity.
    # as the entries in the shearLevels array describe the number of differently
    # sheared atoms on a certain scale, a different set of wedge
    # filters has to be constructed for each value in shearLevels.
    if gpu == 1
        for shearLevel = unique(shearLevels)
            #preallocate a total of floor(2^(shearLevel+1)+1) wedge filters, where
            #floor(2^(shearLevel+1)+1) is the number of different directions of
            #shearlet atoms associated with the horizontal (resp. vertical)
            #frequency cones.
            wedge[shearLevel+1] = AFArray(zeros(Complex{Float32},rows,cols,floor(2^(shearLevel+1)+1)));
            #upsample directional filter in y-direction. by upsampling the directional
            #filter in the time domain, we construct repeating wedges in the
            #frequency domain ( compare abs.(fftshift(fft2(ifftshift(directionalFilterUpsampled)))) and
            #abs.(fftshift(fft2(ifftshift(directionalFilter)))) ).
            directionalFilterUpsampled = upsample(directionalFilter,1,2^(shearLevel+1)-1,1);

            #remove high frequencies along the y-direction in the frequency domain.
            #by convolving the upsampled directional filter with a lowpass filter in y-direction, we remove all
            #but the central wedge in the frequency domain.
            wedgeHelp = conv2(directionalFilterUpsampled, filterLow2[size(filterLow2,2)-shearLevel][:,:])
            wedgeHelp = padarray(wedgeHelp,[rows,cols],1);
            #please note that wedgeHelp now corresponds to
            #conv(p_j,h_(J-j*alpha_j/2)') in the language of the paper. to see
            #this, consider the definition of p_j on page 14, the definition of w_j
            #on the same page an the definition of the digital sheralet filter on
            #page 15. furthermore, the g_j part of the 2D wavelet filter w_j is
            #invariant to shearings, hence it suffices to apply the digital shear
            #operator to wedgeHelp.;

            ## application of the digital shear operator (compare equation (22))

            #upsample wedge filter in x-direction. this operation corresponds to
            #the upsampling in equation (21) on page 15.
            wedgeUpsampled = upsample(wedgeHelp,2,2^shearLevel-1,1);
            #convolve wedge filter with lowpass filter, again following equation
            #(21) on page 14.
            lowpassHelp = padarray(filterLow2[size(filterLow2,2)-max(shearLevel-1,0)],size(wedgeUpsampled),1);
            if shearLevel >= 1
                wedgeUpsampled = fftshift(ifft(ifftshift(fftshift(fft(ifftshift(lowpassHelp))).*fftshift(fft(ifftshift(wedgeUpsampled))))));
            end
            lowpassHelpFlip = fliplr(lowpassHelp,1);
            #traverse all directions of the upper part of the left horizontal
            #frequency cone
            for k = -2^shearLevel:2^shearLevel
                #resample wedgeUpsampled as given in equation (22) on page 15.
                wedgeUpsampledSheared = dshear(wedgeUpsampled,k,2,1);
                #convolve again with flipped lowpass filter, as required by equation (22) on
                #page 15.
                if shearLevel >= 1
                   wedgeUpsampledSheared = fftshift(ifft(ifftshift(fftshift(fft(ifftshift(lowpassHelpFlip))).*fftshift(fft(ifftshift(wedgeUpsampledSheared))))));
                end
                #obtain downsampled and renormalized and sheared wedge filter in the
                #frequency domain, according to equation (22) on page 15
                wedge[shearLevel+1][:,:,fix(2^shearLevel)+1-k] = fftshift(fft(ifftshift(2^shearLevel*wedgeUpsampledSheared[:,1:2^shearLevel:(2^shearLevel*cols-1)])));
            end
        end
    else
        for shearLevel = unique(shearLevels)
            #preallocate a total of floor(2^(shearLevel+1)+1) wedge filters, where
            #floor(2^(shearLevel+1)+1) is the number of different directions of
            #shearlet atoms associated with the horizontal (resp. vertical)
            #frequency cones.
            wedge[shearLevel+1] = zeros(rows,cols,floor(2^(shearLevel+1)+1))+zeros(rows,cols,floor(2^(shearLevel+1)+1))*im;

            #upsample directional filter in y-direction. by upsampling the directional
            #filter in the time domain, we construct repeating wedges in the
            #frequency domain ( compare abs.(fftshift(fft2(ifftshift(directionalFilterUpsampled)))) and
            #abs.(fftshift(fft2(ifftshift(directionalFilter)))) ).
            directionalFilterUpsampled = upsample(directionalFilter,1,2^(shearLevel+1)-1);

            #remove high frequencies along the y-direction in the frequency domain.
            #by convolving the upsampled directional filter with a lowpass filter in y-direction, we remove all
            #but the central wedge in the frequency domain.

            wedgeHelp = conv2(directionalFilterUpsampled, filterLow2[size(filterLow2,2)-shearLevel][:,:])
            wedgeHelp = padarray(wedgeHelp,[rows,cols]);
            #please note that wedgeHelp now corresponds to
            #conv(p_j,h_(J-j*alpha_j/2)') in the language of the paper. to see
            #this, consider the definition of p_j on page 14, the definition of w_j
            #on the same page an the definition of the digital sheralet filter on
            #page 15. furthermore, the g_j part of the 2D wavelet filter w_j is
            #invariant to shearings, hence it suffices to apply the digital shear
            #operator to wedgeHelp.;

            ## application of the digital shear operator (compare equation (22))

            #upsample wedge filter in x-direction. this operation corresponds to
            #the upsampling in equation (21) on page 15.
            wedgeUpsampled = upsample(wedgeHelp,2,2^shearLevel-1);

            #convolve wedge filter with lowpass filter, again following equation
            #(21) on page 14.
            lowpassHelp = padarray(filterLow2[size(filterLow2,2)-max(shearLevel-1,0)],size(wedgeUpsampled));
            if shearLevel >= 1
                wedgeUpsampled = fftshift(ifft(ifftshift(fftshift(fft(ifftshift(lowpassHelp))).*fftshift(fft(ifftshift(wedgeUpsampled))))));
            end
            lowpassHelpFlip = fliplr(lowpassHelp);
            #traverse all directions of the upper part of the left horizontal
            #frequency cone
            for k = -2^shearLevel:2^shearLevel
                #resample wedgeUpsampled as given in equation (22) on page 15.
                wedgeUpsampledSheared = dshear(wedgeUpsampled,k,2);
                #convolve again with flipped lowpass filter, as required by equation (22) on
                #page 15.
                if shearLevel >= 1
                   wedgeUpsampledSheared = fftshift(ifft(ifftshift(fftshift(fft(ifftshift(lowpassHelpFlip))).*fftshift(fft(ifftshift(wedgeUpsampledSheared))))));
                end
                #obtain downsampled and renormalized and sheared wedge filter in the
                #frequency domain, according to equation (22) on page 15
                wedge[shearLevel+1][:,:,fix(2^shearLevel)+1-k] = fftshift(fft(ifftshift(2^shearLevel*wedgeUpsampledSheared[:,1:2^shearLevel:(2^shearLevel*cols-1)])));
            end
        end
    end

    ## compute low pass filter of shearlet system
    if gpu == 1
        lowpass = fftshift(fft(ifftshift(padarray(transpose(filterLow[1]')*filterLow[1]',[rows,cols],1))));
    else
        lowpass = fftshift(fft(ifftshift(padarray(transpose(filterLow[1]')*filterLow[1]',[rows,cols]))));
    end

    # Generate the final array
    return Filterswedgebandlow(wedge,bandpass,lowpass)
end #getwedgebandpasslowpassfilters2D

##############################################################
# Create a type for the Preparedfilters
immutable Preparedfilters
    size
    shearLevels
    cone1
    cone2
end

#######################################################################
# Function that prepare the filters
"""
...
SlprepareFilters2D(rows, cols, nScales, shearLevels = ceil.((1:nScales)/2),
    directionalFilter = filt_gen("directional_shearlet"),
    scalingFilter = filt_gen("scaling_shearlet"),
    waveletFilter = mirror(scalingFilter),
    scalingFilter2 = scalingFilter, gpu = 0) function that prepare the filters to generate
		 the shearlet system
...
"""
function preparefilters2D(rows, cols, nScales, shearLevels = ceil.((1:nScales)/2),
    directionalFilter = filt_gen("directional_shearlet"),
    scalingFilter = filt_gen("scaling_shearlet"),
    waveletFilter = mirror(scalingFilter),
    scalingFilter2 = scalingFilter, gpu = 0)

    #Make sure the shearLevles are integer
    shearLevels = map(Int,shearLevels)
    # check filter sizes
    filters = checkfiltersizes(rows,cols,shearLevels,directionalFilter,scalingFilter,waveletFilter,scalingFilter2);

    # Save the new filters
    directionalFilter = filters.directionalFilter;
    scalingFilter = filters.scalingFilter;
    waveletFilter = filters.waveletFilter;
    scalingFilter2 = filters.scalingFilter2;

    # Define the cones
    cone1 = getwedgebandpasslowpassfilters2D(rows,cols,shearLevels,directionalFilter,scalingFilter,waveletFilter,scalingFilter2,gpu);
    if rows == cols
    	cone2 = cone1;
    else
    	cone2 = getwedgebandpasslowpassfilters2D(cols,rows,shearLevels,directionalFilter,scalingFilter,waveletFilter,scalingFilter2,gpu);
    end
    return Preparedfilters([rows,cols],shearLevels,cone1,cone2)
end # preparefilters2D

#######################################################################
# Function compute a index set describing a 2D shearlet system
"""
...
getshearletidxs2D(shearLevels, full=0, restriction_type = [],restriction_value = []) Compute a index set describing a 2D shearletsystem, with restriction_type in
["cones","scales","shearings"], where shearLevels is a 1D array spcifying the level of shearing on each scale, and full is a boolean that orders to generate the full shearlet indices.
...
"""
function getshearletidxs2D(shearLevels, full=0, restriction_type = [],restriction_value = [])
		shearLevels = map(Int,shearLevels)
    # Set default values
    shearletIdxs = [];
    includeLowpass = 1;
    scales = 1:length(shearLevels);
    shearings = -2^(maximum(shearLevels)):2^(maximum(shearLevels));
    cones = 1:2;

    for i = 1:length(restriction_type)
        includeLowpass = 0;
        if restriction_type[i] == "scales"
            scales = restriction_value[i];
        elseif restriction_type[i] == "shearings"
            shearings = restriction_value[i];
        elseif restriction_type[i] == "cones"
            cones = restriction_value[i];
        end
    end

    for cone = intersect(1:2,cones)
        for scale = intersect(1:length(shearLevels),scales)
            for shearing = intersect(-2^shearLevels[scale]:2^shearLevels[scale],shearings)
                if convert(Bool,full) || cone == 1 || abs.(shearing)<2^(shearLevels[scale])
                    shearletIdxs=[shearletIdxs;[cone,scale,shearing]];
                end
            end
        end
    end

    shearletIdxs = transpose(reshape(shearletIdxs,3,Int(length(shearletIdxs)/3)))
    if convert(Bool,includeLowpass) || convert(Bool,sum(0.==scales)) || convert(Bool,sum(0.==cones))
        shearletIdxs = [shearletIdxs;[0 0 0]];
    end
    return shearletIdxs
end # getshearletidxs2D

####################################################################
# Type of shearletsystem in 2D
immutable Shearletsystem2D
    shearlets
    size
    shearLevels
    full
    nShearlets
    shearletIdxs
    dualFrameWeights
    RMS
    isComplex
		gpu
end

#######################################################################
# Function that generates the desired shearlet system
"""
...
 getshearletsystem2D(rows,cols,nScales,shearLevels=ceil.((1:nScales)/2),full = 0,directionalFilter = filt_gen("directional_shearlet"),quadratureMirrorFilter= filt_gen("scaling_shearlet"), gpu = 0) generates the desired shearlet system
...
"""
function getshearletsystem2D(rows,cols,nScales,
                                shearLevels=ceil.((1:nScales)/2),
                                full= 0,
                                directionalFilter = filt_gen("directional_shearlet"),
                                quadratureMirrorFilter= filt_gen("scaling_shearlet"),gpu=0)

    # Set default value generates the desired shearlet systems
    shearLevels = map(Int,shearLevels)

    #Generate prepared Filters and indices
    Preparedfilters = preparefilters2D(rows,cols,nScales,shearLevels,directionalFilter,quadratureMirrorFilter,mirror(quadratureMirrorFilter),quadratureMirrorFilter, gpu);
    shearletIdxs = getshearletidxs2D(shearLevels,full);

    # Generate shearlets, RMS(rootmeansquare), dualFrameWeights
    rows = Preparedfilters.size[1];
    cols = Preparedfilters.size[2];
    nShearlets = size(shearletIdxs,1);
    if gpu == 1
        shearlets = AFArray(zeros(Complex{Float32},rows,cols,nShearlets));
    else
        shearlets = zeros(rows,cols,nShearlets)+im*zeros(rows,cols,nShearlets);
    end
    # Compute shearlets
    for j = 1:nShearlets
        cone = shearletIdxs[j,1];
        scale = shearletIdxs[j,2];
        shearing = shearletIdxs[j,3];

        if cone == 0
            shearlets[:,:,j] = Preparedfilters.cone1.lowpass;
        elseif cone == 1
            #here, the fft of the digital shearlet filters described in
            #equation (23) on page 15 of "ShearLab 3D: Faithful Digital
            #Shearlet Transforms based on Compactly Supported Shearlets" is computed.
            #for more details on the construction of the wedge and bandpass
            #filters, please refer to getwedgebandpasslowpassfilters2D.
            shearlets[:,:,j] = Preparedfilters.cone1.wedge[Preparedfilters.shearLevels[scale]+1][:,:,-shearing+2^Preparedfilters.shearLevels[scale]+1].*conj(Preparedfilters.cone1.bandpass[:,:,scale]);
        else
            shearlets[:,:,j] = permutedims(Preparedfilters.cone2.wedge[Preparedfilters.shearLevels[scale]+1][:,:,shearing+2^Preparedfilters.shearLevels[scale]+1].*conj(Preparedfilters.cone2.bandpass[:,:,scale]),[2,1]);
        end
    end
	RMS =  transpose(sum(reshape(sum(real(abs.(shearlets)).^2,1),size(shearlets,2),size(shearlets,3)),1));
    if gpu == 1
        RMS = (sqrt.(RMS)/convert(Float32,sqrt.(rows*cols)));
        dualFrameWeights = sum(real(abs.(shearlets)).^2,3);
    else
        RMS = (sqrt.(RMS)/sqrt.(rows*cols));
        dualFrameWeights = squeeze(sum(abs.(shearlets).^2,3),3); # need to stream to host before they fix abs of comples AFArray
    end
    #return the system
    return Shearletsystem2D(shearlets,Preparedfilters.size,
    Preparedfilters.shearLevels,full,size(shearletIdxs,1),
    shearletIdxs,dualFrameWeights,RMS,0,gpu)
end #getshearletsystem2D



# type for individual shearlets2D
immutable Shearlets2D
		shearlets
		RMS
		dualFrameWeights
		gpu
end

#######################################################################
# Function that generates the desired shearlets
"""
...
 getshearlets2D(PreparedFilters,shearletIdxs,gpu = 0) generates the 2D shearlets in the frequency domain
...
"""
function getshearlets2D(Preparedfilters, shearletIdxs = getshearletidxs2D(Preparedfilters.shearLevels),gpu = 0)
    # Generate shearlets, RMS(rootmeansquare), dualFrameWeights
    rows = Preparedfilters.size[1];
    cols = Preparedfilters.size[2];
    nShearlets = size(shearletIdxs,1);
		if gpu == 1
    	shearlets = AFArray(zeros(Complex{Float32},rows,cols,nShearlets));
		else
    	shearlets = zeros(rows,cols,nShearlets)+im*zeros(rows,cols,nShearlets);
		end
    # Compute shearlets
    for j = 1:nShearlets
        cone = shearletIdxs[j,1];
        scale = shearletIdxs[j,2];
        shearing = shearletIdxs[j,3];

        if cone == 0
            shearlets[:,:,j] = Preparedfilters.cone1.lowpass;
        elseif cone == 1
            #here, the fft of the digital shearlet filters described in
            #equation (23) on page 15 of "ShearLab 3D: Faithful Digital
            #Shearlet Transforms based on Compactly Supported Shearlets" is computed.
            #for more details on the construction of the wedge and bandpass
            #filters, please refer to getwedgebandpasslowpassfilters2D.
            shearlets[:,:,j] = Preparedfilters.cone1.wedge[Preparedfilters.shearLevels[scale]+1][:,:,-shearing+2^Preparedfilters.shearLevels[scale]+1].*conj(Preparedfilters.cone1.bandpass[:,:,scale]);
        else
            shearlets[:,:,j] = permutedims(Preparedfilters.cone2.wedge[Preparedfilters.shearLevels[scale]+1][:,:,shearing+2^Preparedfilters.shearLevels[scale]+1].*conj(Preparedfilters.cone2.bandpass[:,:,scale]),[2,1]);
        end
    end
		RMS =  transpose(sum(reshape(sum(real(abs.(shearlets)).^2,1),size(shearlets,2),size(shearlets,3)),1));
    if gpu == 1
        RMS = (sqrt.(RMS)/convert(Float32,sqrt.(rows*cols)));
        dualFrameWeights = sum(real(abs.(shearlets)).^2,3);
    else
        RMS = (sqrt.(RMS)/sqrt.(rows*cols));
        dualFrameWeights = squeeze(sum(abs.(shearlets).^2,3),3); # need to stream to host before they fix abs of comples AFArray
    end
		return Shearlets2D(shearlets, RMS, dualFrameWeights,gpu)
end #getshearlets2D
