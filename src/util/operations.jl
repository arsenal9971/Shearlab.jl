# Submodule with some operations that will help to pad multidimensional arrays and Upsample in the Shearlab3D.m fashion

###################################################
# Padding array function to resize an array padding
# zeros
"""
...
padarray(array, newSize,gpu)
pads array with zeros to have a new size if the input array
is bigger than the targeted size, it will centered it at zero
and cut it off to fit
...
"""
function padarray{T<:Number}(array::AbstractArray{T},newSize,gpu = 0)
    # If you want to use gpu via ArrayFire array needs to be ArrayFire.AFArray{Float32,2}
    # Small patch if the array is one dimensional
    if size([size(array)...])[1]==1
        array = transpose(array)
    end
    padSizes = zeros(Integer,1,length(newSize))
    n = length(newSize)
    sizes = size(array)
    @fastmath @inbounds @simd for k = 1:n
        sizeDiff = newSize[k]-sizes[k];
        if mod(sizeDiff,2) == 0
            padSizes[k] = Int(sizeDiff/2);
        else
            padSizes[k] = Int(ceil.(sizeDiff/2))
        end
    end
    # Correct the matrix that is bigger than the targeted size
    idbig = [1:sizes[i] for i in 1:n]
    @fastmath @inbounds @simd for i in 1:length(newSize)
        if padSizes[i] < 0
            idbig[i] = (round(Int64,(size(array,i)-newSize[i])/2)+1):(round(Int64,(size(array,i)+newSize[i])/2))
            padSizes[i] = 0
        end
    end
    # We need to check if some of the padsizes are negative and cut the array from the center
    # Initialize the padded array with zeros
    if gpu == 1
        paddedArray = AFArray(zeros(typeof(array[1]), newSize...))
    else
        paddedArray = zeros(typeof(array[1]),newSize...)
    end
    # lets create the indices array
    if gpu == 1
        paddedArray[[idbig[1]+padSizes[1],idbig[2]+padSizes[2]]...] = array[idbig...]
    else
        view(paddedArray,[idbig[1]+padSizes[1],idbig[2]+padSizes[2]]...) .= view(array,idbig...)
    end
    return paddedArray
end #padarray

################################################################
# Function that flips from left to right an array in the second dimension
"""
...
fliplr(array,gpu) flips an array from left to right in the second dimension
...
"""
function fliplr{T<:Number}(array::AbstractArray{T},gpu = 0)
    return flipdim(array,2)
end #fliplr

##################################################################
# function that upsample an multidimensional array based on the same
# function at the matlab version
"""
..
upsample(array,dims,nZeros,gpu) upsample an array, in the dimensions dims
with nZeros
...
"""
function upsample{T<:Number}(array::AbstractArray{T},dims::Integer,nZeros::Integer, gpu = 0)
    sz = [size(array)...]
    szUpsampled = sz
    szUpsampled[dims] = (szUpsampled[dims]-1).*(nZeros+1)+1
    if gpu == 1
        arrayUpsampled = AFArray(zeros(typeof(array[1]),szUpsampled...))
    else
        arrayUpsampled = zeros(typeof(array[1]),szUpsampled...);
    end
    # Generate the indices per dimension
    ids = [1:1:size(array,i) for i in 1:length(size(array))]
    @fastmath @inbounds @simd  for k in 1:length(dims)
        ids[dims[k]] = 1:(nZeros[k]+1):szUpsampled[dims[k]]
    end
    arrayUpsampled[ids...] = array
    return arrayUpsampled
end #upsample

#####################################################################
# Function that rounds a number to the nearest integer towards zero
"""
...
fix(x) rounds a number x to the nearest integer towards zero
...
"""
function fix{T<:Number}(x::T)
    if x < 0
        fixed = ceil(x)
    else
        fixed = floor(x)
    end
    return convert(Int64,fixed)
end #fix

#######################################################################
# Function that shears an array in order k in the direction of axis
# based on the same function on the Matlab version
"""
...
dshear(array,k,axis,gpu) shears and array in order k in the direction of
axis
...
"""
function dshear{T<:Number}(array::AbstractArray{T},k::Integer,axis::Integer, gpu = 0)
    if gpu == 1
        array = Array(array)
    end
    if k == 0
        sheared = array;
    else
        rows = size(array,1);
        cols = size(array,2);
        sheared = zeros(typeof(array[1]),size(array)...)
        if axis == 1
            for col = 1:cols
                sheared[:,col] = reshape(circshift(reshape(array[:,col],rows,1),[-k*(floor(cols/2)+1-col) 0]),(rows,));
            end
        else
            for row = 1:rows
                sheared[row,:] = reshape(circshift(reshape(array[row,:],1,cols),[0 -k*(floor(rows/2)+1-row)]),(cols,));
            end
        end
    end
    if gpu == 1
        sheared = AFArray(sheared)
    end
    return sheared
