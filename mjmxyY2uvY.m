function uvY = mjmxyY2uvY( xyY )
% mjmxyY2uvY: compute u'v'Y (chromaticity & luminance) from xyY
%
% usage:  uvY = mjmxyY2uvY( xyY )
%
% input:  xyY  (Nx3) xy chromaticity and Y luminance
%   
% output: uvY  (Nx3) u'v' chromaticity and Y luminance
%
% Note that it also works with xy input (gives uv only)
%
% MJMurdoch 20160802

% error check
if nargin < 1
    help mfilename
elseif size(xyY,2) < 2
    error(['Input argument error to: ' mfilename ]);
end

% compute u'v' from xy (ignore luminance)
% formula from CIE 15:2004
uvY = xyY(:,1:2) .* repmat([4 9],size(xyY,1),1) ./...
      repmat( -2*xyY(:,1) + 12*xyY(:,2) + 3, 1, 2);

% include luminance if it was provided
if size(xyY,2) > 2
    uvY(:,3) = xyY(:,3);
end
