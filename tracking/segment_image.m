function frame = segment_image(frame, object_is_white, threshold)
% SEGMENT_IMAGE Separate the background and foreground (objects) of the frame

if ~object_is_white
    frame = 255 - frame;
    threshold = 1 - threshold;
end

frame = im2bw(frame, threshold) * 255; 
end
