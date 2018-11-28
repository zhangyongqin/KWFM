function imgRecovery = KWFMcolor(imgGuide, imgNoisy, noiSigma)
noiSigma2 = noiSigma^2;
% parameter setting
if noiSigma <=20/255
    rad = 41;
    sigSpa =20;
    coeRng = 2.2; %2.1; %2.0; %1.8; %1.5; %1.2;   %1.2
    coeFreq = 0.8; %0.7;   %0.7
elseif noiSigma <=40/255
    rad = 41;
    sigSpa =20;
    coeRng = 2.0; 
    coeFreq = 1.0; 
elseif noiSigma <=60/255
    rad = 41;
    sigSpa = 20;
    coeRng = 1.1;
    coeFreq = 1.2; 
else % noiSigma >60~100++
    rad = 41;
    sigSpa = 20;
    coeRng = 0.6;  %0.6
    coeFreq = 1.2;  %1.2
end

[Hei, Wid, Cha] = size(imgNoisy);
tSZ = [Hei * Wid, Cha];

% Forward color space conversion
Mdct = dctmtx(Cha)';
dataGuide = reshape(reshape(imgGuide, tSZ) * Mdct, size(imgGuide));
dataNoisy = reshape(reshape(imgNoisy, tSZ) * Mdct, size(imgNoisy));

% Reweight three channels
reWei = reshape(std(reshape(imgGuide, tSZ) * Mdct), [1, 1, Cha]);

b = rad*2+1;
[Hei, Wid, ~] = size(dataNoisy);
[dx, dy] = meshgrid(-rad:rad);
gKer = exp(- (dx.^2 + dy.^2) / (2 * sigSpa^2));
imgGuidePad = padarray(dataGuide, [rad, rad], 'symmetric');
imgNoisyPad = padarray(dataNoisy, [rad, rad], 'symmetric');
imgDenoised = zeros(size(dataNoisy));

for c = 1:Wid
    for r = 1:Hei
        guidePatch = imgGuidePad(r:r+2*rad, c:c+2*rad, :);
        noisyPatch = imgNoisyPad(r:r+2*rad, c:c+2*rad, :);
        diff  = guidePatch-repmat(guidePatch(1+rad, 1+rad, :), [1+2*rad, 1+2*rad, 1]);
        bfKernel  = exp(- diff.^2 ./ (repmat(reWei, [size(diff,1), size(diff,2), 1]) .* coeRng * noiSigma2)) .* repmat(gKer,[1,1,3]);
        kerSum = sum(sum(bfKernel));
        mgPixel = sum(sum( guidePatch .* bfKernel )) ./ kerSum;
        mnPixel = sum(sum( noisyPatch .* bfKernel )) ./ kerSum;
        
        noiVar  = noiSigma2 .* sum(sum(bfKernel.^2));
        freqGuide  = fft2(circshift(( (guidePatch-repmat(mgPixel, [b,b,1])) .* bfKernel ), -[rad rad]));
        freqNoisy  = fft2(circshift(( (noisyPatch-repmat(mnPixel, [b,b,1])) .* bfKernel ), -[rad rad]));
        
        freqShrink  = freqGuide .* conj(freqGuide) ./ (freqGuide .* conj(freqGuide)+ coeFreq * repmat(noiVar, [b, b, 1]));
        
        resiPixel = sum(sum(freqNoisy .* freqShrink)) ./ (2*rad + 1)^2;
        
        imgDenoised(r, c, :) = mnPixel + real(resiPixel);
    end
end

% Inverse color space conversion
imgRecovery = reshape(reshape(imgDenoised, tSZ) / Mdct, size(imgDenoised));

end


