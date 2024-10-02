function [add,rem] = addremvstime(SimVid)

T = size(SimVid,3);
nDen = size(SimVid,4);

add = zeros([T,nDen]);
rem = zeros([T,nDen]);

shell = [0 1 0; 1 0 1; 0 1 0];

for iden = 1:nDen
    for tt = 2:T
        current_tips = (SimVid(:,:,tt,iden)>0) & (conv2(SimVid(:,:,tt,iden)>0,shell,'same') == 1);
        past_tips = (SimVid(:,:,tt-1,iden)>0) & (conv2(SimVid(:,:,tt-1,iden)>0,shell,'same') == 1);
        
        add(tt,iden) = sum(current_tips & ~(SimVid(:,:,tt-1,iden)>0),'all');
        rem(tt,iden) = sum(past_tips & ~(SimVid(:,:,tt,iden)>0),'all');
    end
end

% add = mean(add,2);
% rem = mean(rem,2);

end

