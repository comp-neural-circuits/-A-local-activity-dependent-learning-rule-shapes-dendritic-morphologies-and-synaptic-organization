function freesyn = freesynvstime(SimVid,Syn)

freesyn = squeeze(sum( Syn - squeeze(sum(SimVid>1,4)),[1 2]));

end

