function  [idx, dst]  =  ANN_Search(CurPat, Sigma_arr, Par, Self_arr)
% ann, k-nn search, nearest neighbour search
b = Par.patsize;
patnum = Par.patnum; %-1;
% sigma_PSF = Par.sigma_PSF;
sigma_PSF = sqrt(2)*mean(Sigma_arr(:));

nn=patnum;  %number of nearest neighbors
eps=1;%1, epsilon for ANN
t=cputime;

% Query Patches
QueryPatches = CurPat(:,Self_arr,:);
[Qheight, Qwidth, Qdepth] = size(QueryPatches);
% Construct look-up patch database
DBwidth = size(CurPat,2);
ImageDatabase = CurPat;

[xr,yr] = meshgrid(1:b,1:b);
x = xr-(b+1)/2;
y = yr-(b+1)/2;
gwin = ones(b); %exp(-(x.^2+y.^2)/(2*sigma_PSF^2));

if ndims(CurPat)==3
    QueryPatches = permute(QueryPatches, [1, 3, 2]);
    gwt = repmat(gwin(:),1,size(QueryPatches,2),size(QueryPatches,3));
    gQuery = reshape(gwt.*QueryPatches, [Qheight*Qdepth, Qwidth]);
    
    ImageDatabase = permute(ImageDatabase, [1, 3, 2]);
    gwt = repmat(gwin(:),1,size(ImageDatabase,2),size(ImageDatabase,3));
    gDB = reshape(gwt.*ImageDatabase, [Qheight*Qdepth, DBwidth]);
else
    gwt = repmat(gwin(:),1,size(QueryPatches,2));
    gQuery = gwt.*QueryPatches;
    
    gwt = repmat(gwin(:),1,size(ImageDatabase,2));
    gDB = gwt.*ImageDatabase;
end
%Gaussian SSD
anno=ann(gDB);
[ann_idx, ann_dst] = ksearch(anno, gQuery, nn, eps, true);
close(anno);
% display(['ANN search time: ' num2str(cputime-t)]);

% output 
idx = ann_idx;
dst = ann_dst;

return;