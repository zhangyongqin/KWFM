function  Index_arr = blockMatching(img, par)

b = par.patsize;
st = par.step;
S = par.SearchWin;
H = size(img,1)-b+1;
W = size(img,2)-b+1;
row = [1:st:H];
row = [row row(end)+1:H];
col = [1:st:W];
col = [col col(end)+1:W];
Rows = length(row);
Cols = length(col);

L = 1:(H*W);
L = reshape(L, H, W);

Nei_arr = int32(zeros(4*S^2, Rows*Cols));
Num_arr = int32(zeros(1, Rows*Cols));
Sidx_arr =  int32(zeros(1, Rows*Cols));

for  i = 1 : length(row)
    for  j = 1 : length(col)
        r = row(i);
        c = col(j);
        idx = (c-1)*H + r;
        idx1 = (j-1)*Rows + i;
        
        rMin = max( r-S, 1 );
        rMax = min( r+S, H );
        cMin = max( c-S, 1 );
        cMax = min( c+S, W );
        
        iset = L(rMin:rMax, cMin:cMax);
        iset = iset(:);
        
        Num_arr(idx1) = length(iset);
        Nei_arr(1:Num_arr(idx1),idx1) = iset;
        Sidx_arr(idx1) = idx;
    end
end

% the number of all the patches in the image
numPatches = H*W;
X = zeros(b^2, numPatches, par.Chas, 'single');

% Patch-based image representation converted from pixel-based image
k = 0;
for i  = 1:b
    for j  = 1:b
        k = k+1;
        Block = img(i:end-b+i,j:end-b+j, :);
        X(k,:,:) = reshape(Block, numPatches, par.Chas);
    end
end

Len = length(Num_arr);
Index_arr = zeros(par.patnum,Len);

for  k = 1 : Len
    Block = X(:,Sidx_arr(k),:);
    Neighbors = X(:,Nei_arr(1:Num_arr(k),k),:);
    Diff = (repmat(Block,1,size(Neighbors,2))-Neighbors).^2;
    Dist = sum(reshape(permute(Diff, [1, 3, 2]), [size(X,1)*size(X,3), size(Neighbors,2)]));
    [~, seridx] = sort(Dist);
    Index_arr(:,k)=Nei_arr(seridx(1:par.patnum),k);
end
