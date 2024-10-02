function parsave(fname, SimVid, mats, prms)
% Save-function for parallel computing with parfor, since save and parfor
% are not compatible.
    
    [~,~,~] = mkdir(fname);
    
    varNames = {'SimVid', 'mats', 'prms'};
    for i = 1:numel(varNames)
        varName = varNames{i};
        save(fullfile(fname, [varName, '.mat']), varName, '-v7.3');
    end
end
