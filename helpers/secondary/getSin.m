function [Sin , sCWM] = getSin(cWM , fxs , a , b)
    % This applies a filter to a matrix and checks if what is left after
    % filtration is beyond a (slightly random) threshold.
    
    % Input: - "cWM" is a 2D double matrix of any size
    %        - "fxs" is a stack of 2D double matrices of the same size as
    %        cWm, these are the filters
    %        - "a" and "b" are real number parameters for an exponential
    %        function. The former corresponds to the fireing rate.
    
    % Output: - "Sin" is a size(fxs,3) x 1 logical array documenting if the
    %           respective filters got over the threshold
    %         - "sCWM" is a size(fxs,3) x 1 double array containg the sum
    %           of the what was left after the respective filtration

    N = size(fxs , 3);
    sCWM = squeeze(sum(sum(fxs.*cWM , 1) , 2));
    ssCWM = a*exp(b*sCWM);
    Sin = ssCWM > rand(N,1);
end