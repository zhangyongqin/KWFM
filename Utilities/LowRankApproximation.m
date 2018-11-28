function [estPatch, Wei] = LowRankApproximation(simPatches, Sidx_arr, Sigma_arr, curPatch, par)

% the number of similar patches
nop = par.patnum;
estPatch = zeros(size(curPatch));
Wei = zeros(size(curPatch));

% For similar patches of each target patch
for  k = 1 : length(Sidx_arr)
    patchStack = curPatch(:, simPatches(1:nop,k), :);
    meanStack = repmat(mean( patchStack, 2 ),1,nop);
    patchStack = patchStack-meanStack;
    
    % EVT: eignvalue thresholding
    [tmpEst, tmpW] = EVT(patchStack, Sigma_arr(1,Sidx_arr(k),:), meanStack);
    estPatch(:,simPatches(1:nop,k),:)  = estPatch(:,simPatches(1:nop,k),:)+tmpEst;
    Wei(:,simPatches(1:nop,k),:) = Wei(:,simPatches(1:nop,k),:)+tmpW;
end
end

