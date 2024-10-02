function syn = totalsynvstime(SimVid)

syn = mean(squeeze(sum(SimVid>1,[1 2])),2);

end

