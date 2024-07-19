%%
% MouseLabTracker
%
% @author Giuliano Vilela <giulianoxt@neuro.ufrn.br>
%%



%%
% Main GUI functions
%%

function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 03-Aug-2011 08:05:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, unused, handles, varargin)
    logf('Mouselabtracker initiating');

    % Choose default command line output for main
    handles.output = hObject;

    % Update handles structure
    guidata(hObject, handles);

    setup_controls(handles);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    varargout{1} = handles.output;
    
    t = timer('Name', 'setup_shortcuts_timer', ...
              'ExecutionMode', 'fixedSpacing', 'Period', 0.1);
    t.TimerFcn = @(u1,u2) setup_shortcuts(t);
    start(t);
    
    

%%
% Custom GUI setup
%%

function setup_controls(handles) 
    global handles__;
    handles__ = handles;

    % TODO: should be part of the state transitions
    setVideoSettingsEnabled('off');
    setTrackingSettingsEnabled('off');
    setVideoControlsEnabled('off');
    
    set(guiobj('figure1'), 'WindowButtonMotionFcn', @mouse_over);
    set(guiobj('figure1'), 'DeleteFcn', @figure_delete);
    
    set_status('Open a new video file to begin tracking', 'button_info_blue');


function setup_shortcuts(timer)
    shortcut_map = Constants.KeyboardShortcuts;
    
    try
        for i = 1:length(shortcut_map)
            tag = shortcut_map{i, 1};
            key = shortcut_map{i, 2};
        
            m_handle = guiobj(tag);
            j_handle = findjobj(m_handle);
            j_handle.setMnemonic(key);
        end
    catch ex %#ok<NASGU>
        % Some handle is still invisible. Try to setMnemonic in the next timer shot
        return;
    end
    
    stop(timer);


function setAllEnabled(obj, state)
    if isfield(get(obj), 'Enable')
        set(obj, 'Enable', state);
    end

    arrayfun(@(obj) setAllEnabled(obj, state), get(obj, 'Children'));


function setVideoSettingsEnabled(state)
    setAllEnabled(guiobj('videoSettingsPanel'), state);    

    
function setVideoSliderEnabled(state)
    setAllEnabled(guiobj('left_control_panel'), state);


function setTrackingSettingsEnabled(state)
    setAllEnabled(guiobj('trackingSettingsPanel'), state);

function setVideoControlsEnabled(state)
    set(guiobj('toggleVideoButton'), 'Enable', state);
    set(guiobj('stopVideoButton'), 'Enable', state);
    setVideoSpeedControlsEnabled(state);

function setVideoSpeedControlsEnabled(state)
    set(guiobj('rewindButton'), 'Enable', state);
    set(guiobj('forwardButton'), 'Enable', state);
    set(guiobj('speedText'), 'Enable', state);
    
function setTrackingResultEnabled(state)
    set(guiobj('trackingResultsButton'), 'Enable', state);
    
    
    
%%
% Video controls callbacks
%%
    
function openVideoButton_Callback(varargin)
    [filename dirpath] = uigetfile2( ...
        '.last_open_dir.mat', ...
        {'*.avi' 'Video files (*.avi)'; '*.*' 'All files'}, ...
        'Open video');
    
    if isequal(filename, 0) || isequal(dirpath, 0)
        logf('Cancel opening video');
        return;
    end
    
    filepath = [dirpath filename];
    
    logf('Opening video. File: %s', filepath);
    
    dialog = msgbox('Please wait while Matlab opens the video', ...
                    'Open video', 'warn');
    tic;
    set(dialog, 'ButtonDownFcn', '');
                
    try
%         video_obj = mmreader(filepath);
     video_obj = VideoReader(filepath);

    catch exception
        close_handle(dialog);
        msgbox(['Error opening video file. Message: ' exception.message], ...
               'Open video', 'error');
        
        set_status('Error when opening video file', 'button_cancel_red', true);
        return;
    end
    
    video_player = VideoPlayer(guiobj('left_video_panel'), ...
                               guiobj('left_control_panel'), ...
                               guiobj('left_status_panel'), ...
                               draw_video_frame_f(video_obj), ...
                               @video_click, ...
                               video_obj);
                           
    video_player.repeat = false;
    
    draw_scene = draw_scene_f(video_player, @scene_click);
    addlistener(video_player, 'refreshed', draw_scene);

    setVideoControlsEnabled('on');
    setVideoSettingsEnabled('on');
    setTrackingSettingsEnabled('on');
    
    first_time = isempty(setting(':all'));
    
    savev('video_obj', video_obj);
    savev('video_player', video_player);
    savev('current_animal', []);
    savev('tracking_state', []);
    savev('result', []);
    
    if first_time
        setting(':reset', video_obj);
        suffix = '';
    elseif load_default_settings(dirpath)
        suffix = '. Settings loaded from default file.';
    else
        settings = setting(':all');
        [settings changed] = adjust_settings(settings);
        setting(':all', settings);
            
        if changed
            suffix = '. Settings adapted from previous video.';
        else
            suffix = '. Settings kept from previous video.';
        end
    end

    time = toc;
    close_handle(dialog);
    
    msg = ['Video opened. Time: ' time2str(time) suffix];
    set_status(msg, 'button_ok_green', true);


