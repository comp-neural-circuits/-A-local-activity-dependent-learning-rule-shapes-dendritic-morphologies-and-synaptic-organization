function [loptimal,lrandom,hull] = optimallengthvstime(SimVid)

T = size(SimVid,3);
nDen = size(SimVid,4);

loptimal = zeros([T , nDen]);
lrandom = zeros([T, nDen]);
hull = zeros([T, nDen]);

%shell = [0 1 0; 1 0 1; 0 1 0];

for tt = 1:T
    for iden = 1:nDen
        Syn = SimVid(:,:,tt,iden)>1;
        n = sum(Syn(:));
        
        [X , Y] = find(Syn | (SimVid(:,:,1,iden) > 0));
        
        %if n>1 && ~min(ismember(X,X(1)),[],'all') && ~min(ismember(Y,Y(1)),[],'all') % making sure that the convhull is 2D
        [~ , A] = convhull(X , Y);
        r   = sqrt(A/(2*pi));
        
        hull(tt,iden) = A;
        loptimal(tt,iden) = sqrt(1/pi)*sqrt(A)*sqrt(n+9);
        lrandom(tt,iden) = (128/(45*pi))*r*(n+9);
        %end
        
    end
end

loptimal = mean(loptimal,2);
lrandom = mean(lrandom,2);
hull = mean(hull,2);

end

