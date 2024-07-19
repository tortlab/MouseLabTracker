function [frame buf_video] = read(buf_video, frame_ind)
% BUFFEREDVIDEO/GET_FRAME

if ~isscalar(frame_ind)
    st_frame = frame_ind(1);
    ed_frame = frame_ind(2);
    frame = zeros(buf_video.Height, buf_video.Width, 3, ed_frame-st_frame+1);
    
    for i = st_frame:ed_frame
        [frame(:, :, :, i) buf_video] = BufferedVideo.read(buf_video, i);
    end

    return
end
    
if isnan(buf_video.start) || isnan(buf_video.end) || ...
   frame_ind < buf_video.start || frame_ind > buf_video.end
    window = Constants.BufferedVideoWindow;
    buf_video.start = frame_ind;
    buf_video.end = min(frame_ind+window-1, buf_video.NumberOfFrames);
    buf_video.buffer = read(buf_video.video, [buf_video.start, buf_video.end]);
end

buf_ind = frame_ind - buf_video.start + 1;
frame = buf_video.buffer(:, :, :, buf_ind);
end
