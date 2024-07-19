function buf_video = create(video)
% BUFFEREDVIDEO/CREATE

buf_video.buffer = zeros(video.Height, video.Width, 3, ...
                         Constants.BufferedVideoWindow);
buf_video.start = NaN;
buf_video.end = NaN;

buf_video.video = video;
buf_video.Duration = video.Duration;
buf_video.NumberOfFrames = video.NumberOfFrames;
buf_video.Width = video.Width;
buf_video.Height = video.Height;
end
