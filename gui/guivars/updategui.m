function updategui()

    h = loadhandles();
    s = loadv('settings__');
    video_obj = loadv('video_obj');
    video_player = loadv('video_player');

    set(h.videoNameText, 'String', video_obj.name);

    if ~isempty(s.arena_upper_left)
        set(h.text25, 'String', sprintf('Upper left: (%d, %d)', ...
                                        s.arena_upper_left(1), s.arena_upper_left(2)));
    else
        set(h.text25, 'String', 'Upper left: <undefined>');
    end

    if ~isempty(s.arena_lower_right)
        set(h.text33, 'String', sprintf('Lower right: (%d, %d)', ...
                                        s.arena_lower_right(1), s.arena_lower_right(2)));
    else
        set(h.text33, 'String', 'Lower right: <undefined>');
    end

    set(h.animalsNumberInput, 'String', num2str(s.number_subjects));
    set(h.animalsRadiusInput, 'String', num2str(s.radius));

    if s.subject_is_white
        set(h.lightAnimalsButton, 'Value', 1);
        set(h.darkAnimalsButton, 'Value', 0);
    else
        set(h.lightAnimalsButton, 'Value', 0);
        set(h.darkAnimalsButton, 'Value', 1);
    end


    start_time = double(s.start_frame) / video_player.fps;
    set(h.videoStartText, 'String', ['Start: ' time2str(start_time)]);

    end_time = double(s.end_frame) / video_player.fps;
    set(h.videoEndText, 'String', ['End: ' time2str(end_time)]);
    set(h.sceneColorAxes, 'Color', [s.threshold s.threshold s.threshold]);

    if s.estimate_lost_positions
        set(h.checkbox1, 'Value', 1);
    else
        set(h.checkbox1, 'Value', 0);
    end

    if ~isempty(video_obj) && ~isempty(video_player)
        set(h.videoNameText, 'String', video_obj.name);
        set(h.speedText, 'String', sprintf('%dx', video_player.speed));
        set(h.videoSizeText, 'String', ...
            sprintf('Size: %dx%d', video_obj.width, video_obj.height));
        set(h.videoFramesText, 'String', ...
            sprintf('%d frames, %dfps', video_obj.numberofframes, video_obj.framerate));
        
        video_player.jump(video_player.currentFrameIndex);
    end
end
