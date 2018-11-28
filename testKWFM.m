
close all;
% clear;
% clc;

% add the user toolboxes
toolPath = pwd;
% ANN, approximate nearest neighbor searching
addpath(fullfile(toolPath, '/ann_wrapper'));

% addpath(fullfile(toolPath, '/ann_1.1.2'));
addpath(path, 'Utilities');

% Input images
% addpath(path, 'TestImages/BM3D_images/');
addpath(path, 'TestImages/Kodak_Color');
destFilePath = 'Results/';

% % % grayscale images
% imageFileList = {...
% %     'Barbara.png'
% %     'Boat.png'
%     'Cameraman256.png'
% %     'Couple.png'
% %     'Fingerprint.png'
% %     'Hill.png'
% %     'House.png'
% %     'Lena512.png'
% %     'Man.png'
% %     'Montage.png'
% %     'Peppers256.png'
%     };


% % color images
imageFileList = { ...
    'Wind.jpg'
    % %     'Baboon_512rgb.png'
    % %     'F16_512rgb.png'
    % %     'House_256rgb.png'            % 256x256   'House_256rgb.png'
    % %     'Lake_512rgb.tif'
    % %     'Lena_512rgb.png'               % 512x512   'Lena_512rgb.png'
    % %     'Peppers_512rgb.png'          % 512x512
    % %     'Splash_512rgb.tif'
    % %     'Tiffany_512rgb.tif'
    % %     'kodim01.png'                   % 768x512
    % %     'kodim02.png'                   % 768x512
    % %     'kodim03.png'                   % 768x512
    % %     'kodim05.png'                   % 768x512
    % %     'kodim12.png'                   % 768x512
    };

Stds = [15]; %[10, 30, 50, 70];
PSNR1 = zeros(length(imageFileList),length(Stds));
SSIM1 = zeros(length(imageFileList),length(Stds));

PSNR2 = zeros(length(imageFileList),length(Stds));
SSIM2 = zeros(length(imageFileList),length(Stds));

% Select a test image
pfile = 1;

fileName = imageFileList{pfile};

I0 = im2double(imread(fileName));
[h, w, ch] = size(I0);

% load input_noisy_gray.mat;
% Simulate a noisy image
for nLevel = 1:length(Stds)
    noiSigma = Stds(nLevel)/255;
    
    randn('seed', 0);
    Ynoi = I0 + randn(size(I0)) * noiSigma;
    
    % disp the PSNR of input images
    curPSNR  =  csnr( Ynoi*255, I0*255, 0, 0 );
    fprintf( 'Noisy Image: SD = %2.4f, PSNR = %2.2f \n', noiSigma*255, curPSNR );
    
    % Kernel Wiener Filtering Model for Image Denoising
    [Xest, Xlra] = KWFMdenoising(I0, Ynoi, noiSigma);
    
    curPSNR1 = csnr( Xlra*255, I0*255, 0, 0 );
    curSSIM1 = cal_ssim( Xlra*255, I0*255, 0, 0 );
    
    curPSNR2 = csnr( Xest*255, I0*255, 0, 0 );
    curSSIM2 = cal_ssim( Xest*255, I0*255, 0, 0 );
    fprintf('%s PSNR1=%.4fdB, PSNR2=%.4fdB, SSIM1=%.4f, SSIM2=%.4f\n', fileName, curPSNR1, curPSNR2, curSSIM1, curSSIM2);
    
    
    PSNR1(pfile, 1) = csnr( Xlra*255, I0*255, 0, 0 );
    SSIM1(pfile, 1) = cal_ssim( Xlra*255, I0*255, 0, 0 );
    PSNR2(pfile, 1) = csnr( Xest*255, I0*255, 0, 0 );
    SSIM2(pfile, 1) = cal_ssim( Xest*255, I0*255, 0, 0 );
    
    % Write the denoised images
    imwrite(Xlra,  [destFilePath, fileName(1:end-4), '_', num2str(Stds(nLevel)), '_KWFM_olra', '.png']);
    imwrite(Xest,  [destFilePath, fileName(1:end-4), '_', num2str(Stds(nLevel)), '_KWFM_final', '.png']);
end






