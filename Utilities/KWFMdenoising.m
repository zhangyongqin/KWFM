function [imgRecon, imgOLRA] = KWFMdenoising( imgOrig, imgNoisy, nSigma)
%% Parameter parsing
nSig = nSigma * 255;
imageTruth = imgOrig * 255;
imageNoisy = imgNoisy * 255;

% Display the PSNR/SIMM of input images
PSNR = csnr( imageNoisy, imageTruth, 0, 0 );
SSIM = cal_ssim( imageNoisy, imageTruth, 0, 0 );
fprintf( 'Noisy Image: nSig = %2.4f, PSNR = %2.2f, SSIM=%.4f \n', nSig, PSNR, SSIM );

% Parameter setting
par = setParameters(nSig);

%% Optimized Low Rank Approximation (OLRA)

% for the generation of the reference image
% Grayscale images
if size(imageNoisy, 3) == 1
    imgLra = OLRAdenoising( imageNoisy, imageTruth, par );
    imageEst = imgLra;
else
    % Color images
    [Rows, Cols, Chas] = size(imageNoisy);
    
    % Forward colorspace conversion: RGB-YUV
    SZ = [Rows * Cols, Chas];
    Mdct = dctmtx(Chas)';
    dataNoisy = reshape(reshape(imageNoisy, SZ) * Mdct, size(imageNoisy));
    dataClean = reshape(reshape(imageTruth, SZ) * Mdct, size(imageTruth));
    
    imgLra = OLRAdenoising( dataNoisy, dataClean, par );
    
    % Inverse colorspace conversion: YUV->RGB
    imageEst = reshape(reshape(imgLra, SZ) / Mdct, size(imgLra));
end

% % save imageEst.mat imageEst;
% load imageEst.mat;
% imageEst = imageNoisy;
%% Kernel Wiener filtering process
if ismatrix(imageNoisy)
    % KWFM for grayscale images
    imgFiltered = KWFMgray(imageEst ./ 255, imageNoisy ./ 255, par.nSig / 255);
    imgDenoised = imgFiltered .* 255;
else
    % KWFM for color images
    imgFiltered = KWFMcolor(imageEst ./ 255, imageNoisy ./ 255, par.nSig / 255);
    imgDenoised = imgFiltered .* 255;
end

imgOLRA = imageEst ./ 255;
imgRecon = imgDenoised ./ 255;
return;
