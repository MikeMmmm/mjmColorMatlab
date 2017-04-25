function [CCT duv] = mjmCCT( XYZillum )
% mjmCCT: compute Correlated Color Temperature according to CIE 13.3-1995
% 
% usage:  [CCT duv] = mjmCCT( XYZillum )
%
% input:  XYZillum  (Nx3) 1931 XYZ of illuminant(s)
%   
% output: CCT      (Nx1) CCT of illuminant(s)
%         duv      (Nx1) delta-uv of illuminant(s) - not meaningful if > 0.05
%
% MJMurdoch 20160802

% error check
if nargin < 1
    help mfilename
elseif size(XYZillum,2) < 3
    error(['Input argument error to: ' mfilename ]);
end

% convert XYZ to u'v', then u=u' and u=v'*2/3
upvpY = mjmXYZ2uvY( XYZillum );
uv = upvpY(:,1:2) .* repmat([1 2/3],size(upvpY,1), 1);

% load uv coordinates of Planckian locus
persistent uvPlanck;
if isempty( uvPlanck )
    xx = load('uvbbCCT');
    uvPlanck = xx.uvbbCCT;
end

% compute distance in uv to locus points, select minimum
% Note squeeze, permute, bsxfun are just to allow multiple XYZs at once
uvDist = squeeze( sqrt( sum( bsxfun( @minus, uvPlanck(:,2:3), permute(uv,[3 2 1])).^2,2)));
[duv,minInd] = min(uvDist',[],2);

% find CCT of the minimum-distance point
CCT = uvPlanck(minInd,1);


