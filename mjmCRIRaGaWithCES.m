function [Ra Ga RAll polyRef polyTest] = mjmCRIRaGa( SPD, cmf, wl, cmf2, cesRF )
% mjmCRI: compute Color Rendering Index according to CIE 13.3-1995
%         and the Ga/GAll as Kees Teunissen specified
%         USING 99 CES FROM TM30 INSTEAD OF 14 TCS!
% 
% usage:  [Ra Ga uvRef uvTest] = mjmCRIRaGa( SPD, cmf, wl, cmf2 )
%
% input:  SPD  (NxM) spectral power distribution of illuminant(s) in columns
%         cmf  (Nx3) color matching functions x-bar, y-bar, z-bar, at
%              wavelengths corresponding to those used to sample SPD
%         wl   (Nx1) wavelength axis (used to interpolate test sample
%              spectra if needed)
%         cmf2 (Nx3) (OPTIONAL): second set of CMFs to be used in computing
%              Ra and Ga (note first set of CMFs is always used for CCT and
%              reference SPD computations)
%   
% output: Ra   (Mx1) General color rendering index, the mean of R for
%              test samples 1-8
%         Ga   (Mx1) Gamut area index (computed in uv using samples 1-8)
%         RAll (Mx14) R of each of the 14 test samples
%         duvRef (Mx14x2) duv of each of the 14 test samples under Ref illum
%         duvTest (Mx14x2) duv of each of the 14 test samples under Test illum
%
% MJMurdoch 20161202
%  Using code from Matt Aldrich's pspectro (MIT MS work)

% error check
if nargin < 1
    help mfilename
elseif size(SPD,1) ~= size(cmf,1) || size(cmf,2) ~= 3
    error(['Input argument error to: ' mfilename ]);
end

% default is cmf2=cmf
if nargin < 4
    cmf2 = cmf;
end

% compute CCT and reference SPD
XYZ = mjmSPD2XYZ( SPD, cmf );
CCT = mjmCCT( XYZ );
if CCT < 5000
    refSPD = mjmPlanck( CCT, wl );
else
    refSPD = mjmIllumDaylight( CCT, wl );
end

% load test color samples
% tcs = xlsread('CIE_CRI1995_TestColorSamples.xls');
tcs = [wl cesRF];
% tcsWl = tcs(:,1);
% tcsRef = tcs(:,2:end);

% assign var names to match Aldrich's
range = wl';
cie1931xyz1nm = [wl cmf2];
CIETCS1nm = tcs;
testsourcespd = [wl SPD];
referencespd = [wl refSPD];


% below from Matt Aldrich

%function [Ra R] = getcri1995(testsourcespd,referencespd,range)
%load CIETCS1nm
%load cie1931xyz1nm 

%find starting point based on range input