function toggleVideoButton_Callback(varargin)
    tracking_state = loadv('tracking_state');

    if isempty(tracking_state) || strcmp(tracking_state.state, 'finished') || ...
            strcmp(tracking_state.state, 'stopped')
        video_player = loadv('video_player');
    
        if video_player.playing
            video_player.toggle();
        else
            video_player.play();
        end
    else
        savev('toggle_message', true);
    end


function forwardButton_Callback(varargin)
    video_player = loadv('video_player');
    cur_speed = video_player.speed;
    
    if cur_speed == Constants.VideoSpeedLimit
        msgbox('Video speed limit reached', 'Video speed', 'error');
        logf('Video speed limit reached');
        return;
    end
    
    if cur_speed == -1
        video_player.speed = 1;
    else
        video_player.speed = cur_speed + 1;
    end

    updategui();
    logf('Video playing speed increased');


function rewindButton_Callback(varargin)
    video_player = loadv('video_player');
    cur_speed = video_player.speed;
    
    if cur_speed == -Constants.VideoSpeedLimit
        msgbox('Video speed limit reached.', 'Video speed', 'error');
        logf('Video speed limit reached');
        return;
    end
    
    if cur_speed == 1
        video_player.speed = -1;
    else
        video_player.speed = cur_speed - 1;
    end
    
    updategui();
    logf('Video playing speed decreased');


function stopVideoButton_Callback(varargin)
    tracking_state = loadv('tracking_state');
    
    if isempty(tracking_state) || strcmp(tracking_state.state, 'finished')
        video_player = loadv('video_player');
        video_player.stop();
    else
        savev('stop_message', true);
    end



%%
% Video settings callbacks
%%

function videoSetStartButton_Callback(varargin)
    video_player = loadv('video_player');
    setting('start_frame', video_player.currentFrameIndex);
    
    set_status('Video start time changed', 'button_ok_green', true);
 

function videoSetEndButton_Callback(varargin)
    video_player = loadv('video_player');
    setting('end_frame', video_player.currentFrameIndex);

    set_status('Video end time changed', 'button_ok_green', true);



%%
% General menu callbacks
%%

function about_menu_Callback(hObject, eventdata, handles)
    about()

function exit_menu_Callback(hObject, eventdata, handles)
    close_handle(guiobj('figure1'));

function file_menu_Callback(hObject, eventdata, handles)
    
function preferences_menu_Callback(hObject, eventdata, handles)

function help_menu_Callback(hObject, eventdata, handles)

function pushbutton6_Callback(hObject, eventdata, handles)



%% 
% Save and load settings
%%

function [settings changed] = adjust_settings(settings)
    changed = false;
    video_obj = loadv('video_obj');
    
    if settings.start_frame > video_obj.numberOfFrames
        settings.start_frame = video_obj.numberOfFrames;
        changed = true;
    end
    
    if settings.end_frame > video_obj.numberOfFrames
        settings.end_frame = video_obj.numberOfFrames;
        changed = true;
    end
    
    orig_ul = settings.arena_upper_left;
    orig_lr = settings.arena_lower_right;
    video_lr = [video_obj.width video_obj.height];
    
    ul = min(orig_ul, video_lr);
    lr = min(orig_lr, video_lr);
    
    if any(ul ~= orig_ul) || any(lr ~= orig_lr)
        changed = true;
    end
    
    settings.arena_upper_left = ul;
    settings.arena_lower_right = lr;


function ok = load_default_settings(settingsDir)
    ok = false;

    try
        filepath = [settingsDir 'settings.mat'];
        load(filepath);

        if exist('settings', 'var')
            use_new_settings(settings);
            ok = true;
        end
    catch ex %#ok<NASGU>
    end


