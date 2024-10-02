function [ball] = manhattenball_2D(r)
star = [0 1 0; 1 1 1; 0 1 0];

ball = false((2*r+1));
ball(r+1,r+1) = 1;

for i = 1:r
    ball = convn(ball,star,'same');
end

ball = logical(ball);
end

