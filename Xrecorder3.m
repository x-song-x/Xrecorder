function varargout = Xrecorder3(varargin)
% Xrecorder3 is for the setup assembled in Beijing THU-NPRC & CASIA 2023.07
%   for recording calibrated sounds w/ :
%       (1) G.R.A.S. microphones:
%           46AC: High-Freq, up to 40kHz range and 20  dB(A) background and
%           40HL: Low-Noise, up to 20kHz range and 6.5 dB(A) background
%       (2) G.R.A.S. microphone amplifiers 12AA
%       (3) NI USB-4431 sound & vibration DAQ card   
%   This setup requires :
%       (1) Matlab R2023a and its NI DAQmx adaptor
%       (2) NI DAQmx v23.1.0 
%           to operate
% Xrecorder3pre2 is the version w/ the new GUI (Panelette3) and Mag
%   all pre versions are w/ the 4x4 panelettes arrangement
% Xrecorder3pre is the version w/ the old GUI (Panelette)
% Xrecorder2 would succeed Xrecorder to
%   (1) supports multi-channel recording
%       w/ additional support for Sokolich probe, 
%       besides B&K 4191+Ron's, and B&K 4189+2250
%   (2) revised and double-checked spectral analysis (ture RMS)
%   (3) recording time 1s to 60s 
%   (4) Revised plotting, w/ figure clipping support

%% For Standarized SubFunction Callback Control
if nargin==0                % INITIATION
    InitializeTASKS
elseif ischar(varargin{1})  % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)                        
            [varargout{1:nargout}] = feval(varargin{:});
                            % FEVAL switchyard, w/ output
        else
            feval(varargin{:}); 
                            % FEVAL switchyard, w/o output  
        end
    catch MException
        rethrow(MException);
    end
end

function InitializeTASKS
clear all
global rec

%% Setup GUI
% rec.UI.ColorTheme = 'norm';     %   'dark'
rec.UI.ColorTheme = 'dark';     %   'dark'
% rec.UI.M =          1.0;        %   GUI Magnification
% rec.UI.M =          1.5;        %   GUI Magnification
rec.UI.M =          2.0;        %   GUI Magnification

%% Setup Parameters
rec.FileNameHead =          'rec';
rec.FileDir =               'C:\EXPERIMENTS\SoundCalibration\';
rec.RecTime =               1;

    i = 1;
    rec.MicSysOpts(i).Name =            'GRAS_46AC';
    rec.MicSysOpts(i).SN =              '560157';
    rec.MicSysOpts(i).mVperPa =         12.54;  % 12.5 claimed
    rec.MicSysOpts(i).Enable =          1;

    i = 2;
    rec.MicSysOpts(i).Name =            'GRAS_40HL';
    rec.MicSysOpts(i).SN =              '519396';
    rec.MicSysOpts(i).mVperPa = 	    814.8;  % 850 claimed
    rec.MicSysOpts(i).Enable =          1;

    rec.Mic_OptionTable =   struct2table(rec.MicSysOpts);
    rec.Mic_OptionTipStr =  {[  '46AC is the wide-band option (up to 40kHz) \n',...
                                '40HL is the low-noise option (down to 6 dB(A))\n'  ]}; 

rec.Amp_Name =              'GRAS_12AA';
rec.Amp_SN =                '457825';
rec.Amp_InputPorts =        {   'A',        'B'     };
rec.Amp_GainStr =           {   '-20 dB',   '0 dB',     '20 dB',    '40 dB' };
rec.Amp_GainOptions =       [   -20         0,          20,         40      ];
rec.Amp_GainNum =           [   0.1         1           10          100     ];
rec.Amp_DirectMode =        {   'Direct',   'Amplifier'     ''};
rec.Amp_FilterOptions =     {   'Linear',   'HighPass',     'A-weighting'   };
rec.Amp_FilterOptNum =      1;

rec.DAQ_CardName =          'USB-4431';     % NI card device name in DAQmx
rec.DAQ_ai_ChStr =          {   'ai0',  'ai1',  'ai2',  'ai3'   }';
rec.DAQ_ai_ChOpts =         [   0       1       2       3       ];
rec.DAQ_SR =                100e3;      % Sampling rate
rec.DAQ_UR =                5;          % Update rate
rec.DAQ_DR =                10;         % Dynamic range (fixed for USB-4431)
rec.DAQ_mx_adaptor =        'matlab';   % or 'scanimage' (TBD)

i = 1;
    rec.Ch(i).Name =            rec.Amp_InputPorts{i};
    rec.Ch(i).MicOptNum =       i;
    rec.Ch(i).AmpModeOptNum =   2;
    rec.Ch(i).AmpGainOptNum =   4;
    rec.Ch(i).DAQaiChOptNum =   1;

i = 2;
    rec.Ch(i).Name =            rec.Amp_InputPorts{i};
    rec.Ch(i).MicOptNum =       i;
    rec.Ch(i).AmpModeOptNum =   2;
    rec.Ch(i).AmpGainOptNum =   3;
    rec.Ch(i).DAQaiChOptNum =   2;

%% Generate the GUI
SetupFigureRec;

%% Setup Callbacks
set(rec.UI.H.hMicSys_Checkbox(1),   'Callback',             'Xrecorder3(''GUI_CheckBox'')');
set(rec.UI.H.hMicSys_Checkbox(2),   'Callback',             'Xrecorder3(''GUI_CheckBox'')');
set(rec.UI.H.hAmpMode_PopupMenu(1), 'Callback',             'Xrecorder3(''GUI_PopupMenu'')');
set(rec.UI.H.hAmpMode_PopupMenu(2), 'Callback',             'Xrecorder3(''GUI_PopupMenu'')');
set(rec.UI.H.hAmpGain_PopupMenu(1), 'Callback',             'Xrecorder3(''GUI_PopupMenu'')');
set(rec.UI.H.hAmpGain_PopupMenu(2), 'Callback',             'Xrecorder3(''GUI_PopupMenu'')');
set(rec.UI.H.hDAQaiCh_PopupMenu(1), 'Callback',             'Xrecorder3(''GUI_PopupMenu'')');
set(rec.UI.H.hDAQaiCh_PopupMenu(2), 'Callback',             'Xrecorder3(''GUI_PopupMenu'')');

set(rec.UI.H.hRecTime_Edit,         'Callback',             'Xrecorder3(''GUI_Edit'')');
set(rec.UI.H.hFileNameHead_Edit,	'Callback',             'Xrecorder3(''GUI_Edit'')');
set(rec.UI.H.hStartStop_Rocker,     'SelectionChangeFcn',   'Xrecorder3(''GUI_Rocker'')');
set(rec.UI.H.hSave_Momentary,       'Callback',             'Xrecorder3(''RecordSave'')');
set(rec.UI.H.hPlot_Momentary,       'Callback',             'Xrecorder3(''RecordPlot'')');
set(rec.UI.H.hLoad_Momentary,       'Callback',             'Xrecorder3(''RecordLoad'')');
set(rec.UI.H.hAmpFilter_Rocker,     'SelectionChangeFcn',   'Xrecorder3(''GUI_Rocker'')');

Xrecorder3('GUI_CheckBox',  'hMicSys_Checkbox1',	rec.MicSysOpts(1).Enable);
Xrecorder3('GUI_CheckBox',  'hMicSys_Checkbox2',	rec.MicSysOpts(2).Enable);

function GUI_Edit(varargin)
    global rec 	
    %% Where the Call is from   
    if nargin == 0      % from GUI 
        tag =   get(gcbo,   'tag');
        s =     get(gcbo,   'string');
    else                % from Program
        tag =   varargin{1};
        s =     varargin{2};
    end
    %% Update D and GUI
    switch tag
        case 'hRecTime_Edit'
            t = str2double(s);
            t = round(t*10)/10;
            if t>0 && t<60
                rec.RecTime = t;
                set(rec.UI.H.hRecTime_Edit,     'string', sprintf('%5.1f',rec.RecTime));
            else
                t = rec.RecTime;
                set(rec.UI.H.hRecTime_Edit,     'string', sprintf('%5.1f',t));
                errordlg('Recording time is not within 0-60 seconds');
            end
        case 'hFileNameHead_Edit'
            try 
                rec.FileNameHead = s;
                set(rec.UI.H.hFileNameHead_Edit,'string', sprintf('%s',rec.FileNameHead));
            catch
                errordlg('Cycle Number Total input is not valid');
            end       
        otherwise
    end
	%% MSG LOG
    msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF') '\tGUI_Edit\t' tag ' updated to ' s '\r\n'];
    disp(msg);

