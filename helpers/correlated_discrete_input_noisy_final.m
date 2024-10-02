function [S,GroupID] = correlated_discrete_input_noisy_final(synNum,ngroup,pairstrength,incor,T,mu)

% Generate a master spiketrain with the desired firing rate
master_spiketrain = rand(1, T) < mu;
% Keeping the appropriate amount of spikes from the master spiketrain
master_spiketrain(master_spiketrain > 0) = rand([1, sum(master_spiketrain,'all')]) < pairstrength;

S_groups = false([ngroup,T]);
% Generate the synchronous/correlated spikes of each individual group
for i = 1:ngroup
    cgroup = master_spiketrain;
    cgroup(cgroup == 0) = rand([1, T - sum(cgroup,'all')]) < (mu - sum(cgroup,'all')/T - mu*(1-incor));
    S_groups(i,:) = cgroup;
end

% Add individual spikes for each of synapse
S = false(synNum , T);
GroupID = 1:synNum;
GroupID = mod(GroupID,ngroup)+1;
GroupID = GroupID(randsample(synNum,synNum))';

for i = 1:synNum
    cur_syn = S_groups(GroupID(i),:);
    cur_syn(cur_syn == 0) = rand([1, T - sum(cur_syn,'all')]) < (mu - sum(cur_syn,'all')/T);
    S(i,:) = cur_syn;
end

end