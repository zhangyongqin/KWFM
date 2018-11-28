function imgRecovery = KWFMgray(imgGuide, imgNoisy, noiSigma)

noiSigma2 = noiSigma^2;
% parameter setting
if noiSigma <=20/255
    rad = 41;
    sigSpa = 20;
    coeRng = 0.81;
    coeFreq = 1.6;
elseif noiSigma <=40/255
    rad = 41;
    sigSpa = 20;
    coeRng = 0.32;
    coeFreq = 1.4;
elseif noiSigma <=60/255
    rad = 41;
    sigSpa =20;
    coeRng = 0.28;
    coeFreq = 1.2;
else % noiSigma >60~100++
    rad = 41;
    sigSpa = 20;
    coeRng = 0.24; 
    coeFreq = 1.0; 
end

[Hei, Wid] = size(imgNoisy);
[dx, dy] = meshgrid(-rad:rad);
gKer = exp(- (dx.^2 + dy.^2) / (2 * sigSpa^2));
imgGuidePad = padarray(imgGuide, [rad, rad], 'symmetric');
imgNoisyPad = padarray(imgNoisy, [rad, rad], 'symmetric');
imgRecovery = zeros([Hei, Wid]);


for c = 1:Wid
    for r = 1:Hei
        guidePatch = imgGuidePad(r:r+2*rad, c:c+2*rad);
        noisyPatch = imgNoisyPad(r:r+2*rad, c:c+2*rad);
        diff = guidePatch-guidePatch(1+rad, 1+rad);
        rKer = exp(-diff.^2 ./ (coeRng*noiSigma2));
        bfKernel = rKer .* gKer;
        kerSum = sum(bfKernel(:));
        mgPixel = sum(guidePatch(:) .* bfKernel(:)) ./ kerSum;
        mnPixel = sum(noisyPatch(:) .* bfKernel(:)) ./ kerSum;
        
        noiVar = noiSigma2 .* sum(bfKernel(:).^2);
        freqGuide = fft2(ifftshift((guidePatch-mgPixel) .* bfKernel));
        freqNoisy = fft2(ifftshift((noisyPatch-mnPixel) .* bfKernel));
        
        freqShrink = freqGuide .* conj(freqGuide) ./ (freqGuide .* conj(freqGuide)+coeFreq*noiVar);
        
        resiPixel = sum(freqNoisy(:) .* freqShrink(:)) ./ ((2*rad+1)^2);
        denoisedPixel = mnPixel + real(resiPixel);
        imgRecovery(r,c) = denoisedPixel;
    end
end

return;
