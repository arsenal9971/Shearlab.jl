P = phantom(256);
imshow(P)
title('Phantom')

theta3 = 0:3:360;  
[R3,xp] = radon(P,theta3); 
num_angles_R3 = size(R3,2)

figure, imagesc(theta3,xp,R3)
colormap('gray')
title('Sinogram')
xlabel('Parallel Rotation Angle - \theta (degrees)'); 
ylabel('Parallel Sensor Position - x\prime (pixels)');

output_size = max(size(P));
dtheta3 = theta3(2) - theta3(1);
I3 = iradon(R3,dtheta3,output_size);
figure, imshow(I3)
title('Phantom with measured lines')