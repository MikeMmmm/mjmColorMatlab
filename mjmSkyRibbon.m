function varargout = mjmSkyRibbon( varargin )
% mjmSkyRibbon: control the SkyRibbon luminaires in the light lab
%
% MJMurdoch 20161005
%
% Various usages:
%
% h = mjmSkyRibbon( 'init', portName )
%     Opens a connection to the DMX controller with portName (e.g. 'COM5'
%     (PC) or '/dev/tty.usbmodem1421' (Mac/Linux)
%     Returns h, the handle of the Serial object created
%
% mjmSkyRibbon( h, 'close' )
%     Closes a connection to the DMX controller with Serial handle h
%
% msg = mjmSkyRibbon( h, data )
%     Sends data to the lights with handle h. data can take many forms:
%     Data types:
%     - uint16 numbers are sent directly to light fixtures (16-bit values
%       are split into MSB and LSB bytes on pairs of DMX addresses)
%     - double numbers (assume 0-1 range) are scaled and quantized to
%       16-bit values and sent as above
%     NOT IMPLEMENTED: - uint8 numbers are sent directly to DMX addresses, thus the user has
%       to keep track of which is MSB and which is LSB
%     Data sizes:
%     - scalar values are sent to all 5 channels of 28 light fixtures
%     - 1x5 values are sent to the 5 channels of all 28 fixtures
%     - 28x1 values are sent to all 5 channels of the 28 fixtures
%     - 28x5 values are sent to the 5 channels of 28 fixtures, respectively
%     NOT IMPLEMENTED: - NxMx5 3D arrays are interpolated to the light fixture layout: 8x6 array of
%       lights, but only a circumferential ring
%     Output msg is the 28x1 hex values of the full message sent via DMX (including 
%            start/end/label codes), useful for debugging
%

% constants
Nlights = 28;
Nchannels = 5;

if nargin < 1
    error([ mfilename ' requires at least one input argument']);
end

% string as first argument
if ischar( varargin{1} )
    switch varargin{1}
        case 'init'
            if nargin < 2
                error([ mfilename ': must specify portName as an input argument']);
            end
            
            % initialize connection
            h = mjmDMXinit(varargin{2})
            
            if nargout>0
                varargout{1} = h;
            end
            return
        
        case 'close'
            if nargin < 2
                error([ mfilename ': must specify Serial handle as an input argument']);
            end
            
            % close the connection
            mjmDMXclose( h )
            
            if nargout>0
                varargout{1} = [];
            end
            return

        otherwise
            % do nothing
    end
end

% Serial object handle as first argument: assume DMX controller
if isa( varargin{1}, 'serial' )
    % for efficiency, don't check anything, just proceed
    [r c ch] = size(varargin{2});
    if r==Nlights
        % move along
        data = varargin{2};
    elseif r==1
        % repeat to lights
        data = repmat(varargin{2},Nlights,1);
    else
        error([ mfilename ': unexpected data size.']);
    end
    if c==Nchannels
        % data is already OK
        
    elseif c==1
        % repeat to all channels
        data = repmat(data,1,Nchannels);
    else
        error([ mfilename ': unexpected data size.']);
    end
    
    if isa(data,'uint16')
        %  16-bit input, pass it through
        msg = mjmDMXsend16bit( varargin{1}, reshape(data',Nlights*Nchannels,1) );
    elseif isa( varargin{2}, 'double' )
        % double: scale and convert ti 16-bit
        % Note: uint16 handles clipping gracefully
        data = uint16(data*double(intmax('uint16')));
        msg = mjmDMXsend16bit( varargin{1}, reshape(data',Nlights*Nchannels,1) );
    else
        error([ mfilename ': unexpected datatype.']);
    end
            
    if nargout>0
        varargout{1} = msg;
    end
    
end


