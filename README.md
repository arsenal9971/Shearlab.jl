## Shearlab.jl


Shearlab is a Julia Library with toolbox for two- and threedimensional data processing using the Shearlet system as basis functions which generates an sparse representation of cartoon-like functions. It is based in the Matlab Library Shearlab3D, developed by the Applied Functional Analysis Research Group in the Technical University of Berlin lead by Professor Gita Kutyniok, for further information of the Matlab Implementation you can visit the link [Shearlab3D](http://www3.math.tu-berlin.de/numerik/www.shearlab.org/).

The Julia implementation has visible efficiency improvements which can be seen in the carpet [Benchmarks](https://github.com/arsenal9971/Shearlab.jl/tree/master/benchmarks), and some examples in [Benchmarks](https://github.com/arsenal9971/Shearlab.jl/tree/master/benchmarks).

For the 2D version one has three important functions:

- Generate the Shearlet System.
```julia
SLgetShearletSystem2D(rows,cols,nScales,shearLevels,full= 0,directionalFilter, quadratureMirrorFilter) 
```

- Decoding of a signal X.
```julia
SLsheardec2D(X,shearletSystem) 
```

- Reconstruction of a signal X.
```julia
SLshearrec2D(coeffs,shearletSystem) 
```
