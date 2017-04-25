function mjmDMXclose( h )
% mjmDMXinit: close/end DMX control via USB/Serial such as DMXKing
% MJMurdoch 20160921 Happy birthday Kathy
%
% Input: 
%   h        handle of the Serial object that was opened

% close the serial object
fclose( h );

