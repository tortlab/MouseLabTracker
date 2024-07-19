function savev(name, value, mode)
% savev var_name [:normal | :lock | :unlock]

    if nargin < 4
        mode = 'normal';
    end
    
    handles = loadhandles();
    fig = handles.figure1;
    
    switch mode
        case 'normal'
            setappdata(fig, name, value);
        
        case 'unlock'
            lock_name = [name '__lock__'];
            assert(isappdata(fig, lock_name));
            lock = getappdata(fig, lock_name);
            
            setappdata(fig, name, value);
            lock.release();
            
        otherwise
            error(['set_var: Unknown mode ' mode]);
    end
end