end #dshear

######################################################################
## Type of filter configurations
immutable Filterconfigs
    directionalFilter
    scalingFilter
    waveletFilter
    scalingFilter2
end #Filterconfigs

#######################################################################
# Function that check the sizes of the filters to know if it is possible
"""
...
checkfiltersizes(rows,cols,shearLevels,directionalFilter,scalingFilter,waveletFilter,scalingFilter2) function that check
wBand
the size of the filters and set new possible configurations
...
"""
function checkfiltersizes(rows,cols,shearLevels,directionalFilter,scalingFilter,waveletFilter,scalingFilter2)
    # Lets initialize the FilterConfig array,
    filterSetup = []
    # Set all configurations

    # Configuration 1
    push!(filterSetup,Filterconfigs(directionalFilter,scalingFilter,
                                    waveletFilter,scalingFilter2));

    # Configuration 2
    # Check the default configuration
    scalingFilter = filt_gen("scaling_shearlet");
    directionalFilter = filt_gen("directional_shearlet");
    waveletFilter = mirror(scalingFilter);
    scalingFilter2 =  scalingFilter;
    push!(filterSetup,Filterconfigs(directionalFilter,scalingFilter,
                                    waveletFilter,scalingFilter2));

    # Configuration 3
    # Just change the directionalFilter
    directionalFilter = filt_gen("directional_shearlet2");
    push!(filterSetup,Filterconfigs(directionalFilter,scalingFilter,
                                    waveletFilter,scalingFilter2));

    # Configuration 4
    # The same as 3
    push!(filterSetup,Filterconfigs(directionalFilter,scalingFilter,
                                    waveletFilter,scalingFilter2));

    # Configuration 5
    # It changes the scalingFilter, the waveletFilter and the scalingFilter2
    scalingFilter = filt_gen("Coiflet1");
    waveletFilter = mirror(scalingFilter);
    scalingFilter2 =  scalingFilter;
    push!(filterSetup,Filterconfigs(directionalFilter,scalingFilter,
                                    waveletFilter,scalingFilter2));

    # Configuration 6
    # It changes the scalingFilter, the waveletFilter and the scalingFilter2
    scalingFilter = filt_gen(WT.db2)[2:5];
    waveletFilter = mirror(scalingFilter);
    scalingFilter2 =  scalingFilter;
    push!(filterSetup,Filterconfigs(directionalFilter,scalingFilter,
                                    waveletFilter,scalingFilter2));

    # Configuration 7
    # Just change the directionalFilter
    directionalFilter = filt_gen("directional_shearlet3");
    push!(filterSetup,Filterconfigs(directionalFilter,scalingFilter,
                                    waveletFilter,scalingFilter2));

    # Configuration 8
    # It changes the scalingFilter, the waveletFilter and the scalingFilter2
    scalingFilter = filt_gen(WT.haar)[2:3]
    waveletFilter = mirror(scalingFilter);
    scalingFilter2 =  scalingFilter;
    push!(filterSetup,Filterconfigs(directionalFilter,scalingFilter,
                                    waveletFilter,scalingFilter2));

    # Check the sizes of the filters in comparison with the rows and cols
		kk = 0;
    success1 = 0;
    for k = 1:8
        ## check 1
        lwfilter = length(filterSetup[k].waveletFilter);
        lsfilter = length(filterSetup[k].scalingFilter);
        lcheck1 = lwfilter;
        for j = 1:(length(shearLevels)-1)
            lcheck1 = lsfilter + 2*lcheck1 - 2;
        end
        if lcheck1 > cols || lcheck1 > rows
            continue;
        end

        ## check  2
        rowsdirfilter = size(filterSetup[k].directionalFilter,1);
        colsdirfilter = size(filterSetup[k].directionalFilter,2);
        lcheck2 = (rowsdirfilter-1)*2^(maximum(shearLevels)+1) + 1;

        lsfilter2 = length(filterSetup[k].scalingFilter2);
        lcheck2help = lsfilter2;
        for j = 1:maximum(shearLevels)
            lcheck2help = lsfilter2 + 2*lcheck2help - 2;
        end
        lcheck2 = lcheck2help + lcheck2 - 1;
        if lcheck2 > cols || lcheck2 > rows || colsdirfilter > cols || colsdirfilter > rows
            continue;
        end
        success1 = 1;
				kk = k;
        break;
    end
    if success1 == 0
        error("The specified Shearlet system was not available for data of size "* string(rows) *"x",string(cols)* ". Filters were automatically set to configuration "*string(kk)* "(see operations.jl).");
    end
    if success1 == 1 && kk > 1
        warn("The specified Shearlet system was not available for data of size "*string(rows)*"x"*string(cols)*". Filters were automatically set to configuration "*string(kk)*"(see operations.jl).");
    end
    filterSetup[kk]
end #checkfiltersizes
