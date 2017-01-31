# Submodule that constructs the system of Shearlets in 2D of size rows x cols


######################################################################
## Type of filterConfiguration to check the sizes 
type filterWedgeBandLow
    wedge::Array
    bandpass::Array
    lowpass::Array
end

#######################################################################
# Function that generates the whole Shearlet System filters (wedge, bandpass and lowpass) of size rows x cols
"""
...
SLgetWedgeBandpassAndLowpassFilters2D(rows,cols,directionalFilter = FWT.filt_gen("directional_shearlet"), scalingFilter = FWT.filt_gen("scaling_shearlet")) 
generates the Wedge, Bandpass and LowspassFilter of size rows x cols
...
"""
function SLgetWedgeBandpassAndLowpassFilters2D(rows,cols,shearLevels,directionalFilter = FWT.filt_gen("directional_shearlet"),scalingFilter = FWT.filt_gen("scaling_shearlet"),waveletFilter = FWT.mirror(scalingFilter),scalingFilter2 = scalingFilter)     
		# Make shearLevels integer
		shearLevels = map(Int,shearLevels);
		# The number of scales
    NScales = length(shearLevels);
 
    # Initialize the bandpass and wedge filter

    # Bandpass filters partion the frequency plane into different scales
    bandpass = zeros(rows,cols,NScales); 

    # Wedge filters partition the frequency plane into different directions
    wedge = Array{Any}(1,round(Int64,maximum(shearLevels)+1));

    # normalize the directional filter directional filter
    directionalFilter = directionalFilter/sum(abs(directionalFilter[:]));

    # Compute 1D high and lowpass filters at different scales

    # filterHigh{NScales} = g, and filterHigh{1} = g_J (analogous with filterLow)
    filterHigh = Array{Any}(1,NScales);
    filterLow = Array{Any}(1,NScales);
    filterLow2 = Array{Any}(1,round(Int64,maximum(shearLevels)+1));

    # Initialize wavelet highpass and lowpass filters
    filterHigh[size(filterHigh,2)] = waveletFilter;
    filterLow[size(filterLow,2)] = scalingFilter;
    filterLow2[size(filterLow2,2)] = scalingFilter2;

    # Lets compute the filters in the other scales
    for j = (size(filterHigh)[2]-1):-1:1
        filterLow[j] = conv(filterLow[size(filterLow,2)],SLupsample(filterLow[j+1],1,1))
        filterHigh[j] = conv(filterLow[size(filterLow,2)],SLupsample(filterHigh[j+1],1,1))
    end

    # Lets compute the filters in the other scales
    for j=(size(filterLow2)[2]-1):-1:1
        filterLow2[j] = conv(filterLow2[size(filterLow2,2)],SLupsample(filterLow2[j+1],1,1))
    end

    # Construct the bandpassfilter
    # Need to convert first to complex array since 
    bandpass = bandpass+im*zeros(bandpass)
    for j = 1:size(filterHigh,2)
        bandpass[:,:,j] = -fftshift(fft(ifftshift(padArray(filterHigh[j],[rows,cols]))));
    end

    ## construct wedge filters for achieving directional selectivity.
    # as the entries in the shearLevels array describe the number of differently 
    # sheared atoms on a certain scale, a different set of wedge 
    # filters has to be constructed for each value in shearLevels.

    for shearLevel = unique(shearLevels)
        #preallocate a total of floor(2^(shearLevel+1)+1) wedge filters, where
        #floor(2^(shearLevel+1)+1) is the number of different directions of
        #shearlet atoms associated with the horizontal (resp. vertical)
        #frequency cones.    
        wedge[shearLevel+1] = zeros(rows,cols,floor(2^(shearLevel+1)+1))+zeros(rows,cols,floor(2^(shearLevel+1)+1))*im; 

        #upsample directional filter in y-direction. by upsampling the directional
        #filter in the time domain, we construct repeating wedges in the
        #frequency domain ( compare abs(fftshift(fft2(ifftshift(directionalFilterUpsampled)))) and 
        #abs(fftshift(fft2(ifftshift(directionalFilter)))) ). 
        directionalFilterUpsampled = SLupsample(directionalFilter,1,2^(shearLevel+1)-1);

        #remove high frequencies along the y-direction in the frequency domain.
        #by convolving the upsampled directional filter with a lowpass filter in y-direction, we remove all
        #but the central wedge in the frequency domain. 
        wedgeHelp = conv2(directionalFilterUpsampled'',
                        filterLow2[size(filterLow2,2)-shearLevel]'');
        wedgeHelp = padArray(wedgeHelp,[rows,cols]);
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
        wedgeUpsampled = SLupsample(wedgeHelp,2,2^shearLevel-1);

        #convolve wedge filter with lowpass filter, again following equation
        #(21) on page 14.
        lowpassHelp = padArray(filterLow2[size(filterLow2,2)-max(shearLevel-1,0)],size(wedgeUpsampled));
        if shearLevel >= 1
            wedgeUpsampled = fftshift(ifft(ifftshift(fftshift(fft(ifftshift(lowpassHelp))).*fftshift(fft(ifftshift(wedgeUpsampled))))));
        end
        lowpassHelpFlip = fliplr(lowpassHelp);
        #traverse all directions of the upper part of the left horizontal
        #frequency cone
        for k = -2^shearLevel:2^shearLevel
            #resample wedgeUpsampled as given in equation (22) on page 15.
            wedgeUpsampledSheared = SLdshear(wedgeUpsampled,k,2);
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
    ## compute low pass filter of shearlet system
    lowpass = fftshift(fft(ifftshift(padArray(transpose(filterLow[1]')*filterLow[1]',[rows,cols]))));

    # Generate the final array
    Filters = filterWedgeBandLow(wedge,bandpass,lowpass)
end #SLgetWedgeBandpassAndLowpassFilters2D


##############################################################
# Create a type for the preparedFilters
type preparedfilters
    size
    shearLevels
    cone1
    cone2
end

#######################################################################
# Function that prepare the filters 
"""
...
SlprepareFilters2D(rows, cols, nScales, shearLevels = ceil((1:nScales)/2), 
    directionalFilter = FWT.filt_gen("directional_shearlet"),
    scalingFilter = FWT.filt_gen("scaling_shearlet"),
    waveletFilter = FWT.mirror(scalingFilter),
    scalingFilter2 = scalingFilter) function that prepare the filters to generate
		 the shearlet system
...
"""
function SLprepareFilters2D(rows, cols, nScales, shearLevels = ceil((1:nScales)/2), 
    directionalFilter = FWT.filt_gen("directional_shearlet"),
    scalingFilter = FWT.filt_gen("scaling_shearlet"),
    waveletFilter = FWT.mirror(scalingFilter),
    scalingFilter2 = scalingFilter)
    
    #Make sure the shearLevles are integer
    shearLevels = map(Int,shearLevels)
    # check filter sizes 
    filters = SLcheckFilterSizes(rows,cols,shearLevels,directionalFilter,scalingFilter,waveletFilter,scalingFilter2);    
    
    # Save the new filters
    directionalFilter = filters.directionalFilter;
    scalingFilter = filters.scalingFilter;
    waveletFilter = filters.waveletFilter;
    scalingFilter2 = filters.scalingFilter2;
    
    # Define the cones
    cone1 = SLgetWedgeBandpassAndLowpassFilters2D(rows,cols,shearLevels,directionalFilter,scalingFilter,waveletFilter,scalingFilter2);     
    if rows == cols
    cone2 = cone1;
    else
        cone2 = SLgetWedgeBandpassAndLowpassFilters2D(cols,rows,shearLevels,directionalFilter,scalingFilter,waveletFilter,scalingFilter2);  
    end
    preparedfilters([rows,cols],shearLevels,cone1,cone2)
end # SLprepareFilters2D

#######################################################################
# Function compute a index set describing a 2D shearlet system
"""
...
SLgetShearletIdxs2D(shearLevels, full=0, restriction_type = [],restriction_value = []) Compute a index set describing a 2D shearletsystem, with restriction_type in 
["cones","scales","shearings"], where shearLevels is a 1D array spcifying the level of shearing on each scale, and full is a boolean that orders to generate the full shearlet indices.
...
"""
function SLgetShearletIdxs2D(shearLevels, full=0, restriction_type = [],restriction_value = [])
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
                if convert(Bool,full) || cone == 1 || abs(shearing)<2^(shearLevels[scale])
                    shearletIdxs=[shearletIdxs;[cone,scale,shearing]];
                end
            end
        end
    end

    shearletIdxs = transpose(reshape(shearletIdxs,3,Int(length(shearletIdxs)/3)))
    if convert(Bool,includeLowpass) || convert(Bool,sum(0.==scales)) || convert(Bool,sum(0.==cones))
        shearletIdxs = [shearletIdxs;[0 0 0]];
    end
    shearletIdxs
end # SLgetShearletIdxs2D

####################################################################
# Type of shearletsystem in 2D
type shearletsystem2D
    shearlets
    size
    shearLevels
    full
    nShearlets
    shearletIdxs
    dualFrameWeights
    RMS
    isComplex
end

#######################################################################
# Function that generates the desired shearlet system 
"""
...
 SLgetShearletSystem2D(rows,cols,nScales,shearLevels=ceil((1:nScales)/2),full= 0,directionalFilter = FWT.filt_gen("directional_shearlet"),quadratureMirrorFilter= FWT.filt_gen("scaling_shearlet")) generates the desired shearlet system
...
"""
function SLgetShearletSystem2D(rows,cols,nScales,
                                shearLevels=ceil((1:nScales)/2),
                                full= 0,
                                directionalFilter = FWT.filt_gen("directional_shearlet"),
                                quadratureMirrorFilter= FWT.filt_gen("scaling_shearlet"))

    # Set default value generates the desired shearlet systems
    shearLevels = map(Int,shearLevels)

    #Generate prepared Filters and indices
    preparedFilters = SLprepareFilters2D(rows,cols,nScales,shearLevels,directionalFilter,quadratureMirrorFilter);
    shearletIdxs = SLgetShearletIdxs2D(shearLevels,full);

    # Generate shearlets, RMS(rootmeansquare), dualFrameWeights
    rows = preparedFilters.size[1];
    cols = preparedFilters.size[2];
    nShearlets = size(shearletIdxs,1);
    shearlets = zeros(rows,cols,nShearlets)+im*zeros(rows,cols,nShearlets);
    # Compute shearlets
    for j = 1:nShearlets
        cone = shearletIdxs[j,1];
        scale = shearletIdxs[j,2];
        shearing = shearletIdxs[j,3];

        if cone == 0
            shearlets[:,:,j] = preparedFilters.cone1.lowpass;
        elseif cone == 1
            #here, the fft of the digital shearlet filters described in
            #equation (23) on page 15 of "ShearLab 3D: Faithful Digital
            #Shearlet Transforms based on Compactly Supported Shearlets" is computed.
            #for more details on the construction of the wedge and bandpass
            #filters, please refer to SLgetWedgeBandpassAndLowpassFilters2D.
            shearlets[:,:,j] = preparedFilters.cone1.wedge[preparedFilters.shearLevels[scale]+1][:,:,-shearing+2^preparedFilters.shearLevels[scale]+1].*conj(preparedFilters.cone1.bandpass[:,:,scale]);
        else
            shearlets[:,:,j] = permutedims(preparedFilters.cone2.wedge[preparedFilters.shearLevels[scale]+1][:,:,shearing+2^preparedFilters.shearLevels[scale]+1].*conj(preparedFilters.cone2.bandpass[:,:,scale]),[2,1]);
        end
    end
    RMS = abs(shearlets).^2;
    RMS = sum([RMS[i,:,:] for i in 1:size(RMS,1)]);
    RMS = sum([RMS[i,:] for i in 1:size(RMS,1)]);
    RMS = (sqrt(RMS)/sqrt(rows*cols));
    dualFrameWeights = squeeze(sum(abs(shearlets).^2,3),3);   

    #return the system
    shearletsystem2D(shearlets,preparedFilters.size,
    preparedFilters.shearLevels,full,size(shearletIdxs,1),
    shearletIdxs,dualFrameWeights,RMS,0)
end #SLgetShearletSystem2D 

