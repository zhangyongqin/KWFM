function Sidx_arr = imTargetPatches(img, par)

b = par.patsize;
st = par.step;
H = size(img,1)-b+1;
W = size(img,2)-b+1;
row = [1:st:H];
row = [row row(end)+1:H];
col = [1:st:W];
col = [col col(end)+1:W];
Rows = length(row);
Cols = length(col);

Sidx_arr =  int32(zeros(1, Rows*Cols));

for  i = 1 : length(row)
    for  j = 1 : length(col)
        r = row(i);
        c = col(j);
        idx = (c-1)*H + r;
        idx1 = (j-1)*Rows + i;
        Sidx_arr(idx1) = idx;
    end
end