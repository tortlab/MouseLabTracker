function varargout = loadv(name, mode)
% loadv var_name [:normal | :lock | :unlock]

    if nargin < 3
        mode = 'normal';
    end
    
    handles = loadhandles();
    fig = handles.figure1;
    
    switch mode
        case 'normal'
            varargout{1} = getappdata(fig, name);
            
        case 'lock'
            lock_name = [name '__lock__'];
        
            if isappdata(fig, lock_name)
                lock = getappdata(fig, lock_name);
            else
                lock = java.util.concurrent.Semaphore(1);
                setappdata(fig, lock_name, lock);
            end
            
            if lock.tryAcquire()
                varargout{1} = getappdata(fig, name);
                varargout{2} = true;
            else
                varargout{1} = [];
                varargout{2} = false;
            end
            
        otherwise
            error(['get_var: Unknown mode ' mode]);
    end
end        
