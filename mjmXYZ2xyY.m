function xyY = mjmXYZ2xyY( XYZ )
% mjmXYZ2xyY: compute xyY (chromaticity & luminance) from XYZ
%
% usage:  xyY = mjmXYZ2xyY( XYZ )
%
% input:  XYZ  (Nx3) XYZ tristimulus values (normalized or not; doesn't matter)
%   
% output: xyY  (Nx3) xy chromaticity and Y luminance
%
% MJMurdoch 20160802

% error check
if nargin < 1
    help mfilename
elseif size(XYZ,2) < 3
    error(['Input argument error to: ' mfilename ]);
end

% compute xy from XY, preserve luminance Y
xyY = [ XYZ(:,1:2) ./ repmat(sum(XYZ,2),1,2) XYZ(:,2) ];