function GUI_Rocker(varargin)
    global rec;
  	%% where the call is from      
    if nargin==0
        % called by GUI:            GUI_Rocker
        label =     get(gcbo,'Tag'); 
        val =       get(get(gcbo,'SelectedObject'),'string');
    else
        % called by general update: GUI_Rocker('hSys_LightPort_Rocker', 'Koehler')
        label =     varargin{1};
        val =       varargin{2};
    end   
    %% Update GUI
    eval(['h = rec.UI.H.', label ';'])
    hc = get(h,     'Children');
    for j = 1:3
        if strcmp( get(hc(j), 'string'), val )
            set(hc(j),	'backgroundcolor', rec.UI.C.SelectB);
            set(h,      'SelectedObject',  hc(j));
            k = j;  % for later reference
        else                
            set(hc(j),	'backgroundcolor', rec.UI.C.TextBG);
        end
    end
    %% Update D & Log
    switch label(1:end-1)
        case 'hAmpFilter_Rocke'
            switch val
                case rec.Amp_FilterOptions{1}   % Linear
                    rec.Amp_FilterOptNum = 1;
                case rec.Amp_FilterOptions{2}   % HighPass
                    rec.Amp_FilterOptNum = 2;
                case rec.Amp_FilterOptions{3}   % A-weighting
                    rec.Amp_FilterOptNum = 3;
            end
        case 'hStartStop_Rocke'       
            switch val
                case 'Start';   rec.recording = 1;  RecordStart;
                case 'Stop';    rec.recording = 0;
                otherwise
            end
            %% DO SOMETHING HERE  
        otherwise
            errordlg('Rocker tag unrecognizable!');
    end
	msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF'),'\GUI_Rocker\',label,' selected as ',val,'\r\n'];
    disp(msg);
        
function GUI_Toggle(varargin)
    global rec;
  	%% where the call is from      
    if nargin==0
        % called by GUI:            GUI_Toggle
        label =     get(gcbo,'Tag'); 
        val =       get(get(gcbo,'SelectedObject'),'string');
    else
        % called by general update: GUI_Toggle('hSys_LightSource_Toggle', 'Blue')
        label =     varargin{1};
        val =       varargin{2};
    end    
    %% Update GUI
    eval(['h{1} = rec.UI.H.', label(1:end-1) '1;'])
    eval(['h{2} = rec.UI.H.', label(1:end-1) '2;'])   
	hc{1}.h =   get(h{1}, 'Children');
	hc{2}.h =   get(h{2}, 'Children');
  	for i = 1:2
        for j = 1:3
            if strcmp( get(hc{i}.h(j), 'string'), val )
                set(h{i},   'SelectedObject', hc{i}.h(j) );
                set(h{3-i}, 'SelectedObject', '');
                set(hc{i}.h(j),	'backgroundcolor', rec.UI.C.SelectB);
            else                
                set(hc{i}.h(j),	'backgroundcolor', rec.UI.C.TextBG);
            end
        end
    end
	%% Update D & Log
    switch label(1:end-1)
        case 'hAmpGainA_Toggle'
            rec.Ch(1).AmpGainOptNum = find(matches(rec.Amp_GainStr, val));
        case 'hAmpGainB_Toggle'
            rec.Ch(2).AmpGainOptNum = find(matches(rec.Amp_GainStr, val));
        case 'hDAQ_AI_ChA_Toggle'
            rec.Ch(1).DAQaiChOptNum = find(matches(rec.DAQ_AI_ChStr, val));
        case 'hDAQ_AI_ChB_Toggle'
            rec.Ch(2).DAQaiChOptNum = find(matches(rec.DAQ_AI_ChStr, val));
        otherwise
            errordlg('Toggle tag unrecognizable!');
    end
	msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF'),'\GUI_Toggle\',label,' selected as ',val,'\r\n'];
    disp(msg);

function GUI_CheckBox(varargin)
    global rec;
  	%% where the call is from      
    if nargin==0
        % called by GUI:            GUI_CheckBox
        label =     get(gcbo,   'Tag'); 
        val =       get(gcbo,   'Value');
    else
        % called by general update: GUI_CheckBox('hMicSys_Checkbox', 1)
        label =     varargin{1};
        val =       varargin{2};
    end   
    %% Update GUI
    eval(['h = rec.UI.H.', label(1:end-1), '(' num2str(label(end)) ');'])
    if val
        set(h,	'BackgroundColor',      rec.UI.C.SelectB);
    else
        set(h,	'BackgroundColor',      rec.UI.C.TextBG);
    end
    %% Update D & Log
            ch = str2double(label(end));
    switch label(1:end-1)     
        case 'hMicSys_Checkbox' 
            rec.MicSysOpts(ch).Enable = val;
            if val
                set(rec.UI.H.hAmpMode_PopupMenu(ch),    'Enable',   'on');
                set(rec.UI.H.hAmpGain_PopupMenu(ch),    'Enable',   'on');
                set(rec.UI.H.hDAQaiCh_PopupMenu(ch),    'Enable',   'on');
            else
                set(rec.UI.H.hAmpMode_PopupMenu(ch),    'Enable',   'off');
                set(rec.UI.H.hAmpGain_PopupMenu(ch),    'Enable',   'off');
                set(rec.UI.H.hDAQaiCh_PopupMenu(ch),    'Enable',   'off');
            end
        otherwise
            errordlg('Rocker tag unrecognizable!');
    end
	msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF'),'\GUI_Rocker\',label,' selected as ',num2str(val),'\r\n'];
    disp(msg);
    
function GUI_PopupMenu(varargin)
    global rec;
  	%% where the call is from      
    if nargin==0
        % called by GUI:            GUI_CheckBox
        label =     get(gcbo,   'Tag'); 
        val =       get(gcbo,   'Value');
    else
        % called by general update: GUI_CheckBox('hMicSys_Checkbox', 1)
        label =     varargin{1};
        val =       varargin{2};
    end   
    %% Update GUI
    eval(['h = rec.UI.H.', label(1:end-1), '(' num2str(label(end)) ');'])
    if val
        set(h,	'BackgroundColor',      rec.UI.C.SelectB);
    else
        set(h,	'BackgroundColor',      rec.UI.C.TextBG);
    end
    %% Update D & Log
	ch = str2double(label(end));
    switch label(1:end-1)     
        case 'hAmpMode_PopupMenu' 
            rec.Ch(ch).AmpModeOptNum =  val;
        case 'hAmpGain_PopupMenu' 
            rec.Ch(ch).AmpGainOptNum =  val;
        case 'hDAQaiCh_PopupMenu' 
            rec.Ch(ch).DAQaiChOptNum =  val;
        otherwise
            errordlg('Rocker tag unrecognizable!');
    end
	msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF'),'\GUI_Rocker\',label,' selected as ',num2str(val),'\r\n'];
    disp(msg);
              
