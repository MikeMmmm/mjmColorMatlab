% illD: returns the daylight illuminant for at the given color temperature
% based on Lawrence's start, but allowing for higher-res eigD
% MJMurdoch 20160409

function [ill,wl]=mjmIllumDaylight(Tc,wl,eigenD)

if nargin<2
    wl = 380:10:780;
end

if nargin<3
    eigD = xlsread('CIE_eigD_380-780-5nm.xls');
    eigWl = eigD(:,1);
    eigD = eigD(:,2:4);
else
    eigWl = wl;
    eigD = eigenD;
end
    
    
if Tc <= 7000
  xD = -4.6070*10^9/Tc^3+2.9678*10^6/Tc^2+0.09911*10^3/Tc+0.244063;
else
  xD = -2.0064*10^9/Tc^3+1.9018*10^6/Tc^2+0.24748*10^3/Tc+0.23704;
end
yD = -3.000*xD^2 + 2.870*xD - 0.275;
M1 = (-1.3515 - 1.7703*xD + 5.9114*yD)/(0.0241 + 0.2562*xD  - .7341*yD);
M2 = (0.0300 - 31.4424*xD + 30.0717*yD)/(0.0241 + 0.2562*xD  - .7341*yD);
ill = eigD(:,1) + M1.*eigD(:,2) + M2.*eigD(:,3);

% interpolate if needed
ill = interp1(eigWl,ill,wl);
