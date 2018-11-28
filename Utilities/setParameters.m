function par = setParameters(nSig)
par.nSig = nSig;             % Noise variance of the input noisy image
par.SearchWin = 30;      % Nonlocal search domain for similar patches
par.delta = 0.1;               % Parameter for residual images between each iteration
par.c = 2*sqrt(2);            % Constant num for the weight vector
par.Innerloop = 2;          % InnerLoop Num of between re-blockmatching
par.ReWeiIter = 3;

if nSig <= 20
    par.patsize = 6;      % patch size
    par.patnum = 70;    % the number of initial nonlocal similar pathces
    par.Iter = 8;            % total iter numbers
    par.Switch = 2;       % the interation number of global search
    par.lamada = 0.54;  % noise parameter for each interation
elseif nSig <= 40
    par.patsize = 8;
    par.patnum = 90;
    par.Iter = 10;
    par.Switch = 2;
    par.lamada = 0.58;
elseif nSig <= 60
    par.patsize = 8;
    par.patnum = 105;
    par.Iter = 14;
    par.Switch = 2; 
    par.lamada = 0.59;
else
    par.patsize = 9; 
    par.patnum = 130; 
    par.Iter = 14; 
    par.Switch = 2; 
    par.lamada = 0.59; %0.58;
end

par.s1 = 25;
par.win  = 6;
par.nblk = 12;
par.hp = 75;
par.step =  floor((par.patsize)/2-1);  