function RecordStart

    global rec
    % % check on integrity
    rec.Save = [];

    rec.Save.Mic_Enable =   [];
    rec.Save.Mic_SysNum =   [];
    rec.Save.Mic_Name =     cell(0);
    rec.Save.Mic_SN =       cell(0);
    rec.Save.Mic_mVperPa =  [];
    rec.Save.Amp_Name =     rec.Amp_Name;
    rec.Save.Amp_SN =       rec.Amp_SN;
    rec.Save.Amp_Filter =   rec.Amp_FilterOptions{rec.Amp_FilterOptNum};
    rec.Save.Amp_Mode =     cell(0);
    rec.Save.Amp_Port =     cell(0);
    rec.Save.Amp_GainNum =  [];  
    rec.Save.DAQ_Dev =      rec.DAQ_CardName;
    rec.Save.DAQ_SR =       rec.DAQ_SR;
    rec.Save.DAQ_DR =  	    rec.DAQ_DR;
    rec.Save.DAQ_aiCh =     [];  

    for i = 1:length(rec.MicSysOpts)
        % if rec.MicSysOpts(i).Enable 
        if ismember(rec.DAQ_ai_ChOpts(rec.Ch(i).DAQaiChOptNum), rec.Save.DAQ_aiCh) || ...
           isnan(   rec.DAQ_ai_ChOpts(rec.Ch(i).DAQaiChOptNum))
            errordlg('AI channels are in conflict');
            Xrecorder3('GUI_Rocker', 'hStartStop_Rocker', 'Stop');
            rec.Save =  [];
            return;
        else
            rec.Save.Mic_Enable(    end+1) = rec.MicSysOpts(i).Enable;
            rec.Save.Mic_SysNum(    end+1) = i;
            rec.Save.Mic_Name{      end+1} = rec.MicSysOpts(i).Name;
            rec.Save.Mic_SN{        end+1} = rec.MicSysOpts(i).SN;
            rec.Save.Mic_mVperPa(   end+1) = rec.MicSysOpts(i).mVperPa;
            rec.Save.Amp_Mode{      end+1} = rec.Amp_DirectMode{rec.Ch(i).AmpModeOptNum};
            rec.Save.Amp_Port{      end+1} = rec.Ch(i).Name;
            rec.Save.Amp_GainNum(   end+1) = rec.Amp_GainNum(   rec.Ch(i).AmpGainOptNum);
            rec.Save.DAQ_aiCh(      end+1) = rec.DAQ_ai_ChOpts( rec.Ch(i).DAQaiChOptNum);
        end
        % end
    end
    rec.Save.Mic_SysTotal =    length(rec.Save.Mic_SysNum);
    
    % % initiation
    rec.recordtime = 0; 
    rec.Save.Waveform = zeros(0, rec.Save.Mic_SysTotal);     

    %% NI-DAQmx implementation through the Matlab adaptor
    % disable the warning of adding clocked only channels
    ws = warning("off","daq:Session:clockedOnlyChannelsAdded");
    % restore warning state when cleared
    oc = onCleanup(@() warning(ws));
    % search for the recording device
    devall = daqlist("ni");
    for i = 1:size(devall,1)
        if strcmp(devall{i,3}, rec.DAQ_CardName)
            rec.DAQ_DeviceID = devall{i,1};
        end
    end
    % create acquisition task
    rec.DAQ_dq =        daq("ni");
    rec.DAQ_dq.Rate =   rec.DAQ_SR;
    % adding ai channels
    for i = 1:length(rec.MicSysOpts)
        rec.DAQ_dq_ch(i) = addinput(rec.DAQ_dq, rec.DAQ_DeviceID,...
            rec.DAQ_ai_ChStr{rec.Ch(i).DAQaiChOptNum}, "Voltage");
        rec.DAQ_dq_ch(i).Coupling =         'DC';   
        rec.DAQ_dq_ch(i).TerminalConfig =   'PseudoDifferential';
    end
    rec.DAQ_dq.ScansAvailableFcnCount =  rec.DAQ_SR/rec.DAQ_UR;
    rec.DAQ_dq.ScansAvailableFcn =       @RecordCallback;
    start(rec.DAQ_dq,   "Duration", seconds(rec.RecTime));   
    %% NI-DAQmx implementation through the ScanImage adaptor
    % rec.NIDAQ_D.Dev.devName =	rec.Save.DAQ_Dev;
    % T =                         [];
    % T.taskName =                'CO Trigger Task';
    % T.chan(1).deviceNames =     rec.Save.DAQ_Dev;
    % T.chan(1).chanIDs =         rec.NIDAQ_COchan;
    % T.chan(1).chanNames =       'CO Trigger Channel';
    % T.chan(1).lowTime =         0.001;
    % T.chan(1).highTime =        0.001;
    % T.chan(1).initialDelay =    0.1;
    % T.chan(1).idleState =       'DAQmx_Val_Low';
    % T.chan(1).units =           'DAQmx_Val_Seconds';
    % rec.NIDAQ_D.CO =	T;
    % 
    % T =                             [];
    % T.taskName =                    'AI SoundRec Task';
    % for i = 1:rec.Save.Mic_SysTotal
    %     T.chan(i).deviceNames =     rec.Save.DAQ_Dev;
    %     T.chan(i).chanIDs =         rec.Save.DAQ_aiCh(i);
    %     T.chan(i).chanNames =       rec.Save.Mic_Name{i};
    %     T.chan(i).minVal =         -rec.Save.DAQ_AIDR_V(i);
    %     T.chan(i).maxVal =          rec.Save.DAQ_AIDR_V(i);
    %     T.chan(i).units =           'DAQmx_Val_Volts';
    %     if rec.Save.DAQ_Dev(end) == '1'
    %         T.chan(i).terminalConfig =	'DAQmx_Val_RSE';
    %     else
    %         T.chan(i).terminalConfig =	'DAQmx_Val_Diff';
    %     end
    % end
    % T.time.rate =                   rec.Save.DAQ_SR; 
    % T.time.sampleMode =             'DAQmx_Val_ContSamps';
    % T.time.sampsPerChanToAcquire =  rec.RecTime*rec.Save.DAQ_SR;
    % T.trigger.triggerSource =       ['Ctr',num2str(rec.NIDAQ_COchan),'InternalOutput'];
    % T.trigger.triggerEdge =         'DAQmx_Val_Rising';
    % 
    % T.everyN.callbackFunc =         @RecordCallback;
    % T.everyN.everyNSamples =        round(rec.Save.DAQ_SR/rec.NIDAQ_UR);
    % T.everyN.readDataEnable =       true;
    % T.everyN.readDataTypeOption =   'Scaled';   % versus 'Native'
    % 
    % T.read.outputData =             [];
    % rec.NIDAQ_D.AI =    T;    
    % 
    % rec.NIDAQ_H =	CtrlNIDAQ('Creating',                   rec.NIDAQ_D);
    %                 CtrlNIDAQ('Commiting',  rec.NIDAQ_H,    rec.NIDAQ_D);
    % 
    % % Putting this function here is easier for callback 
	% rec.NIDAQ_H.hTask_AI.registerEveryNSamplesEvent(...
    %     rec.NIDAQ_D.AI.everyN.callbackFunc,     rec.NIDAQ_D.AI.everyN.everyNSamples,...
    %     rec.NIDAQ_D.AI.everyN.readDataEnable,   rec.NIDAQ_D.AI.everyN.readDataTypeOption);
    %                 pause(0.2);
    %                 CtrlNIDAQ('Starting',	rec.NIDAQ_H,    rec.NIDAQ_D); 

