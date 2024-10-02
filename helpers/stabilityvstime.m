function stab = stabilityvstime(SimVid,interval)
% computes morphological stability as the correlation coefficient of the
% current picture of the dendrite to the one interval many steps to the
% future.

T = size(SimVid,4);
nDen = size(SimVid,3);

stab = zeros((T - interval), nDen);

for iden = 1:nDen
    for tt = 1:T-interval
        currentDen = SimVid(:,:,iden,tt)>0;
        futureDen = SimVid(:,:,iden,tt+interval)>0;
        corrmat = corrcoef(double(currentDen(:)) , double(futureDen(:)));
        stab(tt,iden) = corrmat(1,2);
    end
end

stab = mean(stab,2);

end

