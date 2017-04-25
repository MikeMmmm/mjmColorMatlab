function msgOut = mjmDMXsend16bit( h, data )
% mjmDMXsend: send 16-bit DMX data via USB/Serial such as DMXKing
% API from ENTTEC DMX USB Pro Widget API Specification 1.44
%
% MJMurdoch 20160921 Happy birthday Kathy
%
% Input: 
%   h        handle of the Serial object that was opened
%   data     Nx1 vector of values to be sent via DMX. 
%            -uint16 values will be split into two DMX channels each, 
%               first coarse (MSByte), second fine (LSByte).
%            -double precision values (assumed 0-1 range float) will
%               be scaled up to 2^16-1 and then treated as uint16 above.
%
% Output:
%   msgOut   N*2x1 hex values of the full message sent via DMX (including 
%            start/end/label codes), useful for debugging

if nargin < 2
    error([ mfilename ' requires two input arguments']);
end

% convert float values to uint16 
%  (WEIRD STUFF might happen if data not double or uint16...)
if ~isinteger( data )
    data = uint16( data / intmax('uint16') );
end

% split 16-bit values into two bytes each
data = data(:);
data8 = [ bitshift(data(:)',-8); mod(data(:)',256) ];

% send 8-bit values to DMX
msg = mjmDMXsend( h, data8(:) );

if nargout > 0
    msgOut = msg;
end