function RecordPlot
    global rec t
            
    %% Calculate the SPL, temporal & spectral, using data in "rec.Save"
    
    % Temporal
    L = length(rec.Save.Waveform);
    t_mV_AmpOut =	rec.Save.Waveform*1000;                             % (mV)@ MicAmplifier output, @ defined DR
    t_mV_AmpIn =    t_mV_AmpOut* 0;
    t_Pa_Mic =      t_mV_AmpOut* 0;
    for i = 1:length(rec.Save.Mic_SysNum)
        t_mV_AmpIn(:,i) =   t_mV_AmpOut(:,i)/rec.Save.Amp_GainNum(i);	% (mV)@ MicAmplifier input 
        t_Pa_Mic(:,i) = 	t_mV_AmpIn( :,i)/rec.Save.Mic_mVperPa(i);	% (Pascal)@ Mic
    end
    t_PaAC_Mic =        t_Pa_Mic - ones(L,1)* mean(t_Pa_Mic);           % (Pascal[AC}) @ mic
    tTot_PaACrms_Mic =	sqrt(mean(t_PaAC_Mic.^2));                      % (Pascal[ACrms])@ Mic  
    tTot_dBSPL_Mic = 	20*log10(tTot_PaACrms_Mic   /20e-6);            % (dB SPL)@ Mic, 20uPa[rms] = 0 dB SPL, or
                                                                        %                1  Pa[rms] = 94dB SPL (93.9794) 
    % Spectral
    s_Parms_Mic_FL =	abs(fft(t_PaAC_Mic)/L)/sqrt(2);                 % (Pascal[rms]/freq bin), fft needs /L, and rms needs abs()/sqrt(2)
    s_Parms_Mic =       s_Parms_Mic_FL(1:(floor(L/2)+1),:);             % (Pascal[rms]/freq bin), Nyquist Sampling (not full but half length)
	s_Parms_Mic(2:ceil(L/2),:) = s_Parms_Mic(2:ceil(L/2),:)*2;          % (Pascal[rms]/freq bin), Combining power of conjugated frequencies  
    s_dBSPL_Mic =       20*log10(s_Parms_Mic        /20e-6);            % (dB SPL)@ Mic, 20uPa[rms] = 0 dB SPL, or
                                                                        %                1  Pa[rms] = 94dB SPL (93.9794) 
    sTot_dBSPL_Mic = 	10*log10(sum((s_Parms_Mic   /20e-6).^2));       % (dB SPL)@ Mic, Total

        N =                 length(s_dBSPL_Mic);                        % number of Nyquist freq number
        rec.Plot.s_Freq =	( (0:(N-1))*rec.Save.DAQ_SR/L )';               % Frequecies (Nyquist sampling)
        % combined for dB SPL/Hz when t is interger seconds but >0
        if (L/rec.Save.DAQ_SR - round(L/rec.Save.DAQ_SR))==0    % interger seconds
            Ss = round(L/rec.Save.DAQ_SR);
            rec.Plot.s_Freq1Hz = (1:( (N-1)*rec.Save.DAQ_SR/L ))'; 
            s_Parms_Mic_RS = reshape(s_Parms_Mic(2:end,:), Ss, length(rec.Plot.s_Freq1Hz), length(rec.Save.Mic_SysNum));
            s_dBSPL1Hz_Mic = 10*log10( sum(s_Parms_Mic_RS.^2,1)/20e-6^2 );
            s_dBSPL1Hz_Mic = permute(s_dBSPL1Hz_Mic, [2 3 1]);
        end
        % compensate for Mic response
        rec.Plot.s_dBSPL_comp =      s_dBSPL_Mic;
        rec.Plot.s_dBSPL1Hz_comp =   s_dBSPL1Hz_Mic;
        for i = 1:length(rec.Save.Mic_SysNum)
            % eval([  'rec.MicSysOpts(i).CaliChart = CaliChart_',...
            %         replace(rec.Save.Mic_Name{i}, '-', '_') ';']);
            eval([  'rec.MicSysOpts(i).CaliChart = CaliChart_', rec.Save.Mic_Name{i}, ';']);
            t.MicCV{i} =    interp1(rec.MicSysOpts(i).CaliChart.Freq, ...
                                    rec.MicSysOpts(i).CaliChart.FreeField,...
                                    rec.Plot.s_Freq, ...
                                    'spline', 0);
            t.MicCV1Hz{i} = interp1(rec.MicSysOpts(i).CaliChart.Freq, ...
                                    rec.MicSysOpts(i).CaliChart.FreeField,...
                                    rec.Plot.s_Freq1Hz, ...
                                    'spline', 0);
            rec.Plot.s_dBSPL_comp(   :,i) = rec.Plot.s_dBSPL_comp(   :,i) - t.MicCV{i};
            rec.Plot.s_dBSPL1Hz_comp(:,i) = rec.Plot.s_dBSPL1Hz_comp(:,i) - t.MicCV1Hz{i};
            s_Parms_Mic_comp(:,i) = s_Parms_Mic(:,i)./(10.^(t.MicCV{i}/20));
        end
        t.s_Parms_Mic = s_Parms_Mic;
    if max(abs(tTot_dBSPL_Mic - sTot_dBSPL_Mic))<0.001            % double check the SPL calculation
        disp(['the total acoutic power is ',num2str(tTot_dBSPL_Mic),' dB SPL']);
    else
        disp('what''s the hell?');
    end
    
    % ERB weighted  
    rec.Marmoset.AudiogramFreq = 1000*[...
        0.1250	0.2500	0.5000	1.0000	2.0000	4.0000	6.0000	7.0000	8.0000	10.0000	12.0000 16.0000 32.0000 36.0000 ];
    rec.Marmoset.AudiogramLevel = [...
        51.2000 36.4250 26.5250 18.1250 21.2750 18.9500 10.7750 6.8875  10.5500 14.1000 17.5250 20.1500 27.8500 39.0500 ];

    rec.Marmoset.ERB_Freq = [...
        250     500     1000    7000    16000];
    rec.Marmoset.ERBraw = [...
        90.97   126.85  180.51  460.83  2282.71];
    
    s_FreqERB =     250*2.^(0:0.05:6);
    s_ERB =         interp1(rec.Marmoset.ERB_Freq, rec.Marmoset.ERBraw, s_FreqERB,'spline');
    s_ERB_dbspl =   zeros(length(s_ERB), rec.Save.Mic_SysTotal);
    for i = 1: length(s_FreqERB)
        ERBmin = s_FreqERB(i) - 0.5*s_ERB(i);
        ERBmax = s_FreqERB(i) + 0.5*s_ERB(i);
        binmin = find(rec.Plot.s_Freq>ERBmin,1);
        binmax = find(rec.Plot.s_Freq>ERBmax,1) -1;
        s_ERB_dbspl(i,:) = 10*log10( sum((s_Parms_Mic_comp(binmin:binmax,:)/20e-6).^2)); 
    end
    
	%% Figure
    t.FigurePosition =      [   0.1*2560 0.1*1440 ...
                                [0.15*2560 0.4*1440]*rec.UI.M   ];
    t.FigureFontSize =      9*rec.UI.M;
    
    t.AxesSideLeft =        0.12;
    t.AxesSideRight =      	0.12;
    t.AxesWidth =           1 - t.AxesSideLeft - t.AxesSideRight;
    t.AxesHeightT =         0.2;
    t.AxesHeightSpace =     0.05;
    t.AxesHeightS =         0.62;
    t.AxesHeightStart =     0.08;
    
    t.AxesTempYMax =        1;
    t.AxesTempYLim =        1.1;
    t.AxesTempXLabel =      'Time (in second)';
    t.AxesTempXLabelV =     'Bottom';
    t.AxesTempYLabel =      {'Amplitude','(norm.)'};
    t.AxesTempYLabelV =     'Middle';
    t.LineTempYMaxColor =   [   1       0       0];
    t.AxesTempLegLocation = 'Southeast';   
    t.AxesTempLegLocation = 'Northeast';   
    t.AxesTempLegLocation = 'Best';   
%     t.LineTempWaveColor =   [   0,      0.447,   0.741;
%                             	0.8500, 0.3250, 0.0980;
%                                 0.9290, 0.6940, 0.1250  ];
    % t.LineRawDataSubColor = [   0.00*[1 1 1];
    %                             0.35*[1 1 1];
    %                             0.70*[1 1 1]    ];
    t.LineRawDataSubColor = [   0.00*[1 1 1];
                                0.60*[1 1 1];       ];
    t.AxesSpecYTick =       -60:20:100;
    t.AxesSpecXLim =        [50 rec.Save.DAQ_SR/2];
    t.AxesSpecYLim =        [-60 100];
    t.LineSpecAudiogLineWidth = 1.0;
    t.AxesSpecXLabel =      'Frequency (in Hz)';
    t.AxesSpecXLabelV =   	'Middle';
    t.AxesSpecYLabel1 =   	'Sound Pressure Level Density (dB SPL/Hz)';
    t.AxesSpecYLabel1V =   	'Baseline';
    t.AxesSpecYLabel2 =   	'Sound Pressure Level (dB SPL)';
    t.AxesSpecYLabel2V =   	'Middle';
    t.AxesSpecLegText =     {   'Noise floor density (in dB SPL/Hz)',...
                                'Marmoset audiogram (in dB SPL)',...
                                'Marmoset ERB weighted noise (in dB SPL)'};
    t.AxesSpecLegLocation = 'Northeast';    
%     t.LineSpecNoiseRColor = [   0       0.447   0.741];
    t.LineSpecAudiogColor = [   1       0       0];
%     t.LineSpecAudiogColor = [0.6350, 0.0780, 0.1840];
    t.LineSpecNoiseEColor = [   0       1       0];  
    t.LineSpecEqNoiseBaseColorRGB =	[0.4660, 0.6740, 0.1880];   
    t.LineSpecEqNoiseBaseColorHSV =	rgb2hsv( t.LineSpecEqNoiseBaseColorRGB);
%     t.LineSpecEqNoiseSubColor(1,:) = hsv2rgb(min(1,t.LineSpecEqNoiseBaseColorHSV.*[1 0.8 0.8]));
%     t.LineSpecEqNoiseSubColor(2,:) = hsv2rgb(min(1,t.LineSpecEqNoiseBaseColorHSV.*[1 1.1 1.1]));
%     t.LineSpecEqNoiseSubColor(3,:) = hsv2rgb(min(1,t.LineSpecEqNoiseBaseColorHSV.*[1 1.4 1.4]));

    % t.LineSpecEqNoiseSubColor(1,:) = hsv2rgb(min(1,t.LineSpecEqNoiseBaseColorHSV.*[1 1.0 0.9]));
    % t.LineSpecEqNoiseSubColor(2,:) = hsv2rgb(min(1,t.LineSpecEqNoiseBaseColorHSV.*[1 1.2 1.1]));
    % t.LineSpecEqNoiseSubColor(3,:) = hsv2rgb(min(1,t.LineSpecEqNoiseBaseColorHSV.*[1 1.4 1.3]));
    t.LineSpecEqNoiseSubColor(1,:) = hsv2rgb(min(1,t.LineSpecEqNoiseBaseColorHSV.*[1 0.8 0.8]));
    t.LineSpecEqNoiseSubColor(2,:) = hsv2rgb(min(1,t.LineSpecEqNoiseBaseColorHSV.*[1 1.3 1.3]));
    
    % Figure
    figure( 'units',                'pixel',...
            'position',             t.FigurePosition,...
            'Color',                [1 1 1]);
    warning('off',                  'all');
    % Temporal Waveform    
    rec.UI.H.hAT = axes(...
            'Position',             [t.AxesSideLeft,    t.AxesHeightStart+t.AxesHeightS+t.AxesHeightSpace,...
                                    t.AxesWidth,        t.AxesHeightT],...
            'FontSize',             t.FigureFontSize,...
            'Toolbar',              [],...
            'NextPlot',             'add');
    j = 1;
    rec.UI.H.hPtemp = [];
    t.MicNames = {};
	for i = 1:rec.Save.Mic_SysTotal
        if rec.Save.Mic_Enable(i)
        rec.UI.H.hPtemp(j) = ...
        plot(rec.Save.Waveform(:,i)/rec.Save.DAQ_DR,...
            'LineWidth',            0.50*rec.UI.M,...
            'Color',                t.LineRawDataSubColor(rec.Save.Mic_SysNum(i),:));
        t.MicNames{j} = replace(rec.Save.Mic_Name{i}, '_', '-');
        j = j + 1;
        end
	end
    set(gca,...
            'Xtick',                [1 L],...
            'XTickLabels',          {'0', num2str(L/rec.Save.DAQ_SR)},...
            'XLim',                 [1, L],...
            'Box',                  'on');
	xlabel(t.AxesTempXLabel,...
            'FontSize',             t.FigureFontSize,...
            'VerticalAlignment',	t.AxesTempXLabelV,...
            'Interactions',         []);
    
    % Dynamic Range Max/Min lines
    plot(1:L,   +t.AxesTempYMax*ones(1,L),...
            'LineWidth',            0.75*rec.UI.M,...
            'Color',                t.LineTempYMaxColor);
    plot(1:L,   -t.AxesTempYMax*ones(1,L),...
            'LineWidth',            0.75*rec.UI.M,...
            'Color',                t.LineTempYMaxColor);
	set(gca,...        
            'Ytick',                [- t.AxesTempYMax  t.AxesTempYMax],...
            'YLim',                 [-t.AxesTempYLim,    t.AxesTempYLim],...
            'YTickLabels',          {'DR-', 'DR+'});
	ylabel(t.AxesTempYLabel,...
        	'FontSize',             t.FigureFontSize,...
            'VerticalAlignment', 	t.AxesTempYLabelV,...
            'Interactions',         []);
    % rec.UI.H.hPtemp
	legend( rec.UI.H.hPtemp, t.MicNames,...
            'Location',             t.AxesTempLegLocation,...
            'Box',                  'off');
    if isfield(rec.Save, 'filename')
        title(rec.UI.H.hAT,         rec.Save.filename,...
            'Interpreter',          'none');
    end    

    % Spectrum
    rec.UI.H.hAS = axes(...
            'Position',             [t.AxesSideLeft,    t.AxesHeightStart,...
                                    t.AxesWidth,        t.AxesHeightS],...
            'FontSize',             t.FigureFontSize,...
            'Toolbar',              [],...
            'NextPlot',             'add');
    j = 1;
	for i = 1:rec.Save.Mic_SysTotal
        if rec.Save.Mic_Enable(i)