function use_new_settings(settings)
    [settings changed] = adjust_settings(settings);
    setting(':all', settings);
    
    if changed
        set_status(['Settings have been loaded. Some parameters ' ...
                    'were adjusted to this video'], 'warning');
    else
        set_status('Settings successfully opened', 'button_ok_green');
    end


function open_settings_menu_Callback(hObject, eventdata, handles)
    [filename dirpath] = uigetfile2( ...
        '.last_settings_dir.mat', 'settings.mat', 'Open settings');

    if isequal(filename, 0) || isequal(dirpath, 0)
        return;
    end

    filepath = [dirpath filename];
    load(filepath);

    if exist('settings', 'var')
        use_new_settings(settings);
        logf('Settings have been loaded. File: %s', filepath);
    end


function save_settings_menu_Callback(hObject, eventdata, handles)
    settings = setting(':all'); %#ok<NASGU>

    [filename dirpath] = uiputfile2(...
        '.last_settings_dir.mat', 'settings.mat', 'Save settings');
           
    if ~(isequal(filename, 0) || isequal(dirpath, 0))
        filepath = [dirpath filename];
        save(filepath, 'settings');
        set_status('Settings successfully saved', 'button_ok_green');
        logf('Settings saved to file %s', filepath);
    end


function reset_settings_menu_Callback(hObject, eventdata, handles)
    video_obj = loadv('video_obj');
    setting(':reset', video_obj);
    set_status('Settings successfully reset', 'button_ok_green', true);



%%
% Weird compatibility routines generated by GUIDE
%%

function frameSkipInput_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), ...
                       get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function videoContrastSlider_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

function videoBrightnessSlider_CreateFcn(hObject, eventdata, handles)
    if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor',[.9 .9 .9]);
    end

function animalsNumberInput_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

function animalsRadiusInput_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end



%%
% Tracking callbacks
%%

function startTrackingButton_Callback(varargin)
    logf('Starting tracking process. Waiting for initial positions');

    % TODO: Should be part of the state transitions
    setVideoControlsEnabled('off');
    setVideoSettingsEnabled('off');
    setTrackingSettingsEnabled('off');
    
    video_player = loadv('video_player');
    video_player.pause();
    
    % Tracks which animal is being selected to define its initial position
    savev('current_animal', 1);
    
    % The user will select the positions from the first tracked frame
    start_frame = setting('start_frame');
    video_player.jump(start_frame);
    
    set_status('Select the initial position for subject 1', 'button_info_blue');


function trackingResultsButton_Callback(varargin)
    result = loadv('result');

    if isempty(result)
        msgbox('You need to track first.', 'Save results', 'error');
        return;
    end
    
    dialog = loadv('tracking_done_dialog');
    if ishandle(dialog)
        close(dialog);
    end 
    
    if setting('estimate_lost_positions')
        result = estimate_movement(result); %#ok<NASGU>
    end
    
    video_obj = loadv('video_obj');
    [u1 video_name u2] = fileparts(video_obj.name);
    default_name = ['result_' video_name '.mat'];
    
    [filename dirpath] = uiputfile2(...
        '.last_save_dir.mat', default_name, 'Save results');
    
    if ~(isequal(filename, 0) || isequal(dirpath, 0))
        filepath = [dirpath filename];
        save(filepath, 'result');
        set_status('Results successfully saved', 'button_ok_green');
        logf('Results saved to file %s', filepath);
    end


function sceneColorButton_Callback(varargin)
    old_c = get(guiobj('sceneColorAxes'), 'Color');
    new_c = uisetcolor(old_c, 'Select the threshold color (grayscale)');
    
    % Should be in [0,1]
    threshold = mean(new_c);
    
    if any(threshold ~= new_c)
        set_status('The selected color will be converted to grayscale', 'warning');
    else
        set_status('Threshold color successfully changed', 'button_ok_green');
    end
    
    setting('threshold', threshold);
    logf('New threshold: %.03f', threshold);


function paintArenaButton_Callback(varargin)
    % Should be a state transition
    savev('painting', true);
    
    savev('ex_upper_left', []);
    set_status('Select the upper left point of the excluded area', ...
               'button_info_blue');
           
    logf('Start excluding a portion of the arena. Waiting for positions');


function setSceneAreaButton_Callback(varargin)
    set_status('Select the upper left point of the arena', ...
               'button_info_blue');

    setting('arena_upper_left', []);
    setting('arena_lower_right', []);
    setting('excluded_areas', []);
    savev('select_arena', true);
    
    logf('Start setting the arena points. Waiting for positions');



