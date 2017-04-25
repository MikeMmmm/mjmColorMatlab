function h = mjmDMXinit(portID)
% mjmDMXinit: initialize DMX control via USB/Serial such as DMXKing
% MJMurdoch 20160921 Happy birthday Kathy
%
% Input: 
%   portID   name of the serial port (PC) or device path (Mac/Linux),
%            for example 'COM5' (PC) or '/dev/tty.usbmodem1421' (Mac/Linux)
%
% Output:
%   h        handle of the Serial object that was opened


if nargin < 1
    if ispc
        error('Must provide serial port ID on Windows')
    else
        a = instrfind('Type','serial');
        % guess it was the last entry in a
        portID = a(end).Port;
        %error('Please specify device ID; the above output of instrfind might be useful!');
    end 
end

% % DMX Enttec constants
% msgStart = uint8(hex2dec('7E'));
% msgEnd = uint8(hex2dec('E7'));
% msgLabelSendPacket = uint8(6);
% msgLabelGetSN = uint8(10);
% msgLabelGetParameters = uint8(3);

% connect the DMXKing
h = serial(portID,'BaudRate',9600,'InputBufferSize',8192);
fopen(h);

% time delay when needed (ask Dave Wyble)
dT = 0.1;
pause(dT);


