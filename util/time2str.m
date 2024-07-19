function str = time2str(seconds)
    str = datestr(seconds / (24*3600), 'HH:MM:SS');
end
