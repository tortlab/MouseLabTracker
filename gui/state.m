function varargout = state(varargin)
% state()             # state :get
% state :new_state    # state transition
% state :updategui
% 
% state var           # get state var value
% state var value     # set state var value

    update = false;

    switch nargin
        case 0
            varargout{1} = loadv('state__');

        case 1
            arg = varargin{1};
            
            if arg(1) == ':'
                state_change(arg);
                update = true;
            else
                vars = loadv('statevars__');
                varargout{1} = vars.(arg);
            end
        
        case 2
            name = varargin{1};
            value = varargin{2};
            
            vars = loadv('statevars__');
            vars.(name) = value;
            savev('statevars__', vars);
            update = true;

        otherwise
            error('Invalid number of arguments for state');
    end

    if update
        updategui();
    end
end


function state_change(new_state)
    savev('state__', new_state);
    savev('statevars__', []);

    % Execute transiction actions
    ...
        
    % Update GGUI
    switch new_state
        case 'initial'
            ...
                
        case 'standby'
            ...
                
        otherwise
            error(['Unknown state: ' new_state]);
    end
    
    % Is this needed?
    % Is there a case where this is not desired?
    updategui();
end
