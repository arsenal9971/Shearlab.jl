### Notes on presentation: Tomographic Reconstruction and Wavefront set.

#### Slide 1: Presentation.

- Contributions by Philipp, Gitta and Ozan.

#### Slide 2: Slide 3 and 4.

- Show the forward model, and mention that g is known as the sinogram in this parametrization. And what you mean by distributions (dual of smooth distributions).

- Ill posedness of the problem: Filtered back projection, involves differnetaion, incresies singularities and noise. Filtered back projection is unbounded, two far apart images can have very close Radon transform.

#### Slide 5: Solving inverse problems.

- Classical approach when it is not straight forward to compute the inverse. Missfit against data, minimizing an affince transform of the negative loglikelihood. Best probabilistic estimator. Typicially use the Square error. **Downside**: Ill posed problems tipically.

- How to address overfitting, known as regularization theory: You need to rewrite the problem into a more regular one, different methods:

    - Knowledge-driven regularization, uses first principles, and use data to calibrated the parameters of the model (incorporates extra-information).
    - Data-driven regularization: Model learned from data, using methods on statistical estimation.
    - Hybrid, take the best parts from both.

#### Slide 6: Knowledge-driven regularization.

- Ups:
    - Guided by first principles (developed along the history by great scientists), tested and validated independently. 
    - Not much data required.
    - Simple concepts, aiding understanding.

- Downs:
    - Requires explicit description of causal relations, not always a good model exists.
    - Not straight forward, uncertainty quantification.

- Examples: Analytic pseudoinverse (good when there is a mollifier in the space, e.g. FBP), Iterative methods with early stopping (e.g. ART, algebraic reconstruction technique, that uses the so called Kaczmarz method for solving the related linear equation); and Variational methods that enforces the preservation of certain a-priori information using a regularization functional (e.g. TV, l1,..., where you impose certain sparsity under some represenation).

#### Slide 7: Data-driven regularization.

- Pros:
    - Deep undestanding of the problem is not needed, just a lot of sufficiently informative data.
    - Can capture complicated causal relation without making any limiting assumption (so in that sense is less reductionist).

- Cons:
    - Does not provide any conceptual simplification (no much understanding is acquired).
    - Not easy to incorporate a priori knowledge, so one cannot garanty a reconstruction that make sense.
    - Computationally exhaustive.

- Basic idea: Parametrized a sequence of pseudoinverse and find the best paramter estimate by minimizing a statistical error against training data.


