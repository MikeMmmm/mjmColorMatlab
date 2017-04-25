function SPD = mjmPlanck(Tc,wl)
% mjmPlanck: compute spectral power distribution of a blackbody radiator of
%            a specified temperature (As in IES TM-30-15 and CIE 15:2004)
%
% usage:  SPD = mjmPlanck(Tc,wl)
%
% input:  Tc  (1xN) Blackbody temperature Kelvin (typically 2000-20000K)
%         wl  (Mx1) monotonic wavelength axis in nm
%   
% usage:  SPD = mjmPlanck(Tc)
%         (uses default wavelength axis of 380:5:780)
%   
% output: SPD  (MxN) spectral power distributions in columns
%
% MJMurdoch 20160409, 20160802

% error check
if nargin < 1
    help mfilename
elseif nargin < 2
    wl = (380:5:780)';
end
if size(Tc,1) > 1
    if size(Tc,2) > 1
        error(['Input argument error to: ' mfilename ]);
    else
        Tc = Tc';
    end
end


% compute using subfunction below for Le: SPD normalized to 1 at 560
SPD = bsxfun(@rdivide, Le(Tc,wl), Le(Tc,560));

end

% subfunction (Planck's law with c1 & pi ignored, n=1 (vacuum, typical for
%              colorimetry), and c2=1.4388e-2)
function le = Le(Tc,wl)
    % convert wl to meters
    wl = wl * 1e-9;
    le = bsxfun(@times, wl.^-5, (exp(1.4388e-2./bsxfun(@times,wl,Tc)) - 1).^-1 );
end