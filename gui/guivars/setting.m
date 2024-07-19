function value = setting(varargin)
% setting :refresh
% setting :all
% setting var_name [var_value]
% setting :reset video_obj

    settings = loadv('settings__');
    name = varargin{1};

    if nargin == 1
        switch name
            case ':refresh'
                settings_refresh();
                updategui();
            
            case ':all'
                value = settings;
            
            otherwise
                value = settings.(name);
        end
    elseif nargin == 2
        switch name
            case ':reset'
                settings_reset(varargin{2});
                
            case ':all'
                savev('settings__', varargin{2});
             
            otherwise
                settings = settings_set(settings, name, varargin{2});
                savev('settings__', settings);
        end
        
        updategui();
    end
end


function settings_reset(video_obj)
    settings = [];

    settings.video_name = '';
    settings.arena_upper_left = [1 1];
    settings.arena_lower_right = [video_obj.width video_obj.height];
    settings.excluded_areas = [];
    settings.number_subjects = 1;
    settings.subject_is_white = true;
    settings.radius = 15;
    settings.initial_positions = zeros(0, 2);
    settings.start_frame = 1;
    settings.end_frame = video_obj.NumberOfFrames;
    settings.threshold = 0.5;
    settings.estimate_lost_positions = true;
    
    savev('settings__', settings);
end


function settings_refresh()
    function is_white = subject_is_white()
        value = get(guiobj('lightAnimalsButton'), 'Value');
        is_white = (value == get(guiobj('lightAnimalsButton'), 'Max'));
    end

    function is_estimated = is_result_estimated()
        value = get(guiobj('checkbox1'), 'Value');
        is_estimated = (value == get(guiobj('checkbox1'), 'Max'));
    end

    settings = loadv('settings__');

    settings.subject_is_white = subject_is_white();   
    settings.estimate_lost_positions = is_result_estimated();
   
    settings.number_subjects = ...
        str2double(get(guiobj('animalsNumberInput'), 'String')); 
    settings.radius = ...
        str2double(get(guiobj('animalsRadiusInput'), 'String'));

    savev('settings__', settings);
end



function settings = settings_set(settings, name, value)
    switch name
        case 'video_name'
            ok = ischar(value);
            
        case {'arena_upper_left', 'arena_lower_right'}
            ok = is_2d_point(value) || isempty(value);

        case 'excluded_areas'
            ok = is_rect_list(value);
            
        case {'number_subjects', 'radius', 'start_frame', 'end_frame'}
            ok = is_natural(value);

        case {'subject_is_white', 'estimate_lost_positions'}
            ok = islogical(value);

        case 'initial_positions'
            ok = is_list_points(value);

        case 'threshold'
            ok = is_threshold(value);
            
        % Ignored settings
        case 'total_count'
            ok = true;
            
        otherwise
            error(['Unknown setting: ' name]);
    end

    if ok
        settings.(name) = value;
    else
        error(['Invalid value for setting ' name]);
    end
end

function b = is_2d_point(p)
    b = (length(p) == 2 && is_natural(p, true));
end

function b = is_rect_list(ps)
    b = true;
    for i = 1:size(ps,1)
        p1 = ps(i, 1, :);
        p2 = ps(i, 2, :);
        
        p1 = p1(:);
        p2 = p2(:);
        
        b = b && is_2d_point(p1) && is_2d_point(p2);
    end
end

function b = is_threshold(n)
    b = (0 <= n && n <= 255);
end

function b = is_list_points(m)
    b = true;
    for i = 1:size(m, 1)
        p = m(i, :);
        p = p(:);
        b = b && is_2d_point(p);
    end
end

function is_nat = is_natural(m, has_zero)

if nargin == 1 || ~has_zero
    lim = 1;
else
    lim = 0;
end

is_nat = all(m == round(m)) && all(m >= lim);
end
