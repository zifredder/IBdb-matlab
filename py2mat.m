function var = py2mat(var)
%py2mat Converts a Python data type to a MATLAB data type. Nested data is converted
%recursively.
%
%   matVar = py2mat(pyVar);
%
% See also: doc Handle Data Returned from Python

dataType = class(var);


if ~startsWith(dataType, "py.")
    return
end


switch dataType
    
    case {'py.int', 'py.long', 'py.array.array'}
        var = double(var);
        
    case {'py.str', 'py.unicode'}
        var = string(var);
        
    case 'py.bytes'
        var = uint8(var);
        
    case 'py.NoneType'
        var = [];
        
    case 'py.dict'
        var = struct(var);
        
        fns = fieldnames(var);
        
        for j = 1:numel(fns)
            var.(fns{j}) = py2mat( var.(fns{j}) ); % oh yeah
        end
        
        
    case {'py.list', 'py.tuple'}
        var = cell(var);
        var = cellfun(@py2mat, var, 'UniformOutput', false); % oh yeah
        
        % Try to unpack cell arrays; works if all cell contents have the same type. For a
        % cell array of CHARs, this would result in concatenation to a single CHAR;
        % however, Python STRs are converted to STRING (see above), so this should (!?)
        % never happen.
        try
            var = cell2mat(var);
            
        catch ME
            if ~ismember(ME.identifier, ...
                    {'MATLAB:cell2mat:MixedDataTypes'
                    'MATLAB:cell2mat:UnsupportedCellContent'})
                ME.rethrow();
            end
        end
        
        
    otherwise
        warning(...
            "Typecasting Python type %s to a MATLAB type is not implemented.", ...
            dataType)
        
end


end