%         plot(rec.Plot.s_Freq, rec.Plot.s_dBSPL_comp(:,i),...
%             'Color',                t.LineRawDataSubColor(rec.Save.Mic_SysNum(i),:));    % t.LineSpecNoiseRColor); 
        plot(rec.Plot.s_Freq1Hz, rec.Plot.s_dBSPL1Hz_comp(:,i),...
            'LineWidth',            0.1*rec.UI.M,...
            'Color',                t.LineRawDataSubColor(rec.Save.Mic_SysNum(i),:));    % t.LineSpecNoiseRColor);
        j = j + 1;
        end
	end
    set(gca,...
            'Xlim',                 t.AxesSpecXLim,...
            'YTick',                t.AxesSpecYTick,...
            'Ylim',                 t.AxesSpecYLim,...
            'XGrid',              	'on',...
            'YGrid',              	'on',...
            'XScale',               'log');  
    % Marmoset audiogram
    plot(rec.Marmoset.AudiogramFreq, rec.Marmoset.AudiogramLevel,...
            'Color',            	t.LineSpecAudiogColor,...
            'LineWidth',            t.LineSpecAudiogLineWidth);
    % Marmoset ERB weighted noise
    rec.curve.Freq =    s_FreqERB;
    rec.curve.dBSPL =   s_ERB_dbspl;
    disp(['max peak on the ERB weighted level is ', num2str(max(rec.curve.dBSPL)), ' dB SPL']);
    j = 1;
    rec.UI.H.hPerb = [];
    for i = 1:rec.Save.Mic_SysTotal
        if rec.Save.Mic_Enable(i)
            rec.UI.H.hPerb(j) = plot(s_FreqERB, s_ERB_dbspl(:,i),...
            'LineWidth',            0.75*rec.UI.M,...
            'Color',             	t.LineSpecEqNoiseSubColor(rec.Save.Mic_SysNum(i),:));
            j = j + 1;
        end
    end
	legend( rec.UI.H.hPerb, t.MicNames,...
            'Location',             t.AxesTempLegLocation,...
            'Box',                  'off');
    % Spectrum more
	xlabel(t.AxesSpecXLabel,...
           	'FontSize',             t.FigureFontSize,...
            'UserData',             'SpecXLabel',...
            'ButtonDownFcn',        'Xrecorder3(''FigureClip'')',...
            'VerticalAlignment', 	t.AxesSpecXLabelV,...
            'Interactions',         []);
	ylabel(t.AxesSpecYLabel1,...
         	'FontSize',             t.FigureFontSize,...
            'VerticalAlignment', 	t.AxesSpecYLabel1V,...
            'Interactions',         []);
	if rec.Save.Mic_SysTotal == 1
        legend( t.AxesSpecLegText,...
            'Location',             t.AxesSpecLegLocation,...
            'Box',                  'off');
	end
    axes(   'Position',             [t.AxesSideLeft,    t.AxesHeightStart,...
                                    t.AxesWidth,        t.AxesHeightS],...
            'Color',                'none',...
            'FontSize',             t.FigureFontSize,...
            'Toolbar',              [],...
            'XAxisLocation',        'Top',...
            'YAxisLocation',        'Right',...
            'XTick',                [],...
            'YTick',                t.AxesSpecYTick,...
            'Ylim',                 t.AxesSpecYLim);
	ylabel(t.AxesSpecYLabel2,...
         	'FontSize',             t.FigureFontSize,...
            'VerticalAlignment', 	t.AxesSpecYLabel2V,...
            'Interactions',         []);
        
    warning('on', 'all');

function RecordSave
    global rec
    
    waveformS = rec.Save.Waveform;
    waveformS = waveformS/rec.Save.DAQ_DR*(2^(24-1)-1);
    waveformS = int32(waveformS);

    ds = char(datetime('now','Format','yyyy-MM-dd_HHmmss'));
    tt = [...
        'Mic_SysTotal: ',   num2str(          rec.Save.Mic_SysTotal),   '; ',...
        'Mic_SysNum: ',     sprintf('%d, ',   rec.Save.Mic_SysNum),     '; ',...
        'Mic_Enable: ',     sprintf('%d, ',   rec.Save.Mic_Enable),     '; ',...
        'Mic_Name: ',       strjoin(          rec.Save.Mic_Name, ', '), '; ',...
        'Mic_SN: ',         strjoin(          rec.Save.Mic_SN, ', '),   '; ',...
        'Mic_mVperPa: ',    sprintf('%5.1f, ',rec.Save.Mic_mVperPa),    '; ',...  
        'Amp_Name: ',                         rec.Save.Amp_Name,        '; ',... 
        'Amp_SN: ',                           rec.Save.Amp_SN,          '; ',...  
        'Amp_Filter: ',                       rec.Save.Amp_Filter,      '; ',...  
        'Amp_Mode: ',       strjoin(          rec.Save.Amp_Mode, ', '), '; ',...
        'Amp_Port: ',       strjoin(          rec.Save.Amp_Port, ', '), '; ',...
        'Amp_GainNum: ',    sprintf('%5.1f, ',rec.Save.Amp_GainNum),    '; ',...
        'DAQ_Dev: ',                          rec.Save.DAQ_Dev,         '; ',...
        'DAQ_SR: ',         num2str(          rec.Save.DAQ_SR),         '; ',...
        'DAQ_DR: ',         sprintf('%4.1f, ',rec.Save.DAQ_DR),         '; ',...
        'DAQ_aiCh: ',       sprintf('%d, ',   rec.Save.DAQ_aiCh),       '; ' ];
    wholename = [ds,'_',rec.FileNameHead,'.wav'];
    audiowrite([rec.FileDir wholename], waveformS, rec.Save.DAQ_SR,...
        'BitsPerSample',    32,...
        'Artist',           'Acoustic Calibration Recording, from Xrecorder3 by Xindong Song',...
        'Title',            rec.FileNameHead,...
        'Comment',          tt);
    
