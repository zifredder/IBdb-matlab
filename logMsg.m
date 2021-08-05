function logMsg(varargin)
%logMsg Prints a message starting with "--------" to the command line. Useful for
% status messages.
%
%   Usage:
%       logMsg(txt)
%       logMsg(formatSpec, A1, ..., An) % FPRINTF syntax
%
%   Examples:
%   logMsg("abc");
%       prints "--------abc"
%   logMsg(" %i + %i = %s", 1, 1, "two");
%       prints "-------- 1 + 1 = two"
%
% See also fprintf

switch nargin
    case 0,     fmt = "%s";         args = {''};
    case 1,     fmt = "%s";         args = string(varargin);
    otherwise,  fmt = varargin{1};  args = varargin(2:end);
end

% add line break if necessary
if ~endsWith(fmt, "\n")
    fmt = strcat(fmt, "\n"); end

fmt = strcat("--------", fmt);

fprintf(fmt, args{:});
end
