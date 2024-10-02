function [add,rem] = addremvstime(SimVid)

T = size(SimVid,4);
nDen = size(SimVid,3);

add = zeros([nDen,T]);
rem = zeros([nDen,T]);

shell = [0 1 0; 1 0 1; 0 1 0];

for iden = 1:nDen
    for tt = 2:T
        current_tips = (SimVid(:,:,iden,tt)>0) & (conv2(SimVid(:,:,iden,tt)>0,shell,'same') == 1);
        past_tips = (SimVid(:,:,iden,tt-1)>0) & (conv2(SimVid(:,:,iden,tt-1)>0,shell,'same') == 1);
        % current_tips = (SimVid(:,:,iden,tt)==1) & (conv2(SimVid(:,:,iden,tt)==1,shell,'same') == 1);
        % past_tips = (SimVid(:,:,iden,tt-1)==1) & (conv2(SimVid(:,:,iden,tt-1)==1,shell,'same') == 1);
        
        add(iden,tt) = sum(current_tips & ~(SimVid(:,:,iden,tt-1)>0),'all');
        rem(iden,tt) = sum(past_tips & ~(SimVid(:,:,iden,tt)>0),'all');
        % add(iden,tt) = sum(current_tips & ~(SimVid(:,:,iden,tt-1)==1),'all');
        % rem(iden,tt) = sum(past_tips & ~(SimVid(:,:,iden,tt)==1),'all');
    end
end

% add = mean(add,2);
% rem = mean(rem,2);

end

