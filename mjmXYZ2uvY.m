function uvY = mjmXYZ2uvY( XYZ )
% mjmXYZ2uvY: compute u'v'Y (chromaticity & luminance) from XYZ
%
% usage:  uvY = mjmXYZ2uvY( XYZ )
%
% input:  XYZ  (Nx3) XYZ tristimulus values (normalized or not; doesn't matter)
%   
% output: uvY  (Nx3) u'v' chromaticity and Y luminance
%
% MJMurdoch 20160802

% error check
if nargin < 1
    help mfilename
elseif size(XYZ,2) < 3
    error(['Input argument error to: ' mfilename ]);
end

% compute using other functions
uvY = mjmxyY2uvY( mjmXYZ2xyY( XYZ ));