%%
% Mouse callbacks
%%

function mouse_over(unused1, unused2)
    if loadv('select_arena')
        axes = loadv('video_axes');
    elseif ~isempty(loadv('current_animal'))
        axes = loadv('video_axes');
    elseif loadv('painting')
        axes = loadv('scene_axes');
    else
        % fast path for the common case
        return;
    end
    
    video_obj = loadv('video_obj');
    point = get(axes, 'CurrentPoint');
    xy = round(point(1, [1 2]));
    
    statusStr = get(guiobj('statusText'), 'String');
    pos = strfind(statusStr, '|');
    
    if isempty(pos)
        pos = length(statusStr);
    else
        pos = pos - 2;
    end
    
    if any(xy > [video_obj.width video_obj.height]) || any(xy < [1 1])
        statusStr = statusStr(1:pos);
    else
        statusStr = sprintf('%s | Position: (%d, %d)', ...
                            statusStr(1:pos), xy(1), xy(2));
    end
    
    set(guiobj('statusText'), 'String', statusStr);


function video_click(unused1, unused2, axes)
    point = get(axes, 'CurrentPoint');
    xy = round(point(1, [1 2]));

    upper_left = setting('arena_upper_left');
    lower_right = setting('arena_lower_right');
    
    if isempty(upper_left)
        setting('arena_upper_left', xy);
        set_status('Select the lower right point of the arena', ...
                   'button_info_blue');
            
        logf('Arena upper left set to (%d, %d)', xy(1), xy(2));
        return;
    elseif isempty(lower_right)
        setting('arena_lower_right', xy);
        logf('Arena lower right set to (%d, %d)', xy(1), xy(2));
        
        set_status('Arena points successfully selected', 'button_ok_green', true);
        savev('select_arena', false);
        
        return;
    end
    
    current_animal = loadv('current_animal');
    num_subjects = setting('number_subjects');
    init_positions = setting('initial_positions');
    
    % Should be a state check
    if isempty(current_animal)
        return
    end
       
    init_positions(current_animal, :) = xy;
    current_animal = current_animal + 1;

    savev('current_animal', current_animal);
    setting('initial_positions', init_positions);
    
    logf('Set initial position for subject %d to (%d, %d)', ...
        current_animal-1, xy(1), xy(2));

    if current_animal > num_subjects
        savev('current_animal', []);
        track();
    else
        set_status(['Select the initial position for subject ' ...
                   int2str(current_animal)], 'button_info_blue');
    end


function scene_click(unused1, unused2, axes)
    point = get(axes, 'CurrentPoint');
    xy = round(point(1, [1 2]));

    if loadv('painting')
        set_excluded_point(xy);
    elseif ~isempty(loadv('tracking_state'))
        savev('click_message', xy);
    end


function set_excluded_point(xy)
    ex_upper_left = loadv('ex_upper_left');

    if isempty(ex_upper_left)
        savev('ex_upper_left', xy);
        
        logf('Set the upper left point of the new excluded area to (%d, %d)', ...
            xy(1), xy(2));
        
        set_status('Select the lower right point of the excluded area', ...
                   'button_info_blue');
    else
        ex_lower_right = xy;
        ex_areas = setting('excluded_areas');
        
        if isempty(ex_areas)
            ex_areas = zeros(0, 2, 2);
        end
        
        sz = size(ex_areas, 1);
        ex_areas(sz+1, 1, :) = ex_upper_left;
        ex_areas(sz+1, 2, :) = ex_lower_right;
        
        logf('Set the upper left point of the new excluded area to (%d, %d)', ...
            xy(1), xy(2));
        
        num_rect = sz+1;
        if num_rect == 1
            logf('There is now %d excluded rectangle from the scene', num_rect);
        else
            logf('There are now %d excluded rectangles from the scene', num_rect);
        end
        
        savev('painting', []);
        setting('excluded_areas', ex_areas);
    
        set_status('Excluded area successfully selected', 'button_ok_green');
    end



%%
% Tracking functions
%%


function track()
    video_player = loadv('video_player');
    video_player.pause();
    
    tracking_start();
    
    % This busy loop looks strange since the event loop also runs
    % in this thread, but the Matlab interpreter stops matlab code to
    % run the java event loop internally so everything runs ok.
    %
    % Using timers proved to be a worse solution, with concurrency bugs.
    while tracking_tick()
    end
    
    tracking_end();


