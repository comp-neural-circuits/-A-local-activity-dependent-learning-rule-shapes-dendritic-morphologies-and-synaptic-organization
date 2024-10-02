function mf = maxvsfinal(SimVid)

nDen = size(SimVid,4);
mf = zeros([2,nDen]);

lvt = squeeze(sum(SimVid>0,[1 2]));

for iden = 1:nDen
    mf(1,iden) = max(lvt(:,iden),[],'all');
    mf(2,iden) = lvt(end,iden);
end

end

