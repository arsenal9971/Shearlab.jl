n = 256;

data = rand(n,n);

sizeX = size(data,1);
sizeY = size(data,2);

# Set the variables for the Shearlet trasform
rows = sizeX;
cols = sizeY;
X = data; 
nScales = 2;

shearletSystem = Shearlab.SLgetShearletSystem2D(rows,cols,nScales);

coeffs = Shearlab.SLsheardec2D(X,shearletSystem);

Xrec=Shearlab.SLshearrec2D(coeffs,shearletSystem);

@test size(Xrec) == size(data)
