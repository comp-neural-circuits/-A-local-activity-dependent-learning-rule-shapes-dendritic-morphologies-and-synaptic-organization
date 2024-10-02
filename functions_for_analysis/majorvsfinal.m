function mvf = majorvsfinal(SimVid)

nDen = size(SimVid,4);

shell = [0 1 0; 1 0 1; 0 1 0];

mvf = zeros([2 nDen]);

for iden = 1:nDen
    mvf(1,iden) = sum((conv2(SimVid(:,:,1,iden)>0,shell,'same')==1).* (SimVid(:,:,end,iden)>0),'all');
    mvf(2,iden) = sum((SimVid(:,:,end,iden)>0),'all');
end

end

