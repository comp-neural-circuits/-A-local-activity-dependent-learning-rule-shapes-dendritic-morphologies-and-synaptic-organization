function [dMat , SMat , ConSyn , W] = get_distances_ver_20_11_03(newConSyn , SynPositions , Dt , ConSyn , dMat , SMat , W , prms , mats) 
    for lin = find(newConSyn == 1)'
        linsyn = SynPositions==lin;
        conSynPos = find(ConSyn(:));
        if length(conSynPos) > 0
            gr = im2graph(Dt);

            %% Version 2 from Jan
            for jj = 1: length(conSynPos)
                [route, dist] = route_planner(gr, lin, conSynPos(jj));
                dMat(linsyn , SynPositions==conSynPos(jj)) = dist;
                dMat(SynPositions==conSynPos(jj) , linsyn) = dist;
            end
            %% changed until here

            % for jj = 1:length(conSynPos)
                % [dist, path, pred] = graphshortestpath(gr, lin, conSynPos(jj)) ;%Default uses Dijkstra
                % dMat(linsyn , SynPositions==conSynPos(jj)) = dist;
                % dMat(SynPositions==conSynPos(jj) , linsyn) = dist;
            SMat = normpdf(dMat, 0 , prms.normSTD)*(sqrt(2*pi)*prms.normSTD);%prms.normSTD);
            % % SMat = SMat - eye(length(SMat)).*SMat + eye(length(SMat));
            % end
        end
        ConSyn(lin) = 1;
        W(linsyn)=prms.initialweight;
    end
end

function [route, dist] = route_planner(dg, S, T)
% find shortest path in graph of road intersections (nodes)
%
% usage
%   [route, dist] = ROUTE_PLANNER(dg, S, T)
%
% input
%   dg = directed graph of road network
%      = [N x N] matrix
%        (element i,j is non-zero when the connection between nodes
%         i->j exists). Use the connectivity_matrix returned by function
%        extract_connectivity.
%   S = route source (start) node
%     = node index (int)
%   T = route target (destination) node
%     = node index (int)
%
% output
%   route = matrix of subsequent nodes traversed
%   dist = total distance covered by route, counting as unit distance a
%          transition between nodes (Remark: this is NOT the actual
%          distance over the map for this route).
%
% dependency
%   dijkstra, part of File Exchange ID = 24134,
%   (c) 2008-2009 Stanford University, by David Gleich
%   http://www.mathworks.com/matlabcentral/fileexchange/24134-gaimc-graph-algorithms-in-matlab-code
% OR
%   graphshortestpath, part of MATLAB Bioinformatics Toolbox.
%
% 2010.11.17 (c) Ioannis Filippidis, jfilippidis@gmail.com
%
% See also EXTRACT_CONNECTIVITY, PLOT_ROUTE, PLOT_ROAD_NETWORK, PLOT_NODES.

%% find path

% BioInformatics Toolbox available ?
% if exist('graphshortestpath', 'file')
%     [dist, route] = graphshortestpath(dg, S, T, 'Directed', true,...
%                                       'Method', 'Dijkstra');
% else
[d, pred] = dijkstra(dg, S);

route = [];
curnode = T;
curpred = pred(curnode);
while curpred ~= 0
    route = [curpred, route];
    
    curnode = curpred;
    curpred = pred(curnode);
end

dist = d(T);
% end

% no path found ?
if isempty(route)
    warning('No route found by the route planner. Try without road directions.')
    return
end

%% report
% disp('Distance: ')
% disp(dist.')
end