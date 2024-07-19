function logf(varargin)
    message = sprintf(varargin{1}, varargin{2:end});
    str = ['[' datestr(now(), 'HH:MM:SS') '] ' message];
    disp(str);
end
