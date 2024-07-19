function frame_f = draw_video_frame_f(video)
%VIDEO_FRAME_F

function fr = get(i)
    fr = read(video, i);
end

frame_f = @get;
end
