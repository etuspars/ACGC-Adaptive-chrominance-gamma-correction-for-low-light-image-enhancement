% ACGC: Adaptive chrominance gamma correction for low-light image enhancement
% 
% If you use this code, please cite the following paper:
% 
% @article{severoglu2025acgc,
%   title={ACGC: Adaptive chrominance gamma correction for low-light image enhancement},
%   author={Severoglu, N and Demir, Y and Kaplan, NH and Kucuk, S},
%   journal={Journal of Visual Communication and Image Representation},
%   pages={104402},
%   year={2025},
%   publisher={Elsevier}
% }

clc;clear all;close all

addpath('.\Embedding-Bilateral-Filter-in-Least-Squares-for-Efficient-Edge-preserving-Image-Smoothing-master');

input_img= imread("images\1.jpg");

input_img = double(input_img);
IMAX = max(input_img(:));
    
gamma_corr = uint8(IMAX*power(input_img/IMAX,1/2.2));
    
YCBCR = rgb2ntsc(gamma_corr);

Y=YCBCR(:,:,1);
I=YCBCR(:,:,2);
Q=YCBCR(:,:,3);

Y_new = log(Y+1);  
    
Y_new=Y_new-min(min(Y_new));
Y_new=Y_new/max(max(Y_new));
    
sigma_s = 21;
sigma_r = 0.001;  
    
aprlayer = BLF_LS(Y_new, Y_new, sigma_s, sigma_r);

aprlayer=aprlayer-min(min(aprlayer));
aprlayer=aprlayer/max(max(aprlayer));

detaillayer=Y_new-aprlayer;

aprlayer=double(aprlayer);

avg=mean(aprlayer(:));

spatial_gama=power(avg,aprlayer);

local_gamma_corr=power(aprlayer,spatial_gama); 

local_gamma_corr=adapthisteq(local_gamma_corr,"NumTiles",[2 2],"ClipLimit",0.012);

corr_Y=local_gamma_corr+detaillayer;
corr_Y=exp(corr_Y)-1;

lum_prop =0.000001+corr_Y./(Y_new+0.00001);

Y_final=corr_Y./(Y_new+lum_prop);
I_final=real(power((I),1.65-spatial_gama));
Q_final=real(power((Q),1.65-spatial_gama));
 

YIQ = cat(3,Y_final,I_final,Q_final);
img_rgb = ntsc2rgb(YIQ);
final_image = uint8(img_rgb*255/max(img_rgb(:)));
enhanced_image=abs(double(final_image));
enhanced_image=uint8(255*enhanced_image/max(enhanced_image(:)));

imshow(enhanced_image)
    