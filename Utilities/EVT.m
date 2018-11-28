function  [Xc, Wei] = EVT( Yc, NSig, mYc )
Chas = size(Yc, 3);
Xc = zeros(size(Yc));
Wei = zeros(size(Yc));

for ch = 1:Chas
    Y = Yc(:,:,ch);
    [U, singvalueY, V] = svd(full(Y),'econ');
    patchNum = size(Y,2);
    
    revVecs = sqrt(max( diag(singvalueY).^2 - patchNum*NSig(ch)^2, 0 ));
    singvalueX = diag(revVecs);
    
    X =  U*singvalueX*V' + mYc(:,:,ch);
    
    % the weighted averaging method for bias correction
    ranks = sum( revVecs>0 );
    if ranks == size(Y,1)
        wei	= 1/size(Y,1);
    else
        wei	= (size(Y,1)-ranks)/size(Y,1);
    end
    Xc(:,:,ch) = X*wei;
    Wei(:,:,ch)	= wei*ones( size(X) );
end

return;