cie1931xyz1nm = horzcat(range',interp1(cie1931xyz1nm (:,1),cie1931xyz1nm (:,[2 3 4]),range,'linear'));
CIETCS1nm = horzcat(range',interp1(CIETCS1nm(:,1),CIETCS1nm(:,2:end),range,'linear'));

startval = find(cie1931xyz1nm(:,1) == min(range));
endval = find(cie1931xyz1nm(:,1) == max(range));

startvaltcs = find(CIETCS1nm(:,1) == min(range));
endvaltcs = find(CIETCS1nm(:,1) == max(range));

startvalts = find(testsourcespd(:,1) == min(range));
endvalts = find(testsourcespd(:,1) == max(range));

startvalref = find(referencespd(:,1) == min(range));
endvalref = find(referencespd(:,1) == max(range));

%compute object color tristimulus data for test source and reference
testXYZ= zeros(3,14);

%calculate normalization constant k for perfect diffuse reflector of source
ktest = 100./sum(testsourcespd(startvalts:endvalts,end).*cie1931xyz1nm(startval:endval,3));
kreference = 100./sum(referencespd(startvalts:endvalts,end).*cie1931xyz1nm(startval:endval,3));

for j=1:3
    for i=1:14 %all 14 samples in CIETCS1nm
        testXYZ(j,i) = ktest.*sum(CIETCS1nm(startvaltcs:endvaltcs,i+1).*cie1931xyz1nm(startval:endval,j+1).*testsourcespd(startvalts:endvalts,end));
        i = i + 1;
    end
    j = j + 1;
end

referenceXYZ = zeros(3,14);
for j=1:3
    for i=1:14 %all 14 samples in CIETCS1nm
        referenceXYZ(j,i) = kreference.*sum(CIETCS1nm(startvaltcs:endvaltcs,i+1).*cie1931xyz1nm(startval:endval,j+1).*referencespd(startvalref:endvalref,end));
        i = i + 1;
    end
    j = j + 1;
end

%reformat spds for functions
testXYZ = testXYZ';
referenceXYZ = referenceXYZ';

%calculate chromaticity coordinates first is xy, then convert to uv
testxyzsamples = getxyz(testXYZ);
referencexyzsamples = getxyz(referenceXYZ);

uvtestsamples = xytouv(testxyzsamples);
uvreferencesamples = xytouv(referencexyzsamples);

%apply von Kries chromatic adaptation
%first calculate c and d for both sources
%this requires calculating the chromaticity in uv for the test source and
%reference source

uvtestsource = xytouv(getxyz(gettristimulus2degn(testsourcespd,range)));
%make sure yvtestsource is last sample (full spd)
uvtestsource = uvtestsource(end,:);

uvreferencesource = xytouv(getxyz(gettristimulus2degn(referencespd,range)));

%convert that last sample to [c_ref d_ref] and [c_test d_ref]
cdtestsource = uvtocd(uvtestsource);
cdreferencesource = uvtocd(uvreferencesource);

%convert TCS samples illuminated by test light to [c_test_i d_test_i]
cdtestsamples = uvtocd(uvtestsamples);

%apply chromatic transform 
% c_rt = cdreferencesource(:,1)/cdtestsource(:,1);
% d_rt = cdreferencesource(:,2)/cdtestsource(:,2);
% 
% uc_num = 10.872+(.404*c_rt.*cdtestsamples(:,1))-(4*d_rt.*cdtestsamples(:,2));
% uc_den = 16.518+(1.481*c_rt.*cdtestsamples(:,1))-(d_rt.*cdtestsamples(:,2));
% uc = uc_num./uc_den;
% 
% vc_num = 5.520;
% vc_den = 16.518+(1.481*c_rt.*cdtestsamples(:,1))-(d_rt.*cdtestsamples(:,2));
% 
% vc = vc_num./vc_den;

% uc_num = 10.872+(.404* cdreferencesource(:,1))-(4*cdreferencesource(:,2));
% uc_den = 16.518+(1.481* cdreferencesource(:,1))-(cdreferencesource(:,2));

uc = (10.872+.404.*(cdreferencesource(:,1)./cdtestsource(:,1)).*cdtestsamples(:,1)-4.*(cdreferencesource(:,2)./cdtestsource(:,2)).*cdtestsamples(:,2))...
    ./(16.518+1.481.*(cdreferencesource(:,1)./cdtestsource(:,1)).*cdtestsamples(:,1)-(cdreferencesource(:,2)./cdtestsource(:,2)).*cdtestsamples(:,2));

vc = 5.520./(16.518+1.481.*(cdreferencesource(:,1)./cdtestsource(:,1)).*cdtestsamples(:,1)-(cdreferencesource(:,2)./cdtestsource(:,2)).*cdtestsamples(:,2));

%create chromatically adapted uv matrix
uvc = horzcat(uc,vc);

%move uv coordinates into CIE1964 UVW color space

% %calculate Luv for object colors
% Wtestcr = 116.*((testXYZ(:,2)./100).^(1/3))-16;
% Utestcr = 13.*Wtestcr.*(uvtestsamples(:,1)-uvreferencesource(:,1));
% Vtestcr = 13.*Wtestcr.*(uvtestsamples(:,2)-uvreferencesource(:,2));
% UVWtestcr = horzcat(Utestcr,Vtestcr,Wtestcr);
% 
% %calculate Luv for reference illumant object colors
% Wref = 116.*((testXYZ(:,2)./100).^(1/3))-16;
% Uref = 13.*Wref.*(uvreferencesamples(:,1)-uvreferencesource(:,1));
% Vref = 13.*Wref.*(uvreferencesamples(:,2)-uvreferencesource(:,2));
% UVWref = horzcat(Uref,Vref,Wref);

%calculate UVW for chromatically adapted object colors
Wtestcr = 25.*(testXYZ(:,2).^(1/3))-17;
Utestcr = 13.*Wtestcr.*(uvc(:,1)-uvreferencesource(:,1));
Vtestcr = 13.*Wtestcr.*(uvc(:,2)-uvreferencesource(:,2));
UVWtestcr = horzcat(Utestcr,Vtestcr,Wtestcr);

%calculate UVW for reference illumance object colors
Wref = 25.*(referenceXYZ(:,2).^(1/3))-17;
Uref = 13.*Wref.*(uvreferencesamples(:,1)-uvreferencesource(:,1));
Vref = 13.*Wref.*(uvreferencesamples(:,2)-uvreferencesource(:,2));
UVWref = horzcat(Uref,Vref,Wref);

deltaE = sqrt((UVWtestcr(:,1)-UVWref(:,1)).^2+(UVWtestcr(:,2)-UVWref(:,2)).^2+(UVWtestcr(:,3)-UVWref(:,3)).^2);
R = 100-(4.6.*deltaE);
RAll = R;
Ra = mean(R);
% Ytest
% Ztest

% % compute delta uv of reference and test
% duvRef = bsxfun(@minus,uvreferencesamples,uvreferencesource);
% duvTest = bsxfun(@minus,uvtestsamples,uvtestsource);

% Teunissen's gamut area in transformed uv:
% compute areas of sample 1-8 polygons
% gRef = polyarea(duvRef([1:8],1),duvRef([1:8],2));
% gTest = polyarea(duvTest([1:8],1),duvTest([1:8],2));
gRef = polyarea(uvreferencesamples([1:8],1),uvreferencesamples([1:8],2));
gTest = polyarea(uvc([1:8],1),uvc([1:8],2));

% this makes no difference
% gRef = polyarea(uvreferencesamples([1:8],1),uvreferencesamples([1:8],2));
% gTest = polyarea(uvtestsamples([1:8],1),uvtestsamples([1:8],2));

% Teunissen gamut area
Ga = 100 * gTest ./ gRef;

% uv gamut
uvRef = uvreferencesamples;
uvTest = uvc;

% compute normalized transformed uv gamut polygons
duvRef = (uvRef - repmat(uvreferencesource,14,1)) .* repmat([1 1.5],14,1);
duvTest = (uvTest - repmat(uvreferencesource,14,1)) .* repmat([1 1.5],14,1);
cRef = sqrt(sum(duvRef.^2,2));
polyRef = duvRef ./ repmat(cRef,1,2);
polyTest = duvTest ./ repmat(cRef,1,2);

%keyboard
