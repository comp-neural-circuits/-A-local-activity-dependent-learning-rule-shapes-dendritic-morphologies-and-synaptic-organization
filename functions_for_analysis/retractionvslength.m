function [count] = retractionvslength(SimVid)
% counts the number of branches that retracted, as a function of branch
% length
% NOTE: right now it treats the length of the branch as the distance from
% the tip to the nearest branch point at the time of the first retraction.
% This is of course inaccurate but still serves as a rough estimate.
SimVid = logical(SimVid);
count = zeros(1,100);
Retractors = zeros([size(SimVid,1) size(SimVid,2) size(SimVid,4)]);
shell = [0 1 0; 1 0 1; 0 1 0];

for tt = 2:size(SimVid,3)-2
    for iden = 1:size(SimVid,4)
        Dt = logical(SimVid(:,:,tt,iden));
        Dt_then = logical(SimVid(:,:,tt-1,iden));
        Dt_soon = logical(SimVid(:,:,tt+1,iden));

        Rt = Retractors(:,:,iden);
        Rt = Rt + (~Dt & Dt_then & (conv2(Dt_then,shell,'same')==1) & ~Rt);
        Rt_soon = double(conv2(logical(Rt),shell,'same') & Dt & (~Dt_soon & (conv2(Dt,shell,'same')==1)));
        for lin = find(Rt > 0)'
            flower = false([size(SimVid,1) size(SimVid,2)]);
            flower(lin) = 1;
            newflower = Rt_soon & conv2(flower,shell,'same');
            if sum(newflower(:))>0
                Rt_soon(newflower) = Rt(flower) + 1;
            else
                count(Rt(flower)) = count(Rt(flower)) + 1;
            end
        end
        Retractors(:,:,iden) = Rt_soon;
    end
end

end

