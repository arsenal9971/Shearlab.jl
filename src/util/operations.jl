# Submodule with some operations that will help to pad multidimensional arrays and Upsample in the Shearlab3D.m fashion

###################################################
# Padding array function to resize an array padding
# zeros 
"""
...
padarray(array, newSize)
pads array with zeros to have a new size if the input array
is bigger than the targeted size, it will centered it at zero
and cut it off to fit
...
"""
function padarray(array,newSize)
		# Small patch if the array is one dimensional
		if size([size(array)...])[1]==1
			array = transpose(array)
		end
    padSizes = zeros(1,length(newSize))
    for k = 1:length(newSize)
        currSize = size(array,k);
        sizeDiff = newSize[k]-currSize;       
        if mod(sizeDiff,2) == 0
            padSizes[k] = sizeDiff/2;
        else
            padSizes[k] = ceil(sizeDiff/2)
        end
    end
    padSizes = round(Int64,padSizes)
    # Correct the matrix that is bigger than the targeted size
    idbig = [1:size(array,i) for i in 1:length(newSize)]
    for i in 1:length(newSize)
        if padSizes[i] < 0
            idbig[i] = (round(Int64,(size(array,i)-newSize[i])/2)+1):(round(Int64,(size(array,i)+newSize[i])/2))
            padSizes[i] = 0
        end
    end
    array = array[idbig...] 
    padSizes = round(Int64,padSizes)
    # We need to check if some of the padsizes are negative and cut the array from the center
    # Initialize the padded array with zeros
    paddedArray = zeros(newSize...)
    # lets create the indices array
    id = [(padSizes[i]+1):(padSizes[i]+size(array,i)) for i in 1:length(newSize)]
    paddedArray[id...] = array
    paddedArray
end #padarray



################################################################
# Function that flips from left to right an array in the second dimension
"""
...
fliplr(array) flips an array from left to right in the second dimension
...
"""
function fliplr(array)
    # Initialize the flipped array 
    array_flipped = zeros(array)
    # Insert the values
    for i in 1:size(array,2)
        array_flipped[:,i]=array[:,size(array,2)-i+1]
    end
    array_flipped
end #fliplr

##################################################################
# function that upsample an multidimensional array based on the same
# function at the matlab version
"""
...
upsample(array,dims,nZeros) upsample an array, in the dimensions dims
with nZeros
...
"""
function upsample(array,dims,nZeros)
    sz = [size(array)...];
    szUpsampled = sz;
    szUpsampled[dims] = (szUpsampled[dims]-1).*(nZeros+1)+1;
    arrayUpsampled = zeros(szUpsampled...);
    # Generate the indices per dimension
    ids = [1:1:size(array,i) for i in 1:length(size(array))]
    for k in 1:length(dims)
        ids[dims[k]] = 1:(nZeros[k]+1):szUpsampled[dims[k]]
    end
    arrayUpsampled[ids...] = array
    arrayUpsampled
end #upsample

#####################################################################
# Function that rounds a number to the nearest integer towards zero
"""
...
fix(x) rounds a number x to the nearest integer towards zero
...
"""
function fix(x)
    if x < 0
        fixed = ceil(x)
    else 
        fixed = floor(x)
    end
    convert(Int64,fixed)
end #fix

#######################################################################
# Function that shears an array in order k in the direction of axis
# based on the same function on the Matlab version
"""
...
dshear(array,k,axis) shears and array in order k in the direction of
axis
...
"""
function dshear(array,k,axis)
    if k == 0
        sheared = array;
    else
        rows = size(array,1);
        cols = size(array,2);

        sheared = zeros(size(array))+zeros(size(array))*im
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
    sheared
end #dshear

######################################################################
## Type of filter configurations
type Filterconfigs
    directionalFilter::Array
    scalingFilter::Array
    waveletFilter::Array
    scalingFilter2::Array
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

