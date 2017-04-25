function msgOut = mjmDMXsend( h, data )
% mjmDMXsend: send DMX data via USB/Serial such as DMXKing
% API from ENTTEC DMX USB Pro Widget API Specification 1.44
%
% MJMurdoch 20160921 Happy birthday Kathy
%
% Input: 
%   h        handle of the Serial object that was opened
%   data     Nx1 uint8 vector of values to be sent via DMX. Index of 
%            data is the DMX address (thus N<512 or Universe Size)
%            Note: other data types will be cast to uint8 regardless
%
% Output:
%   msgOut   Nx1 hex values of the full message sent via DMX (including 
%            start/end/label codes), useful for debugging

if nargin < 2
    error([ mfilename ' requires two input arguments']);
end

% cast wrong datatype to uint8 (no effs given)
if ~isa( data, 'uint8' )
    data = uint8(data);
end

% DMX Enttec constants
msgStart = uint8(hex2dec('7E'));
msgEnd = uint8(hex2dec('E7'));
msgLabelSendPacket = uint8(6);
% msgLabelGetSN = uint8(10);
% msgLabelGetParameters = uint8(3);
dmxStartCode = uint8(0); % DMX start code included in message size

% infer Universe Size from data length
data = data(:);
universeSize = length(data);

% message to DMX
sizeLSB = uint8( mod( (universeSize+1), 256 ));
sizeMSB = uint8( floor( (universeSize+1) / 256 ));
msg = [ msgStart msgLabelSendPacket sizeLSB sizeMSB dmxStartCode data' msgEnd ];
%fprintf(dd,'%s\n', msg)
fwrite( h, msg, 'uint8' );

if nargout > 0
    msgOut = dec2hex(uint8(msg));
end




