function progress = calculate_progress(frame_ind, mode)

if nargin == 1
    mode = 'normal';
end

old_time = loadv('progress_old_time');
old_frame_ind = loadv('progress_old_frame_ind');

elapsed_time = loadv('progress_elapsed_time');
if isempty(elapsed_time) || frame_ind == 1
    elapsed_time = 0;
end

switch mode
    case 'pause'
        time = toc();
        elapsed_time = elapsed_time + (time - old_time);
        savev('progress_elapsed_time', elapsed_time);
        return;
    
    case 'restart'
        tic();
        old_time = toc();
        savev('progress_old_time', old_time);
        return;
end

% Normal mode

frame_mod = Constants.DisplayFrameRate;

st_frame = setting('start_frame');
end_frame = setting('end_frame');
frame_tot = end_frame - st_frame + 1;

if frame_ind == 1 || (~isempty(old_frame_ind) && frame_ind <= old_frame_ind)
    tic();
    old_time = toc();
    progress = [];
elseif frame_ind == frame_tot || ~mod(frame_ind, frame_mod)
    time = toc();
    
    progress = [];
    progress.completed = double(frame_ind) / double(frame_tot);
    progress.completed_pct = round(progress.completed * 100);
    
    progress.current_fps = frame_mod / (time - old_time);
    progress.average_fps = frame_ind / time;
    progress.seconds_left = (frame_tot - frame_ind) / progress.average_fps;
    
    elapsed_time = elapsed_time + (time - old_time);
    
    try
        progress.eta = time2str(double(progress.seconds_left));
    catch ex %#ok<NASGU>
        progress.eta = 'calculating...';
    end
    
    status_msg = sprintf('%3d%% (frame %4d/%4d) %3.01ffps (avg %2.01ffps) ETA: %s', ...
                         progress.completed_pct, frame_ind, frame_tot, ...
                         progress.current_fps, progress.average_fps, ...
                         progress.eta);

    progress.status = status_msg;
    
    if frame_ind ~= frame_tot
        old_time = time;
    end
end

savev('progress_old_time', old_time);
savev('progress_old_frame_ind', frame_ind);
savev('progress_elapsed_time', elapsed_time);
end
