function url = composeUrl( parts )
%composeUrl Compose a URL from the input argument strings
% Works like FULLFILE but with "/" and always appends a "/" at the end.
%
%   url = composeUrl(urlPart1, ..., urlPartN)
%
% Example:
%
%  composeUrl("https://insectbraindb.org", "app", "forum")
%  -> returns "https://insectbraindb.org/app/forum/"

arguments (Repeating)
    parts (1,1) string
end

url = strjoin(string(parts), "/");

url = append(url, "/");

% replace duplicate slashes with a single slash
url = regexprep(url, "/+", "/");

% preserve double slashes for protocol specifiers such as "https://"
url = regexprep(url, ":/", "://");

end