function RecordLoad
    global rec t
    
    [t.filename, t.pathname] = uigetfile([rec.FileDir '*.wav']);
    t.wavefilename  = [t.pathname t.filename];
    t.info          = audioinfo(t.wavefilename);
    disp(t.info.Artist);
    t.sysinfo       = strsplit(t.info.Comment, '; ');

    rec.Save =      [];
    for i = 1:length(t.sysinfo)
        t.curstrsplts = strsplit(t.sysinfo{i}, ': ');
        switch t.curstrsplts{1}
            case 'Mic_SysTotal';rec.Save.Mic_SysTotal = str2double(t.curstrsplts{2});
            case 'Mic_SysNum';  rec.Save.Mic_SysNum =   str2double(strsplit(t.curstrsplts{2}, ', '));
            case 'Mic_Enable';  rec.Save.Mic_Enable =   str2double(strsplit(t.curstrsplts{2}, ', '));
            case 'Mic_Name';    rec.Save.Mic_Name=      strsplit(  t.curstrsplts{2}, ', ');
            case 'Mic_SN';      rec.Save.Mic_SN =       strsplit(  t.curstrsplts{2}, ', ');
            case 'Mic_mVperPa'; rec.Save.Mic_mVperPa =  str2double(strsplit(t.curstrsplts{2}, ', ')); 
            case 'Amp_Name';    rec.Save.Amp_Name =                t.curstrsplts{2};
            case 'Amp_SN';      rec.Save.Amp_SN =                  t.curstrsplts{2}; 
            case 'Amp_Filter';  rec.Save.Amp_Filter =              t.curstrsplts{2}; 
            case 'Amp_Mode';    rec.Save.Amp_Mode =     strsplit(  t.curstrsplts{2}, ', ');
            case 'Amp_Port';    rec.Save.Amp_Port =     strsplit(  t.curstrsplts{2}, ', ');
            case 'Amp_GainNum'; rec.Save.Amp_GainNum =  str2double(strsplit(t.curstrsplts{2}, ', '));
            case 'DAQ_Dev';     rec.Save.DAQ_Dev =                 t.curstrsplts{2};
            case 'DAQ_SR';      rec.Save.DAQ_SR =       str2double(t.curstrsplts{2});
            case 'DAQ_DR';      rec.Save.DAQ_DR =       str2double(t.curstrsplts{2});
            case 'DAQ_aiCh';    rec.Save.DAQ_aiCh =     str2double(strsplit(t.curstrsplts{2}, ', '));
        end
    end
    rec.Save.Mic_SysNum =   rec.Save.Mic_SysNum(    1:rec.Save.Mic_SysTotal);
    rec.Save.Mic_mVperPa =  rec.Save.Mic_mVperPa(   1:rec.Save.Mic_SysTotal);
    rec.Save.Amp_GainNum =  rec.Save.Amp_GainNum(   1:rec.Save.Mic_SysTotal);
    rec.Save.DAQ_aiCh =     rec.Save.DAQ_aiCh(      1:rec.Save.Mic_SysTotal);

    rec.Save.filename =     t.filename;

	[   waveformS,   rec.Save.DAQ_SR] = audioread(t.wavefilename, 'native');
        waveformS = double(waveformS);
        waveformS = waveformS/(2^(24-1)-1)*rec.Save.DAQ_DR;
    rec.Save.Waveform =  waveformS;
                    RecordPlot;

function RecordCallback(obj,evnt)
    global rec
    
    % Time maintainence
    rec.recordtime = rec.recordtime + 1/rec.DAQ_UR;    
    set(rec.UI.H.hRecTime_Edit, 'string', sprintf('%5.1f', rec.recordtime));
    if rec.recordtime >= rec.RecTime-0.05
        GUI_Rocker('hStartStop_Rocker', 'Stop');
    end
    
    % Read data
    switch rec.DAQ_mx_adaptor
        case 'matlab'
            data = read(obj, obj.ScansAvailableFcnCount,"OutputFormat","Matrix");
            if rec.recording == 0
                stop(obj);
            end
        case 'scanimage'
            data = evnt.data;
            if rec.recording == 0
                CtrlNIDAQ('Deleting',	rec.NIDAQ_H);
            end
    end
    rec.Save.Waveform = [rec.Save.Waveform; data];
    if rec.recording == 0
        RecordPlot;
    end
    

function SetupFigureRec
global rec
%% GUI Setup
    S.dark.BG =     	[   0       0       0];
    S.dark.HL =         [   0       0       0];
    S.dark.FG =     	[   0.6     0.6     0.6];    
    S.dark.TextBG  =    [   0.25    0.25    0.25];
    S.dark.SelectB =    [   0       0       0.35];
    S.dark.SelectT =    [   0       0       0.35];

    S.norm.BG =         [   0.8     0.8     0.8];
    S.norm.HL =         [   1       1       1];  
    S.norm.FG =         [   0       0       0];
    S.norm.TextBG =     [   0.94    0.94    0.94];
    S.norm.SelectB =    [   0.74    0.84    0.94];
    S.norm.SelectT =    [   0.18    0.57   	0.77];

switch rec.UI.ColorTheme
    case 'dark';    rec.UI.C = S.dark;
    case 'norm';    rec.UI.C = S.norm;
end
    SC = rec.UI.C;

% Screen Size
S.MonitorPositions = get(0,'MonitorPositions');

S.M =   rec.UI.M;   % Magnification
% Global Spacer Scale
S.SP =  10;         % Panelettes Side Spacer
S.S =   2;          % Small Spacer 

% Panelettes Scale
S.PanelettesWidth = 100;         S.PanelettesHeight = 150;    
S.PanelettesTitle = 18;
S.PanelettesRowNum = 2;  S.PanelettesColumnNum = 5;

% Control Panel Scale 
S.PanelCtrlWidth =  S.PanelettesColumnNum *(S.PanelettesWidth+S.S) + 2*(2*S.S);
S.PanelCtrlHeight = S.PanelettesRowNum *(S.PanelettesHeight+S.S) + S.PanelettesTitle;

% Figure Scale
S.FigWidth = S.PanelCtrlWidth + 2*S.SP;
S.FigHeight = S.PanelCtrlHeight + 2*S.SP;
S.FigCurrentW = S.MonitorPositions(1,3)/2 - S.FigWidth/2;
S.FigCurrentH = S.MonitorPositions(1,4)/2 - S.FigHeight/2;
S.FigCurrentW = 200;
S.FigCurrentH = 200;
rec.UI.S = S;

% create GUI Figure
rec.UI.H0.hFigGUI = figure(...
    'Name',         'Xrecorder3',...
    'NumberTitle',  'off',...
    'Resize',       'off',...
	'color',        SC.BG,...
    'position',     [   S.FigCurrentW, ...
                        S.FigCurrentH, ...
                        S.FigWidth*rec.UI.M,...
                        S.FigHeight*rec.UI.M],...
    'menubar',      'none',...
	'doublebuffer', 'off');
    % 'position',     [   S.FigCurrentW*rec.UI.M, ...
    %                     S.FigCurrentH*rec.UI.M, ...
    %                     S.FigWidth,     S.FigHeight],...

% create the Control Panel
S.PanelCurrentW = S.SP;
S.PanelCurrentH = S.SP;
rec.UI.H0.hPanelCtrl = uipanel(...
  	'parent',           rec.UI.H0.hFigGUI,...
    'BackgroundColor',  SC.BG,...
    'Highlightcolor',   SC.HL,...
    'ForegroundColor',  SC.FG,...
    'FontSize',         8*rec.UI.M,...
   	'units',            'pixels',...
  	'Title',            'CONTROL PANEL',...
    'Position',         [   S.PanelCurrentW     S.PanelCurrentH ...
                            S.PanelCtrlWidth    S.PanelCtrlHeight]*rec.UI.M);

% create rows of Empty Panelettess                      
for i = 1:S.PanelettesRowNum
    for j = 1:S.PanelettesColumnNum
        rec.UI.H0.Panelettes{i,j}.hPanelette = uipanel(...
        'parent',           rec.UI.H0.hPanelCtrl,...
        'BackgroundColor',  SC.BG,...
        'Highlightcolor',   SC.HL,...
        'ForegroundColor',  SC.FG,...
        'FontSize',         8*rec.UI.M,...
        'units',            'pixels',...
        'Title',            ' ',...
        'Position', [   2*S.S+(S.S+S.PanelettesWidth)*(j-1),...
                        2*S.S+(S.S+S.PanelettesHeight)*(S.PanelettesRowNum-i),...
                        S.PanelettesWidth, S.PanelettesHeight]*rec.UI.M);
                            % edge is 2*S.S
    end
end

