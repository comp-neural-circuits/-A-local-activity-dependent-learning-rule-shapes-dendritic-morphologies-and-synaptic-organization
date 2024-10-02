function lvt = lengthvstime(SimVid)
% computes length vs time for each dendrite in the simulation

lvt = mean(squeeze(sum(SimVid>0,[1 2])),2);

end

