function [S,GroupID,GroupID2,S_groups] = correlated_discrete_input_noisy_2_below(synNum,ngroup,pairstrength,incor,T,mu)

% in this version instead of a general correlation between the group firing
% patterns, there will be designated synapses which get input from both
% groups. this results in the maximum possible correlation being 1/ngroup
% as at that point all the synapses belong so some overlapping pair

GroupID = 1:synNum;
GroupID = mod(GroupID,ngroup)+1;
GroupID = GroupID(randsample(synNum,synNum))';

% giving some of the synapses a second Identity
pairnum = floor((synNum*pairstrength)/2);
GroupID2 = zeros(size(GroupID));
for g1 = 1:ngroup
    for g2 = 1:ngroup
        cgroup = GroupID2((GroupID == g1) & (GroupID2 == 0));
        cgroup = [zeros(1,size(cgroup,1)-pairnum), g2*ones(1,pairnum)];
        cgroup = randsample(cgroup,size(cgroup,1));
        GroupID2((GroupID == g1) & (GroupID2 == 0)) = cgroup';
    end
end

% generating pattern for each group idependently
S_groups = false([ngroup,T]);
for ig = 1:ngroup
    S_groups(ig,:) = rand([1,T]) < mu*incor;
end

% distributing the pattern on the synapses according to their identities
S = false(synNum , T);
for isyn = 1:synNum
    if GroupID2(isyn) == 0
        S(isyn,:) = S_groups(GroupID(isyn),:);
    else
        % randomly taking half of the fireing patterns for each parent
        fh = S_groups(GroupID(isyn),:);
        fh_a = [zeros(1,floor(sum(fh,'all')/2)), ones(1,ceil(sum(fh,'all')/2))];
        fh_a = randsample(fh_a,size(fh_a,2));
        fh(fh) = fh_a;
        
        sh = S_groups(GroupID2(isyn),:);
        sh_a = [zeros(1,floor(sum(sh,'all')/2)), ones(1,ceil(sum(sh,'all')/2))];
        sh_a = randsample(sh_a,size(sh_a,2));
        sh(sh) = sh_a;
        
        S(isyn,:) = fh | sh;
    end
end

% filling up the individual patterns with completely random spikes subject
% to no correlation (as specified by incor)
if incor < 1
    for isyn = 1:synNum
        cur_syn = S(isyn,:);
        cur_syn(cur_syn == 0) = rand([1, T - sum(cur_syn,'all')]) < mu*(1-incor);
        S(isyn,:) = cur_syn;
    end
end

end

