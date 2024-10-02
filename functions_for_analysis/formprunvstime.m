function [add,rem] = formprunvstime(SimVid)

T = size(SimVid,3);
nDen = size(SimVid,4);

add = zeros([T,nDen]);
rem = zeros([T,nDen]);

for iden = 1:nDen
    for tt = 2:T
        current_syn = (SimVid(:,:,tt,iden)>1);
        past_syn = (SimVid(:,:,tt-1,iden)>1);
        
        add(tt,iden) = sum(current_syn & ~(past_syn),'all');
        rem(tt,iden) = sum(past_syn & ~(current_syn),'all');
    end
end

%add = mean(add,2);
%rem = mean(rem,2);

end

