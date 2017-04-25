function [XYZ] = mjmSPD2XYZ( SPD, cmf, normFlag, dwl )
% mjmSPD2XYZ: compute XYZ tristimulus values from radiant spectral power distribution
% 
% usage:  [XYZ] = mjmSPD2XYZ( SPD, cmf )
%
% input:  SPD  (NxM) spectral power distribution of illuminant(s) in columns
%         cmf  (Nx3) color matching functions x-bar, y-bar, z-bar, at
%              wavelengths corresponding to those used to sample SPD
%         normFlag  (1) then normalize Y to 100%; (0) use absolute, then if 
%              in W/steradian/wl then Y will be candelas / m2
%         dwl  delta wavelength, only needed if normFlag=0
%
% output: XYZ  (Nx3) tristimulus values of SPD 
%
% NOTE: CIE 15:2004 recommends wl axis of 360:1:830nm, but says 5nm spacing
%       is OK for most things
%
% MJMurdoch 20160808

% error check
if nargin < 2
    help mfilename
elseif size(SPD,1) ~= size(cmf,1) || size(cmf,2) ~= 3
    error(['Input argument error to: ' mfilename ]);
end
if nargin < 3
    normFlag = 1;
end
if ~normFlag & nargin < 4
    error(['Input argument error to: ' mfilename ]);
end    

% normalize with k = 683 lumens/W
if normFlag
    k = 1; % normalize later
else
    k = 683 * dwl;
end

% compute according to CIE 15:2004
% ( put SPDs in 3rd dimension for efficiency )
SPD = permute( SPD, [1 3 2] );
XYZ = k * sum( bsxfun( @times, SPD, cmf ), 1 );
if size(SPD,3) > 1
    XYZ = squeeze(XYZ)';
end

% normalize?
if normFlag
    XYZ = bsxfun( @rdivide, XYZ, XYZ(:,2) ) * 100;
end