function tracking_start()
    % Update settings
    setting :refresh;

    % Frame source
    video_obj = loadv('video_obj');
    buf_video = BufferedVideo.create(video_obj);
    savev('buf_video', buf_video);
    
    init_positions = setting('initial_positions');
    start_f = setting('start_frame');
    end_f = setting('end_frame');
    total_count = end_f - start_f + 1;
    
    % Initial tracking state
    tracking_state.state = 'running';
    tracking_state.current_object = 1;
    tracking_state.current_frame = setting('start_frame');
    tracking_state.count = 0;
    tracking_state.pos = init_positions(1, :);
    tracking_state.radius = setting('radius');
    tracking_state.positions = zeros(total_count, 2, setting('number_subjects'));
    tracking_state.radius_progress = zeros(total_count, 1, setting('number_subjects'));
    
    % Save the main tracking variables
    savev('tracking_state', tracking_state);
    
    % Update GUI visibility (should be a state transition)
    setVideoControlsEnabled('on');
    setVideoSpeedControlsEnabled('off');
    setVideoSliderEnabled('off');
    setVideoSettingsEnabled('off');
    setTrackingSettingsEnabled('off');
    setTrackingResultEnabled('off');

    % Prepare for video rewinds during tracking
    video_player = loadv('video_player');
    addlistener(video_player, 'refreshed', @(u1, u2) savev('move_message', true));
    
    logf('Tracking started');


function tracking_toggle()
    video_player = loadv('video_player');
    tracking_state = loadv('tracking_state');
    
    switch tracking_state.state
        case 'running'
            tracking_state.state = 'paused';
            calculate_progress(0, 'pause');

            if video_player.currentFrameIndex ~= tracking_state.current_frame-1
                video_player.jump(tracking_state.current_frame-1);
            end

            setVideoSliderEnabled('on');

            subject = tracking_state.current_object;
            set_status(['Tracking paused. You may set a new position for ' ...
                        'subject ' int2str(subject)], 'pause_blue', true);

        case 'paused'
            tracking_state.state = 'running';
            calculate_progress(0, 'restart');
            
            setVideoSliderEnabled('off');
            set_status('Tracking restarted', 'gear_gray', true);
    end
    
    savev('tracking_state', tracking_state);


function tracking_stop()
    tracking_state = loadv('tracking_state');
    tracking_state.state = 'stopped';
    savev('tracking_state', tracking_state);
    
    set_status('Tracking stopped', 'ball_red', true);


function continue_ = tracking_tick()
    if loadv('toggle_message')
        savev('toggle_message', false);
        tracking_toggle();
    elseif loadv('stop_message')
        savev('stop_message', false);
        tracking_stop();
    elseif loadv('move_message')
        savev('move_message', false);
        tracking_move();
    elseif loadv('click_message')
        xy = loadv('click_message');
        savev('click_message', []);
        tracking_click(xy);
    end

    buf_video = loadv('buf_video');
    video_player = loadv('video_player');
    tracking_state = loadv('tracking_state');
    
    if strcmp(tracking_state.state, 'stopped')
        savev('tracking_state', []);
        setVideoControlsEnabled('on');
        setVideoSliderEnabled('on');
        setVideoSettingsEnabled('on');
        setTrackingSettingsEnabled('on');

        continue_ = false;
    elseif strcmp(tracking_state.state, 'paused')
        drawnow();
        continue_ = true;
    else
        assert(strcmp(tracking_state.state, 'running'), 'State should be running');

        % Read a frame from the buffered video
        frame_i = tracking_state.current_frame;
        [frame buf_video] = BufferedVideo.read(buf_video, frame_i);

        % Track the object across frames
        tracking_state = track_movement_frame(frame, tracking_state);

        % Save vars
        savev('buf_video', buf_video);
        savev('tracking_state', tracking_state);

        % Display progress
        count = tracking_state.count;
        if count == 1 || ~mod(count, Constants.DisplayTrackingFrameRate)
            progress = calculate_progress(count);

            if isempty(progress)
                status = 'Calculating...';
            else
                status = progress.status;
            end

            video_player.jump(frame_i);
            set_status(['Tracking: ' status], 'gear_gray');
            drawnow();
        end

        % Check to see if the tracking is finished
        continue_ = ~strcmp(tracking_state.state, 'finished');
    end
        
    savev('tracking_state', tracking_state);


