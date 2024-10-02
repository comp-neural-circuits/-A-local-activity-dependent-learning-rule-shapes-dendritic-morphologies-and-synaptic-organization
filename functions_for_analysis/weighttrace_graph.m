function [stabilized,pruned] = weighttrace_graph(allWtrace)
nDen = size(allWtrace,3);
T = size(allWtrace,2);

stabilized = zeros([2 T nDen]);
pruned = zeros([2 T nDen]);

for iden = 1:nDen
    W = allWtrace(:,:,iden);
    pruned_id = W(:,end) == 0;
    stabilized_id = W(:,end) > 0.5;
    
    % shifting all the weight traces, so that the initial creation of the
    % synapse is at t=0
    Wsorted = zeros(size(W));
    for isyn = find(sum(W,2) > 0)'
        cW = W(isyn,:);
        first = min(find(cW > 0),[],'all');
        newW = zeros(size(cW));
        newW(sort((1:T)>= first,'descend')) = cW((1:T)>= first);
        newW(~sort((1:T)>= first,'descend')) = NaN;
        Wsorted(isyn,:) = newW;
    end
    %setting the zero rows to NaN
    Wsorted(sum(W,2) == 0,:) = NaN;
    pruned(1,:,iden) =  mean(Wsorted(pruned_id,:),1,'omitnan');
    pruned(2,:,iden) =  std(Wsorted(pruned_id,:),0,1,'omitnan');
    stabilized(1,:,iden) =  mean(Wsorted(stabilized_id,:),1,'omitnan');
    stabilized(2,:,iden) =  std(Wsorted(stabilized_id,:),0,1,'omitnan');
end

pruned = mean(pruned,3);
stabilized = mean(stabilized,3);
    
end

