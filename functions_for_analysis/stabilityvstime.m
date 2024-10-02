function stab = stabilityvstime(SimVid,interval)
% computes morphological stability as the correlation coefficient of the
% current picture of the dendrite to the one interval many steps to the
% future.
T = size(SimVid,3);
nDen = size(SimVid,4);

stab = zeros([T - interval , nDen]);

for iden = 1:nDen
for tt = 1:T-interval
    currentDen = SimVid(:,:,tt,iden)>0;
    futureDen = SimVid(:,:,tt+interval,iden)>0;
    corrmat = corrcoef(double(currentDen(:)) , double(futureDen(:)));
    stab(tt,iden) = corrmat(1,2);
end

stab = mean(stab,2);

end


end

