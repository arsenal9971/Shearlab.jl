# Shearlab.jl #

[![Build Status](https://travis-ci.org/arsenal9971/Shearlab.jl.svg?branch=master)](https://travis-ci.org/arsenal9971/Shearlab.jl)
[![Coverage Status](https://coveralls.io/repos/arsenal9971/Shearlab.jl/badge.svg?branch=master&service=github)](https://travis-ci.org/arsenal9971/Shearlab.jl?branch=master)
[![codecov](https://codecov.io/gh/arsenal9971/Shearlab.jl/branch/master/graph/badge.svg)](https://travis-ci.org/arsenal9971/Shearlab.j)
[![Join the chat at https://gitter.im/arsenal9971/Shearlab.jl](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/Shearlab-jl/Lobby)
[![Shearlab](http://pkg.julialang.org/badges/Shearlab_0.6.svg)](http://pkg.julialang.org/?pkg=Shearlab&ver=0.6)

## Installation
To install Shearlab.jl from within Julia do 

    julia> Pkg.add("Shearlab")

Note that for the julia-0.6.x there is no official release yet, although the newest version on the repository already works, one should then clone the library doing

    julia> Pkg.clone("https://github.com/arsenal9971/Shearlab.jl")


## Description 
Shearlab is a Julia Library with toolbox for two- and threedimensional data processing using the Shearlet system as basis functions which generates an sparse representation of cartoon-like functions. It is based in the Matlab Library Shearlab3D, developed by the [Applied Functional Analysis Research Group](http://www.math.tu-berlin.de/fachgebiete_ag_modnumdiff/angewandtefunktionalanalysis/v_menue/afg/) in the Technical University of Berlin lead by [Professor Gitta Kutyniok](http://www.tu-berlin.de/?108957), for further information of the Matlab Implementation you can visit the link [Shearlab3D](http://www3.math.tu-berlin.de/numerik/www.shearlab.org/).

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

For more detailed usage functionalities check the original [Shearlab manual](http://shearlab.org/files/documents/ShearLab3Dv10_Manual.pdf), for scientific reference one can also read ["ShearLab 3D: Faithful Digital Shearlet Transforms Based on Compactly Supported Shearlets"](http://www.math.tu-berlin.de/fileadmin/i26_fg-kutyniok/Kutyniok/Papers/ShearLab3D.pdf).
