
% Lets load the data
load psi1file
load psi2file
load psi3file

scales = 4

% Lets compute the shearlet transform from the first file data
%%load data
X = psi1;

%%create shearlets
shearletSystem = SLgetShearletSystem2D(0,size(X,1),size(X,2),scales);


%%decomposition
coeffs = SLsheardec2D(X,shearletSystem);


% save it to a csv file

csvwrite('psifile1.csv',psi1)
csvwrite('psifile2.csv',psi2)
csvwrite('psifile3.csv',psi3)

imwrite(psi1,'psi1.png')
imwrite(psi2, 'psi2.png')
imwrite(psi3, 'psi3.png')