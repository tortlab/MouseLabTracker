function frame_f = draw_scene_f(video_player, button_down_f)

scene_panel = guiobj('right_video_panel');
scene_axes = axes(...
    'Parent', scene_panel,...
    'Visible', 'off',...
    'DataAspectRatio', [1 1 1],...
    'DrawMode', 'fast',...
    'XLimMode', 'manual',...
    'XLim', [1 video_player.width],...
    'YLimMode','manual',...
    'YLim', [1 video_player.height],...
    'Units', 'normalized',...
    'Position', [0 0 1 1],...
    'YDir','reverse');

scene_image = image(...
    'Parent', scene_axes, ...
    'CData', []);

set(scene_image, 'ButtonDownFcn', ...
    {button_down_f scene_axes});

savev('scene_axes', scene_axes);

function get(video_player, event)
    frame = video_player.currentFrame;
    frame_ind = video_player.currentFrameIndex;
    width = video_player.width;
    height = video_player.height;
    
    is_white = setting('subject_is_white');
    threshold = setting('threshold');
    radius = setting('radius');
    upper_left = setting('arena_upper_left');
    lower_right = setting('arena_lower_right');
    excluded_areas = setting('excluded_areas');
    
    tracking_state = loadv('tracking_state');
    
    if isempty(threshold)
        return;
    end
    
    bw_frame = segment_image(frame, is_white, threshold);
    
    frame(:, :, 1) = bw_frame;
    frame(:, :, 2) = bw_frame;
    frame(:, :, 3) = bw_frame;
    
    if ~isempty(upper_left) && ~isempty(lower_right)
        frame = draw_alpha_rect(frame, upper_left, lower_right, ...
                                Constants.SceneFrameColor);
    end
    
    frame = draw_excluded_areas(frame, excluded_areas, Constants.ExcludedAreaColor);
    
    if isempty(tracking_state)
        frame = draw_circle(frame, radius, ...
                            int32(width/2), int32(height/2), ...
                            Constants.CircleOnVideoColors(1, :));
    elseif setting('start_frame') <= frame_ind && frame_ind <= setting('end_frame')
        frame = draw_on_subjects(frame, frame_ind, tracking_state);
    end
    
    set(scene_image, 'CData', frame);
end

frame_f = @get;
end


function frame = draw_on_subjects(frame, frame_ind, tracking_state)
    for object = 1 : setting('number_subjects')
        pos_i = frame_ind - setting('start_frame') + 1;
        ind = max(0, round(pos_i));
        
        position = tracking_state.positions(ind, :, object);
        radius = tracking_state.radius_progress(ind, 1, object);
        
        if radius == setting('radius')
            color = Constants.CircleOnVideoColors(object, :);
        else
            color = Constants.LostSubjectColor;
        end;
        
        frame = draw_circle(frame, radius, position(1), position(2), color);
    end
end


function frame = draw_excluded_areas(frame, areas, color)
    for i = 1:size(areas, 1)
        frame = draw_rect(frame, areas(i, 1, :), areas(i, 2, :), color);
    end
end
