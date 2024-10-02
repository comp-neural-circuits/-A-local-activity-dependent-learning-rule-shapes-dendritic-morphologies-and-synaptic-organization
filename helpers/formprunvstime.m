function [add,rem] = formprunvstime(SimVid)

T = size(SimVid,4);
nDen = size(SimVid,3);

add = zeros([nDen,T]);
rem = zeros([nDen,T]);

for iden = 1:nDen
    for tt = 2:T
        current_syn = (SimVid(:,:,iden,tt)>1);
        past_syn = (SimVid(:,:,iden,tt-1)>1);
        % current_syn = (SimVid(:,:,iden,tt)==2);
        % past_syn = (SimVid(:,:,iden,tt-1)==2);
        
        add(iden,tt) = sum(current_syn & ~(past_syn),'all');
        rem(iden,tt) = sum(past_syn & ~(current_syn),'all');
    end
end

% add = mean(add,2);
% rem = mean(rem,2);

end

