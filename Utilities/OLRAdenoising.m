function imgEst = OLRAdenoising( imgNoisy, imgClean, par )
% Image size
[Rows, Cols, Chas] = size(imgNoisy);
par.Chas = Chas;

% Number of patches in the image
imgEst = imgNoisy;

% Extract the coordinates of the target patches in the noisy image
Sidx_arr = imTargetPatches(imgNoisy, par);

for iter = 1 : par.Iter
    imgEst = imgEst + par.delta*(imgNoisy - imgEst);
    [curPatch, Sigma_arr]	= Im2Patch(imgEst, imgNoisy, par);
    
    if(iter==1)
        % Use the input noise for the first interation
        Sigma_arr = par.nSig * ones(size(Sigma_arr));
    end
    
    if (mod(iter-1, par.Innerloop)==0)
        par.patnum = par.patnum - 10;
        % Selection switch: Global and local search
        similarPatches = blockMatching(imgEst, par);
% %         if iter>=(par.Iter-par.Switch)
% %             [similarPatches, ~] = ANN_Search(curPatch, Sigma_arr, par, Sidx_arr);
% %         else
% %             similarPatches = blockMatching(imgEst, par);
% %         end
    end
    
    [patchEst, patchWei] = LowRankApproximation(similarPatches, Sidx_arr, Sigma_arr, curPatch, par);   % Estimate all the patches
    imgEst = Patch2Im(patchEst, patchWei, par.patsize, Rows, Cols, Chas);
    PSNR = csnr( imgEst, imgClean, 0, 0 );
    SSIM = cal_ssim( imgEst, imgClean, 0, 0 );

    fprintf( 'Iter = %d, PSNR = %2.2f, SSIM = %.4f \n', iter, PSNR, SSIM);
end

return;
