### <center> Learned tomographic reconstruction and Wavefront set </center>
<center> Héctor Andrade Loarca </center> 

  
Tomographic reconstruction plays a central role in biomedical imaging applications. For most of the settings, it forms an (very) ill-posed inverse problems, this makes hard to find high-quality reconstruction methods, that generates less artifacts as possible. In the last years some methods of machine learning have been used to improve the state of the art reconstruction methods, but there is still a lot to improve.  

For medical purposes, it is very important to reconstruct correctly the singularities of the image. The CT community has adopted the concept of Wavefront set to describe the singularities of the images that one aims to reconstruct and its directions. The ideal would be then to recover the wavefront correctly from the data; the reality is that this concept is too abstract to implement it straightforwardly.  

In this talk I will present a method for tomographic reconstruction that uses Deep Neural Networks to improve a commonly used primal-dual optimizer, and I will also talk about our approach to implement a Wavefront set recovery in this method.