% Change the subject position on the fly
function tracking_click(xy)
    tracking_state = loadv('tracking_state');
    video_player = loadv('video_player');
    
    if isempty(tracking_state) || ~strcmp(tracking_state.state, 'paused')
        return;
    end
    
    object = tracking_state.current_object;
    count = tracking_state.count;
    tracking_state.positions(count, :, object) = xy;
    tracking_state.pos = xy;

    savev('tracking_state', tracking_state);
    
    % draw on scene
    video_player.jump(tracking_state.current_frame-1);
    savev('move_message', false);
    
    logf('Changed position of subject %d to (%d, %d)', object, xy(1), xy(2));


% Rewind the video to re-track a section
function tracking_move()
    tracking_state = loadv('tracking_state');
    video_player = loadv('video_player');
    
    if isempty(tracking_state) || ~strcmp(tracking_state.state, 'paused')
        return;
    end
    
    frame_ind = video_player.currentFrameIndex;
    start_frame = setting('start_frame');
    end_frame = setting('end_frame');
    
    backtrack = false;
    if frame_ind < start_frame || frame_ind > end_frame
        set_status('The selected position is outside the defined tracking boundaries.', ...
                   'ball_red');
        backtrack = true;
    elseif frame_ind > tracking_state.current_frame
        set_status('The selected position is after the current tracking position.', ...
                   'ball_red');
        backtrack = true;
    end

    if backtrack
        video_player.jump(tracking_state.current_frame-1);
        return;
    end

    object = tracking_state.current_object;
    number_objects = setting('number_subjects');
    count = ceil(frame_ind - start_frame + 1) - 1;
    
    tracking_state.current_frame = frame_ind;
    tracking_state.count = count;  
    
    if count == 0
        init_positions = setting('initial_positions');
        tracking_state.pos = init_positions(object, :);
        tracking_state.radius = setting('radius');
    else
        tracking_state.pos = tracking_state.positions(count, :, object);
        tracking_state.radius = tracking_state.radius_progress(count, 1, number_objects);
    end

    savev('tracking_state', tracking_state);
    logf('Rewind tracking to frame %d', frame_ind);


function tracking_end()
    video_obj = loadv('video_obj');
    tracking_state = loadv('tracking_state');
    elapsed_time = loadv('progress_elapsed_time');

    setVideoControlsEnabled('on');
    setVideoSliderEnabled('on');
    setVideoSettingsEnabled('on');
    setTrackingSettingsEnabled('on');
    setTrackingResultEnabled('on');
    
    if strcmp(tracking_state.state, 'finished')
        result = setting(':all');
        result.video_name = video_obj.name;
        result.duration = video_obj.duration;
        result.frame_rate = video_obj.framerate;
        result.positions = tracking_state.positions;
        result.radius_progress = tracking_state.radius_progress;
        savev('result', result);
        
        play_sound('tracking_finished');
        
        msg = ['Tracking done. Elapsed time: ' time2str(elapsed_time)];
        set_status(msg, 'button_info_blue', true);

        dialog = msgbox(msg, 'Video processing', 'help');
        savev('tracking_done_dialog', dialog);
    end

    video_player = loadv('video_player');
    video_player.jump(setting('start_frame'));



%%
% Update scene when parameters change
%%
  
function update_tracking_settings()
    setting :refresh;
    
    % redraw
    video_player = loadv('video_player');
    if ~isempty(video_player)
        video_player.jump(video_player.currentFrameIndex);
    end
    
    logf('Updated tracking settings');


function uipanel7_SelectionChangeFcn(hObject, eventdata, handles)
    update_tracking_settings();

    
function checkbox1_Callback(hObject, eventdata, handles)
    update_tracking_settings();


function animalsNumberInput_Callback(hObject, eventdata, handles)
    str = get(hObject, 'String');
    value = str2double(str);
    
    if ~isnan(value) && value == round(value)
        update_tracking_settings();
    end


function animalsRadiusInput_Callback(hObject, eventdata, handles)
    str = get(hObject, 'String');
    value = str2double(str);
    
    if ~isnan(value) && value == round(value)
        update_tracking_settings();
    end



%%
% Notifications
%%

function set_status(message, icon_name, log_message)
    set(guiobj('statusText'), 'String', message);
    
    filename = sprintf('gui/icons/%s.png', icon_name);
    background_color = get(guiobj('figure1'), 'Color');

    icon_img = imread(filename, 'BackgroundColor', background_color);
    imshow(icon_img, 'Parent', guiobj('statusAxes'));

    if nargin == 3 && log_message
        logf(message);
    end


%%
% Cleanup functions
%%
    
function close_handle(handle)
    close(handle(ishandle(handle)));


function figure_delete(varargin)
    logf('Exit');
