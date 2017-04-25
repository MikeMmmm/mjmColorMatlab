function rgbx = mjmXYZ2RGBX( xyz, pmat, xmr )
% XYZ2RGBX: compute RGBX primary intensities for desired XYZ specification
% 
% MJMurdoch 201511
% Implementing the method described in Murdoch et al., ICIS 2006.
%
% Inputs:
%   XYZ:  Nx3 array of CIE 1931 XYZ color triads
%   pmat: 3x4 matrix of primary XYZ triads, e.g. measured XYZ for each
%         channel, R, G, B, and "X" where X is whitish: these can be
%         literal XYZ (where Y is luminance in cd/m2) or XYZ factors, for
%         example scaled so that Y is 1 at max RGB as in a display
%   xmr:  scalar in [0,1]: "X" mixing ratio (called white mixing ratio 
%         in the paper): fraction of max-possible X to use
%
% Output:
%   RGBX: Nx4 array of channel intensities, should be on [0,1]: out of
%         gamut colors result in <0 or >1 values!
%

% compute "white equivalent" RGB
WeqRGB = diag( pmat(:,1:3) \ pmat(:,4) );

% RGB from XYZ (ignore X channel)
RGB = ( pmat(:,1:3) \ xyz' )';

% compute maximum-possible X in Weq-normalized RGB
RGBeq = ( WeqRGB' \ RGB' )';
Wmax = min(RGBeq,[],2);

% subtract out X
RGBeq2 = RGBeq - repmat(xmr*Wmax,1,3);
RGB2 = ( WeqRGB' * RGBeq2' )';

% RGBX is RGB and X concatenated
rgbx = [ RGB2 xmr*Wmax ];


