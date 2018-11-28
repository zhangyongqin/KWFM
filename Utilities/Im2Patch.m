function  [Y, SigmaArr]  =  Im2Patch( imgEst,imgNoisy, par )
b = par.patsize;
NumPatches = (size(imgEst,1)-b+1)*(size(imgEst,2)-b+1);
Y = zeros(b*b, NumPatches, par.Chas, 'single');
NY = zeros(b*b, NumPatches, par.Chas, 'single');

k = 0;
for i = 1:b
    for j = 1:b
        k = k+1;
        Epatch = imgEst(i:end-b+i,j:end-b+j, :);
        Npatch = imgNoisy(i:end-b+i,j:end-b+j, :);
        Y(k,:,:) = reshape(Epatch, NumPatches, par.Chas);
        NY(k,:,:) = reshape(Npatch, NumPatches, par.Chas);
    end
end
%Estimated local noise deviation
SigmaArr = par.lamada*(sqrt(abs(repmat(par.nSig^2,[1,size(Y,2),par.Chas])-mean((NY-Y).^2))));
