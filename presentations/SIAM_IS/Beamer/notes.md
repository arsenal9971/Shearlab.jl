## Notes for thesis defence beamer.

- [Presentation of myself and thanks for the public].

### Slide 2: Inverse problems in imaging

- The goal of an inverse problem is to recover the parameters characterizing a system under investigation from measurements.

- Mathematical formulation with the forward operator that characterized the way data arises from measurements and noise.

- Classical Solution, minimazing the the miss-fit of the data, using a transformation of the negative log-likelihood (find maximum likelihood), one example for miss-fit of data is square error.

### Slide 3: Ill-posedness and regularization.

- Introduction of Hadamard well-posedness.

- Problems of overfitting when having Ill-posed problems.

- Definition of regularization as a set of methods that change the original problem to a more regular one to avoid overfitting.

- Variational regularization: The one that will be used in this presentation.

### Slide 5-9: Examples of inverse problems

- Denoising, Inpainting, Deblurring (Deconvolution), CT, MRI.

-Explain orthogonal projection on inpainting.

- Common thing between them: They are all ill-posed and interesting for science. 

- Mention that Denoising and Inpainting are the ones that we will focus.

### Slide 10: Image denoising

- Goal: Recover image (in cartoon-like functions space, that will be explained later), from noisy data with a Gaussian noise with standard deviation.

- The risk of the estimator.

- Typically one would like to obtain the estimator that attains the minimax of the MSE (minimize the worst behaivor, typical in different applications based on stochastical measurements).

### Slide 11: Minimax MSE.


- It is proven that sparsifying the image and thresholding (with threshold depending on the standard deviation) gives the Minimax solution, which sparsifying frame, with the sparsity performance defined by the best N-term approximation, explained later.

- Mention that the general risk cannot be minimized since it depends on a parameter that we dont know (the noise).

- Mention that the sparsity performance of the frame influences its performance on denosing, via the decay of the best N-term estimator, this can also be seen as the noise having not so important structured information as the actual features. 

- We will talk about the proper sparsifying fame after.

### Slide 12: Image inpainting

- Show the forward problem, explain the orthogonal projection.

- Result of compressed sensing for image recovery from underdetermined, non-adaptive linear measurements.

### Slide 13: Error Estimate

- The error estimation depends on the level of cluster sparsity that measures the lost information of the shearlets in the missing part, and the cluster coherence, that measures the coherence of the coefficients in the found cluster. 

- A sparsifying frame for images allows you to perform image denoising and inpainting, the reconstruction quality depends on the sparsifying level. The problem is to choose a good sparsifying frame.

### Slide 14: Cartoon like functions

- Before proceeding on the frame picking, we need a good model for image spaces, mostly defined by edges.

### Slide 15: Example of frames for images

- Gabor, wavelets, curvelets, shearlets.

- Show an example of Morlet wavelet, remark that it is isotropic in both directions.

- Mention that wavelet frames are obtained by scaling and translating certain windows functions.

### Slide 16: Optimal approximation error for images

- Show the optimal best term approximation error which is related to the denosing and inpainting performance. 

- Show that wavelets have a slower approximation error, by its isotropic character, and can be solve by introducing anisotropic operations, shearing and anisotropic scaling that approximate optimally curve-like edges.

### Slide 17: Shearlet Transform

- The shearlet transform uses elements that are obtained by scale, shear and translate windows functions. 

- Under certain circumstances form frames (classical shearlets, cone-adapted, band-limited, compactly supported).

### Slide 18: Cone adapted shearlet transform.

- Obtained by projecting into cones of the frequency domain, and form certain tiling and a low-frequency area.

- Better for implementation, one does not need to have infinite number of scalings and shearings to approximate vertical lines.

- They attain the optimal appriximation error for cartton-like functions, one can use it for inpainting and denoising.


### Slide 19: Current software.

- Matlab, python and julia.

### Slide 20: Why julia?

- FFt, JIT, libraries, GPU-support.

- Show the notebooks.
