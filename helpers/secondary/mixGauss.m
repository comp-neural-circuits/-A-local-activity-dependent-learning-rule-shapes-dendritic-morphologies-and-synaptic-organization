function [fx] = mixGauss(X , MU , theta , S1 , S2 )
    % This function is used to create (Gabor) filters by adding together two 2D
    % Gaussians (one positive one negative), basically mirrored through a
    % certain point in the area.
    
    % Input: - "X" is a 2 column double matrix ???
    %        - "MU" is a 1 x 2 double array containing the 2D real cartesian
    %        coordinates of the point through which the Gaussians are
    %        mirrored (this can be an RF center for instance)
    %        - "theta" is a real number between 0 and 2*pi, determining a
    %        which angle the mean of the positive Guassian is realative to
    %        MU
    %        - "S1" and "S2" are covariance parameters for the 2D Gaussian
    
    % Output: - "fx" is a size(X,1) x 1 double array ???
    
    SIGMA_P = eye(2); SIGMA_P(1,1) = S1; SIGMA_P(2,2) = S2;
    SIGMA_N = eye(2); SIGMA_N(1,1) = S1; SIGMA_N(2,2) = S2;

    ROT = [cos(theta) , sin(theta) ; -sin(theta) , cos(theta)]; % flipped this matrix so that theta accurately represents the direction in which the positive field is pointing
    RSIGMA_P = ROT*SIGMA_P*ROT';
    RSIGMA_N = ROT*SIGMA_N*ROT';

    RMU = (ROT*[1;0])'/2;
    fx = mvnpdf(X ,MU + RMU,RSIGMA_P) - mvnpdf(X,MU  - RMU,RSIGMA_N);
    fx = fx/sum(abs(fx(:)));
end