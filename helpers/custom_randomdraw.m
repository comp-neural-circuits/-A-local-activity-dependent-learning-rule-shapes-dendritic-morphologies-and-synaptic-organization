function [sample] = custom_randomdraw(M)
% this function takes as input any matrix with only numeric values and
% returns a logical matrix of the same size with a single 1 that is drawn
% randomly by treating the matrix entries as probabilities
sample = false(size(M));

M = M/sum(M(:));

order = randsample(numel(M),numel(M));

stop = false;
while stop == false
    for i = 1:numel(M)
        if rand <= M(order(i))
            sample(order(i)) = true;
            stop = true;
            break
        end
    end
end

end

