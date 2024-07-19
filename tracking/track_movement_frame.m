function tracking_state = track_movement_frame(frame, tracking_state)

orig_radius = setting('radius');
init_positions = setting('initial_positions');
                                           
object = tracking_state.current_object;
frame_i = tracking_state.current_frame;
radius = tracking_state.radius;
old_pos = tracking_state.pos;
count = tracking_state.count;

region = [setting('arena_upper_left'); setting('arena_lower_right')];

% Update count
tracking_state.count = count + 1;

% Updated used radius
tracking_state.radius_progress(tracking_state.count, 1, object) = radius;

% Segment the image
bw_frame = segment_image(frame, setting('subject_is_white'), setting('threshold'));

% Track the object across frames
[pos radius] = find_subject(bw_frame, old_pos, radius, orig_radius, ...
                            region, setting('excluded_areas'));
tracking_state.pos = pos;
tracking_state.radius = radius;

% Update the current frame index
tracking_state.current_frame = frame_i + 1;

% Update calculated position
tracking_state.positions(tracking_state.count, :, object) = pos;


% Update state
if tracking_state.current_frame > setting('end_frame')
    if object == setting('number_subjects')
        tracking_state.state = 'finished';
    else
        tracking_state.current_object = object + 1;
        tracking_state.current_frame = setting('start_frame');
        tracking_state.count = 0;
        tracking_state.pos = init_positions(object + 1, :);
        tracking_state.radius = orig_radius;
    end
end

end