% create Panelettess
S.PnltCurrent.row = 1;      S.PnltCurrent.column =    1;
    WP.name =	'Microphones';    
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type = 	'CheckBox';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'Calibration Microphones'};
        WP.tip =    rec.Mic_OptionTipStr;  
        WP.inputOptions =   {   rec.MicSysOpts(1).Name,...
                                rec.MicSysOpts(2).Name,...
                                ''   };
        WP.inputValue =   [     rec.MicSysOpts(1).Enable
                                rec.MicSysOpts(2).Enable
                                0   ];
        Panelette3(S, WP, 'rec');  
        rec.UI.H.hMicSys_Checkbox(1) = 	rec.UI.H0.Panelettes{WP.row,WP.column}.hCheckbox(1);
        rec.UI.H.hMicSys_Checkbox(2) = 	rec.UI.H0.Panelettes{WP.row,WP.column}.hCheckbox(2);
        rec.UI.H.hMicSys_Checkbox(3) = 	rec.UI.H0.Panelettes{WP.row,WP.column}.hCheckbox(3);
        set(rec.UI.H.hMicSys_Checkbox(1),	'tag',  'hMicSys_Checkbox1');
        set(rec.UI.H.hMicSys_Checkbox(2),	'tag',  'hMicSys_Checkbox2');
        set(rec.UI.H.hMicSys_Checkbox(3),	'tag',  'hMicSys_Checkbox3');
        clear WP; 

    WP.name =	'Mic'' Sensitivity';    
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type = 	'RockerSwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column =  S.PnltCurrent.column + 1; 
        WP.text = { 'Microphones'' sensitivity (mV/Pa)'};
        WP.tip =    rec.Mic_OptionTipStr;  
        WP.inputOptions =   {...
            sprintf('%5.1f mV/Pa', rec.MicSysOpts(1).mVperPa),...
            sprintf('%5.1f mV/Pa', rec.MicSysOpts(2).mVperPa),...
            sprintf('')   };
        WP.inputDefault =   0;
        Panelette3(S, WP, 'rec');  
        rec.UI.H.hMicSens_RockerA =     rec.UI.H0.Panelettes{WP.row,WP.column}.hRocker{1};
        set(rec.UI.H.hMicSens_RockerA,    'tag',      'hMicSens_Rocker');
        for i = 1:length(rec.UI.H.hMicSens_RockerA.Children)
            rec.UI.H.hMicSens_RockerA.Children(i).Enable = 'off';
        end
        clear WP; 

    WP.name =	'Amplifiers'' Mode';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'PopupMenu';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'Direct feedthrough or with amplifier'};
        WP.tip = {  'Direct feedthrough or with amplifier'};
        WP.inputOptions = {	rec.Amp_DirectMode,...
                            rec.Amp_DirectMode,...
                            rec.Amp_Name	};
        WP.inputValue = [   rec.Ch(1).AmpModeOptNum,...
                            rec.Ch(2).AmpModeOptNum ,...
                            1  ];
        WP.inputEnable =    [ 1 1 NaN ];
        Panelette3(S, WP, 'rec'); 
        rec.UI.H.hAmpMode_PopupMenu(1) = rec.UI.H0.Panelettes{WP.row,WP.column}.hPopupMenu(1);
        rec.UI.H.hAmpMode_PopupMenu(2) = rec.UI.H0.Panelettes{WP.row,WP.column}.hPopupMenu(2);
        rec.UI.H.hAmpMode_PopupMenu(3) = rec.UI.H0.Panelettes{WP.row,WP.column}.hPopupMenu(3);
        set(rec.UI.H.hAmpMode_PopupMenu(1),	'tag',  'hAmpMode_PopupMenu1');
        set(rec.UI.H.hAmpMode_PopupMenu(2),	'tag',  'hAmpMode_PopupMenu2');
        set(rec.UI.H.hAmpMode_PopupMenu(3),	'tag',  'hAmpMode_PopupMenu3');
        clear WP;

    WP.name =	'Amplifiers'' Gain';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'PopupMenu';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'Amplifier'' Gain in dB'};
        WP.tip = {  'Amplifier'' Gain in dB'};
        WP.inputOptions = {	rec.Amp_GainStr,...
                            rec.Amp_GainStr,...
                            rec.Amp_Name	};
        WP.inputValue = [   rec.Ch(1).AmpGainOptNum,...
                            rec.Ch(2).AmpGainOptNum ,...
                            1  ];
        WP.inputEnable =    [ 1 1 NaN ];
        Panelette3(S, WP, 'rec'); 
        rec.UI.H.hAmpGain_PopupMenu(1) = rec.UI.H0.Panelettes{WP.row,WP.column}.hPopupMenu(1);
        rec.UI.H.hAmpGain_PopupMenu(2) = rec.UI.H0.Panelettes{WP.row,WP.column}.hPopupMenu(2);
        rec.UI.H.hAmpGain_PopupMenu(3) = rec.UI.H0.Panelettes{WP.row,WP.column}.hPopupMenu(3);
        set(rec.UI.H.hAmpGain_PopupMenu(1),	'tag',  'hAmpGain_PopupMenu1');
        set(rec.UI.H.hAmpGain_PopupMenu(2),	'tag',  'hAmpGain_PopupMenu2');
        set(rec.UI.H.hAmpGain_PopupMenu(3),	'tag',  'hAmpGain_PopupMenu3');
        clear WP;

    WP.name =	'DAQ AI Channel #';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'PopupMenu';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'NI-DAQ Analog Input Channel #'};
        WP.tip = {  'NI-DAQ Analog Input Channel #'};
        WP.inputOptions = {	rec.DAQ_ai_ChStr...
                            rec.DAQ_ai_ChStr,...
                            rec.DAQ_CardName 	};
        WP.inputValue = [   rec.Ch(1).DAQaiChOptNum,...
                            rec.Ch(2).DAQaiChOptNum,...
                            1  ];
        WP.inputEnable =    [ 1 1 NaN ];
        Panelette3(S, WP, 'rec'); 
        rec.UI.H.hDAQaiCh_PopupMenu(1) = rec.UI.H0.Panelettes{WP.row,WP.column}.hPopupMenu(1);
        rec.UI.H.hDAQaiCh_PopupMenu(2) = rec.UI.H0.Panelettes{WP.row,WP.column}.hPopupMenu(2);
        rec.UI.H.hDAQaiCh_PopupMenu(3) = rec.UI.H0.Panelettes{WP.row,WP.column}.hPopupMenu(3);
        set(rec.UI.H.hDAQaiCh_PopupMenu(1),	'tag',	'hDAQaiCh_PopupMenu1');
        set(rec.UI.H.hDAQaiCh_PopupMenu(2),	'tag',	'hDAQaiCh_PopupMenu2');
        set(rec.UI.H.hDAQaiCh_PopupMenu(3),	'tag',	'hDAQaiCh_PopupMenu3');
        clear WP;

S.PnltCurrent.row = 2;      S.PnltCurrent.column =    1;
    WP.name =   'Timer / File Name';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'Edit';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'Recording Time (in Seconds)',...
                    'Waveform File Surname'};
        WP.tip = WP.text; 
        WP.inputValue = {   rec.RecTime,...
                            rec.FileNameHead};
        WP.inputFormat = {'%5.1f','%s'};
        WP.inputEnable = {'on','on'};
        Panelette3(S, WP, 'rec');    
        rec.UI.H.hRecTime_Edit =        rec.UI.H0.Panelettes{WP.row,WP.column}.hEdit{1};
        rec.UI.H.hFileNameHead_Edit =   rec.UI.H0.Panelettes{WP.row,WP.column}.hEdit{2};
        set(rec.UI.H.hRecTime_Edit,         'tag',  'hRecTime_Edit');
        set(rec.UI.H.hFileNameHead_Edit,	'tag',  'hFileNameHead_Edit');
        clear WP;    
    WP.name = 'Start / Stop';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'RockerSwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'Start /Stop Recording'};
        WP.tip = {  'Start /Stop Recording'};
        WP.inputOptions =   {'Start','Stop',''};
        WP.inputDefault =   2;
        Panelette3(S, WP, 'rec'); 
        rec.UI.H.hStartStop_Rocker = rec.UI.H0.Panelettes{WP.row,WP.column}.hRocker{1};
        set(rec.UI.H.hStartStop_Rocker,     'tag',  'hStartStop_Rocker');
        clear WP; 
    
    WP.name = 'Plot / Save';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'MomentarySwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'Plot','Save'}; 	
        WP.tip = {  '',''};
        WP.inputEnable = {'on','on'};
        Panelette3(S, WP, 'rec');  
        rec.UI.H.hPlot_Momentary = rec.UI.H0.Panelettes{WP.row,WP.column}.hMomentary{1};
        rec.UI.H.hSave_Momentary = rec.UI.H0.Panelettes{WP.row,WP.column}.hMomentary{2};
        set(rec.UI.H.hPlot_Momentary,       'tag',  'hPlot_Momentary');
        set(rec.UI.H.hSave_Momentary,       'tag',  'hSave_Momentary');
        clear WP;
        
    WP.name = 'Load';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'MomentarySwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'Load',''};	
        WP.tip = {  '',''};
        WP.inputEnable = {'on','off'};
        Panelette3(S, WP, 'rec'); 
        rec.UI.H.hLoad_Momentary = rec.UI.H0.Panelettes{WP.row,WP.column}.hMomentary{1};
        set(rec.UI.H.hLoad_Momentary,       'tag',  'hLoad_Momentary');
        clear WP;

    WP.name =	'Ampfliers'' Filter';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'RockerSwitch';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column =  S.PnltCurrent.column + 1; 
        WP.text =   {'Linear, HighPass, or A-weighting'};
        WP.tip =    {'Linear, HighPass, or A-weighting'}; 
        WP.inputOptions =   rec.Amp_FilterOptions;
        WP.inputDefault =   rec.Amp_FilterOptNum;
        Panelette3(S, WP, 'rec');  
        rec.UI.H.hAmpFilter_Rocker =    rec.UI.H0.Panelettes{WP.row,WP.column}.hRocker{1};
        set(rec.UI.H.hAmpFilter_Rocker,     'tag',  'hAmpFilter_Rocker');
  
