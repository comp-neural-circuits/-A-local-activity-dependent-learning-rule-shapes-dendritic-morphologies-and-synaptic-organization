function wt = weighttrace(W,Conlin,Syn)
    Synlin = find(Syn == 1);
    
    wt = zeros(size(Synlin));
    
    for i = 1:size(W,2)
        wt(Synlin == Conlin(i)) = W(i);
    end
end