function FigureClip
    ButtonTag =         get(gcbo,   'UserData');
    FigureH =           gcf;
    FigPosiMatlab =     get(gcf,    'Position');
%     AxesH =             get(H,      'Parent');
%     AxesPosiMatlab =    get(AxesH,  'Position');    
%     FigName =           get(gcf,    'Name');
    MoniPosiMatlab =    get(0,      'MonitorPosition');
    MoniNumMain =       find(MoniPosiMatlab(:,1) == 1);
    % -x -y are counted from the lowerleft corner of the WINDOWS MAIN DISPLAY
    %   MATLAB sets the display information values for this property at startup.
    %   The values are static. If your system display settings change, 
    %   for example, if you plug in a new monitor, then the values do not update. 
    %   To refresh the values, restart MATLAB.
    switch ButtonTag
        case 'SpecXLabel';	AxesPlus = [    -1  -1  -1  -1  ];  figclip = 1;
                            AxesPosiMatlab = [ 0 0 FigPosiMatlab(3:4)];
%         case 'Var1';    AxesPlus = [    -2  -56 54  17  ];  figclip = 1;
%         case 'Tex1';                                        figclip = 0;
%         case 'Tex3';    SesName =   strtok(FigName, '"');
%                         SesName =   split(SesName, '_');
%                         SesName =   join(SesName(1:5), '_');
%                         clipboard('copy',   SesName{1});...
%                                                             figclip = 0;      
        otherwise
    end
    if figclip
        AxesAdd =       AxesPlus;
        AxesAdd(3:4) =  AxesAdd(3:4)-AxesAdd(1:2);
        FigCutMatlab =  AxesPosiMatlab + AxesAdd;
        MoniCutMatlab = FigCutMatlab + [FigPosiMatlab(1:2) 0 0];
        MoniCutWin =    MoniCutMatlab;
        MoniCutWin(2) = MoniPosiMatlab(MoniNumMain,4) - MoniCutWin(2) - MoniCutWin(4);
        % The following function requires NirCmd
        % http://www.nirsoft.net/utils/nircmd.html
        % download NirCmd, unzip, and put the .exe files into Windows/System32
        dos([ 'C:\Windows\System32\Nircmd.exe savescreenshot *clipboard* ', ...
            sprintf('%d ', MoniCutWin) ]);
        % The coordinates for Nircmd is: -x, -y, width, height
        %   -x, -y are counted from the upperleft corner of the WINDOWS MAIN DISPLAY
    else
    end

function CC = CaliChart_GRAS_46AC
    CC.temp = [...              % freq(Hz), Pressure(dB), Free-Field(dB)
        250     0.00    0.00     
        280     0.00    0.01
        315     -0.00   0.01
        355     -0.01   0.01
        400     -0.01   0.01
        450     -0.02   0.01
        500     -0.03   0.01
        560     -0.04   -0.00
        630     -0.05   -0.01
        710     -0.06   -0.01
        800     -0.07   -0.01
        900     -0.09   -0.02
        1000    -0.11   -0.03
        1120    -0.14   -0.04
        1250    -0.17   -0.04
        1400    -0.21   -0.05
        1600    -0.27   -0.06
        1800    -0.33   -0.08
        2000    -0.40   -0.09
        2240    -0.50   -0.10
        2500    -0.61   -0.11
        2800    -0.74   -0.14
        3150    -0.91   -0.19
        3550    -1.12   -0.25
        4000    -1.37   -0.32
        4500    -1.66   -0.36
        5000    -1.97   -0.36
        5600    -2.34   -0.40
        6300    -2.78   -0.46
        7100    -3.28   -0.48
        8000    -3.83   -0.46
        9000    -4.45   -0.36   
        10000   -5.07   -0.13
        11200   -5.76   0.15
        12500   -6.44   0.05
        14000   -7.07   0.12
        16000   -7.82   0.08
        18000   -8.44   0.37
        20000   -8.97   0.44
        22400   -9.46   0.64
        25000   -10.00  0.70
        28000   -10.61  0.49 
        31500   -11.11  0.39
        35500   -11.35  0.65
        40000   -11.49  0.61
        ];
    CC.Freq =       CC.temp(:,1);
    CC.Pressure =   CC.temp(:,2);
    CC.FreeField =  CC.temp(:,3);


function CC = CaliChart_GRAS_40HL
    CC.temp = [...              % freq(Hz), Pressure(dB), Free-Field(dB)
        251.189E+0  0.000E+0    -117.170E-3
        266.073E+0  0.000E+0    -94.743E-3
        281.838E+0  0.000E+0    -87.426E-3
        298.538E+0  0.000E+0    -78.994E-3
        316.228E+0  0.000E+0    -72.678E-3
        334.965E+0  0.000E+0    -67.807E-3
        354.813E+0  0.000E+0    -63.111E-3
        375.837E+0  0.000E+0    -54.786E-3
        398.107E+0  0.000E+0    -46.675E-3
        421.697E+0  0.000E+0    -39.307E-3
        446.684E+0  0.000E+0    -35.878E-3
        473.151E+0  0.000E+0    -32.748E-3
        501.187E+0  0.000E+0    -30.957E-3
        530.884E+0  0.000E+0    -29.107E-3
        562.341E+0  0.000E+0    -27.772E-3
        595.662E+0  0.000E+0    -25.740E-3
        630.957E+0  0.000E+0    -23.669E-3
        668.344E+0  0.000E+0    -21.296E-3
        707.946E+0  0.000E+0    -18.946E-3
        749.894E+0  0.000E+0    -15.780E-3
        794.328E+0  0.000E+0    -13.533E-3
        841.395E+0  0.000E+0    -11.442E-3
        891.251E+0  0.000E+0    -10.043E-3
        944.061E+0  0.000E+0    -7.450E-3
        1.000E+3    0.000E+0    -26.000E-3
        1.059E+3    0.000E+0    -23.732E-3
        1.122E+3    0.000E+0    -15.746E-3
        1.189E+3    0.000E+0    7.334E-3
        1.259E+3    0.000E+0    32.149E-3
        1.334E+3    0.000E+0    57.550E-3
        1.413E+3    0.000E+0    69.477E-3
        1.496E+3    0.000E+0    93.419E-3
        1.585E+3    0.000E+0    117.566E-3
        1.679E+3    0.000E+0    101.627E-3
        1.778E+3    0.000E+0    111.690E-3
        1.884E+3    0.000E+0    135.308E-3
        1.995E+3    0.000E+0    139.751E-3
        2.113E+3    0.000E+0    152.787E-3
        2.239E+3    0.000E+0    131.562E-3
        2.371E+3    0.000E+0    148.674E-3
        2.512E+3    0.000E+0    133.224E-3
        2.661E+3    0.000E+0    132.667E-3
        2.818E+3    0.000E+0    109.067E-3
        2.985E+3    0.000E+0    101.129E-3
        3.162E+3    0.000E+0    30.956E-3
        3.350E+3    0.000E+0    39.763E-3
        3.548E+3    0.000E+0    -21.120E-3
        3.758E+3    0.000E+0    -70.230E-3
        3.981E+3    0.000E+0    -123.464E-3
        4.217E+3    0.000E+0    -148.565E-3
        4.467E+3    0.000E+0    -220.378E-3
        4.732E+3    0.000E+0    -195.559E-3
        5.012E+3    0.000E+0    -226.385E-3
        5.309E+3    0.000E+0    -219.189E-3
        5.623E+3    0.000E+0    -291.111E-3
        5.957E+3    0.000E+0    -290.938E-3
        6.310E+3    0.000E+0    -293.114E-3
        6.683E+3    0.000E+0    -266.534E-3
        7.079E+3    0.000E+0    -260.176E-3
        7.499E+3    0.000E+0    -165.319E-3
        7.943E+3    0.000E+0    -127.621E-3
        8.414E+3    0.000E+0    -68.841E-3
        8.913E+3    0.000E+0    2.743E-3
        9.441E+3    0.000E+0    273.508E-3
        10.000E+3   0.000E+0    492.589E-3
        10.593E+3   0.000E+0    658.743E-3
        11.220E+3   0.000E+0    739.724E-3
        11.885E+3   0.000E+0    567.101E-3
        12.589E+3   0.000E+0    502.917E-3
        13.335E+3   0.000E+0    648.696E-3
        14.125E+3   0.000E+0    872.016E-3
        14.962E+3   0.000E+0    1.057E+0
        15.849E+3   0.000E+0    1.019E+0
        16.788E+3   0.000E+0    1.344E+0
        17.783E+3   0.000E+0    1.496E+0
        18.836E+3   0.000E+0    1.480E+0
        19.953E+3   0.000E+0    719.264E-3
        21.135E+3   0.000E+0    382.062E-3
        ];
    CC.Freq =       CC.temp(:,1);
    CC.Pressure =   CC.temp(:,2);
    CC.FreeField =  CC.temp(:,3);