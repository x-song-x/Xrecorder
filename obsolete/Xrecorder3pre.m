function varargout = Xrecorder3(varargin)
% Xrecorder3 is for the setup assembled in Beijing THU-NPRC & CASIA 2023.07
%   for recording calibrated sounds w/ :
%       (1) G.R.A.S. calibrated microphones 46AC(HighFreq), 40HL(LowNoise)
%       (2) G.R.A.S. microphone amplifiers 12AA
%       (3) NI USB-4431 sound & vibration DAQ card   
%   This setup requires :
%       (1) Matlab R2023a and its NI DAQmx adaptor
%       (2) NI DAQmx v23.1.0 
%           to operate
% Xrecorder3pre is the version w/ old GUI (Panelette)
%   all pre versions are w/ the 4x4 panelettes arrangement
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

%% Parameter Setup

rec.G.M =                   1;  % Graphics Magnification

rec.FileNameHead =          'rec';
rec.FileDir =               'C:\EXPERIMENTS\Ambience\';
rec.RecTime =               1;

    i = 1;
    rec.MicOptions(i).Name =            'G.R.A.S. 46AC';
    rec.MicOptions(i).ShortName =       '46AC';
    rec.MicOptions(i).SN =              '560157';
    rec.MicOptions(i).mVperPa =         12.5;

    i = 2;
    rec.MicOptions(i).Name =  		    'G.R.A.S. 40HL';
    rec.MicOptions(i).ShortName =       '40HL';
    rec.MicOptions(i).SN =              '519396';
    rec.MicOptions(i).mVperPa = 	    850;

    i = 3;
    rec.MicOptions(i).Name =  		    'Not Connected';
    rec.MicOptions(i).ShortName =       '';
    rec.MicOptions(i).SN =              '';
    rec.MicOptions(i).mVperPa = 	    NaN;

rec.Mic_OptionTable =       struct2table(rec.MicOptions);
rec.Mic_OptionStr =         ''; 

rec.Amp_Name =  	        'G.R.A.S. 12AA';
rec.Amp_SN =                '457825';
rec.Amp_InputPorts =        {   'A',        'B'     };
rec.Amp_GainOptions =       [   -20         0,      NaN,    20,         40,         NaN ];
rec.Amp_GainStr =           {   '-20 dB',   '0 dB', '';     '20 dB',    '40 dB',    ''  }';
rec.Amp_GainNum =           [   0.1         1       NaN     10          100         NaN ];
rec.Amp_DirectMode =        {   'Direct',   'Amplifier'     ''};
rec.Amp_FilterOptions =     {   'Linear',   'HighPass',     'A-weighting'   };
rec.Amp_FilterOptNum =      1;

rec.DAQ_Card =              'USB-4431';     % 'NI card device name
rec.DAQ_AI_ChOptions =      [   0       1       NaN     2       3       NaN     ];
rec.DAQ_AI_ChStr =          {   'ai0',  'ai1',  '';     'ai2',  'ai3',  ''      }';
rec.DAQ_SR =                100e3;
rec.DAQ_UR =                5;
rec.DAQ_DR =                10;
rec.DAQ_mx_adaptor =        'matlab';   % or 'scanimage'


rec.GUI_ToggleOptionNum =   [   1       2       3;      4       5       6   ];
rec.GUI_ToggleButtomNum =   {   [1,0],  [2,0],  [3,0],  [0,1],  [0,2],  [0,3]};

i = 1;
    rec.Ch(i).Name =            rec.Amp_InputPorts(i);
    rec.Ch(i).MicOptNum =       i;
    rec.Ch(i).AmpModeOptNum =   2;
    rec.Ch(i).AmpGainOptNum =   4;
    rec.Ch(i).DAQ_AI_ChOptNum = 1;

i = 2;
    rec.Ch(i).Name =            rec.Amp_InputPorts(i);
    rec.Ch(i).MicOptNum =       i;
    rec.Ch(i).AmpModeOptNum =   2;
    rec.Ch(i).AmpGainOptNum =   5;
    rec.Ch(i).DAQ_AI_ChOptNum = 2;

%% GUI Setup

S.Color.BG =        [   0       0       0];
S.Color.HL =        [   0       0       0];
S.Color.FG =        [   0.6     0.6     0.6];    
S.Color.TextBG =    [   0.25    0.25    0.25];
S.Color.SelectB =  	[   0       0       0.35];
S.Color.SelectT =  	[   0       0       0.35];

rec.UI.C = S.Color;

% Screen Size
S.MonitorPositions = get(0,'MonitorPositions');

% Global Spacer Scale
S.SP = 10;          % Panelettes Side Spacer
S.S = 2;            % Small Spacer 

% Panelettes Scale
S.PanelettesWidth = 100;         S.PanelettesHeight = 150;    
S.PanelettesTitle = 18;
S.PanelettesRowNum = 4;  S.PanelettesColumnNum = 4;

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
    'Name',         'Xrecorder',...
    'NumberTitle',  'off',...
    'Resize',       'off',...
	'color',        S.Color.BG,...
    'position',     [   S.FigCurrentW, ...
                        S.FigCurrentH, ...
                        S.FigWidth*rec.G.M,...
                        S.FigHeight*rec.G.M],...
    'menubar',      'none',...
	'doublebuffer', 'off');
    % 'position',     [   S.FigCurrentW*rec.G.M, ...
    %                     S.FigCurrentH*rec.G.M, ...
    %                     S.FigWidth,     S.FigHeight],...

% create the Control Panel
S.PanelCurrentW = S.SP;
S.PanelCurrentH = S.SP;
rec.UI.H0.hPanelCtrl = uipanel(...
  	'parent',           rec.UI.H0.hFigGUI,...
    'BackgroundColor',  S.Color.BG,...
    'Highlightcolor',   S.Color.HL,...
    'ForegroundColor',  S.Color.FG,...
   	'units',            'pixels',...
  	'Title',            'CONTROL PANEL',...
    'Position',         [   S.PanelCurrentW     S.PanelCurrentH ...
                            S.PanelCtrlWidth    S.PanelCtrlHeight]*rec.G.M);

% create rows of Empty Panelettess                      
for i = 1:S.PanelettesRowNum
    for j = 1:S.PanelettesColumnNum
        rec.UI.H0.Panelettes{i,j}.hPanelette = uipanel(...
        'parent',           rec.UI.H0.hPanelCtrl,...
        'BackgroundColor',  S.Color.BG,...
        'Highlightcolor',   S.Color.HL,...
        'ForegroundColor',  S.Color.FG,...
        'units',            'pixels',...
        'Title',            ' ',...
        'Position', [   2*S.S+(S.S+S.PanelettesWidth)*(j-1),...
                        2*S.S+(S.S+S.PanelettesHeight)*(S.PanelettesRowNum-i),...
                        S.PanelettesWidth, S.PanelettesHeight]*rec.G.M);
                            % edge is 2*S.S
    end
end

% create Panelettess
S.PnltCurrent.row = 1;      S.PnltCurrent.column =    1;
    WP.name =	'Ch A: Microphone';    
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type = 	'RockerSwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column =  S.PnltCurrent.column + 1; 
        WP.text = { 'The Microphone on Amp Channel A'};
        WP.tip = {  rec.Mic_OptionStr};  
        % WP.inputOptions =   {'4191+AM1800','4191+Ron''s','4189+2250'};
        WP.inputOptions =   rec.Mic_OptionTable.Name';
        WP.inputDefault =   rec.Ch(1).MicOptNum;
        Panelette(S, WP, 'rec');  
        rec.UI.H.hMic_RockerA =       rec.UI.H0.Panelettes{WP.row,WP.column}.hRocker{1};
        set(rec.UI.H.hMic_RockerA,    'tag',      'hMic_RockerA');
        set(rec.UI.H.hMic_RockerA,    'UserData', 'A'); 
        clear WP; 
    WP.name =	'Ch B: Microphone';    
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type = 	'RockerSwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.row =     S.PnltCurrent.row + 1; 
            S.PnltCurrent.column =  S.PnltCurrent.column - 1; 
        WP.text = { 'The Microphone on Amp Channel B'};
        WP.tip = {  rec.Mic_OptionStr};  
        % WP.inputOptions =   {'4191+AM1800','4191+Ron''s','4189+2250'};
        WP.inputOptions =   rec.Mic_OptionTable.Name';
        WP.inputDefault =   rec.Ch(2).MicOptNum;
        Panelette(S, WP, 'rec');  
        rec.UI.H.hMic_RockerB =       rec.UI.H0.Panelettes{WP.row,WP.column}.hRocker{1};
        set(rec.UI.H.hMic_RockerB,    'tag',      'hMic_RockerB');
        set(rec.UI.H.hMic_RockerB,    'UserData', 'B'); 
        clear WP; 

    WP.name =	'Ch A: Amp Mode';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type = 	'RockerSwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column =  S.PnltCurrent.column + 1; 
        WP.text = { 'Direct feedthrough or with amplifier'};
        WP.tip = {  rec.Mic_OptionStr};  
        % WP.inputOptions =   {'4191+AM1800','4191+Ron''s','4189+2250'};
        WP.inputOptions =   rec.Amp_DirectMode;
        WP.inputDefault =   rec.Ch(1).AmpModeOptNum;
        Panelette(S, WP, 'rec');  
        rec.UI.H.hAmpMode_RockerA =     rec.UI.H0.Panelettes{WP.row,WP.column}.hRocker{1};
        set(rec.UI.H.hAmpMode_RockerA,  'tag',      'hAmpMode_RockerA');
        set(rec.UI.H.hAmpMode_RockerA,  'UserData', 'A'); 
    WP.name =	'Ch B: Amp Mode';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type = 	'RockerSwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column =  S.PnltCurrent.column + 1; 
        WP.text = { 'Direct feedthrough or with amplifier'};
        WP.tip = {  rec.Mic_OptionStr};  
        % WP.inputOptions =   {'4191+AM1800','4191+Ron''s','4189+2250'};
        WP.inputOptions =   rec.Amp_DirectMode;
        WP.inputDefault =   rec.Ch(2).AmpModeOptNum;
        Panelette(S, WP, 'rec');  
        rec.UI.H.hAmpMode_RockerB =     rec.UI.H0.Panelettes{WP.row,WP.column}.hRocker{1};
        set(rec.UI.H.hAmpMode_RockerB,  'tag',      'hAmpMode_RockerB');
        set(rec.UI.H.hAmpMode_RockerB,  'UserData', 'A'); 
    WP.name =	'Ampfliers'' Filter';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'RockerSwitch';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.row =     S.PnltCurrent.row + 1; 
            S.PnltCurrent.column =  S.PnltCurrent.column - 2; 
        WP.text = { 'Linear, HighPass, or A-weighting'};
        WP.tip = {  rec.Mic_OptionStr};  
        WP.inputOptions =   rec.Amp_FilterOptions;
        WP.inputDefault =   rec.Amp_FilterOptNum;
        Panelette(S, WP, 'rec');  
        rec.UI.H.hAmpFilter_Rocker =    rec.UI.H0.Panelettes{WP.row,WP.column}.hRocker{1};
        set(rec.UI.H.hAmpFilter_Rocker,     'tag',  'hAmpFilter_Rocker');

    WP.name =	'Ch A: Amp Gain';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'ToggleSwitch';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column =  S.PnltCurrent.column + 1; 
        WP.text = { 'Amplification','Gain in dB'};
        WP.tip = {  'Amplifier''s Gain, in dB',...
                	'Amplifier''s Gain, in dB'};
        WP.inputOptions = rec.Amp_GainStr';
        WP.inputDefault = rec.GUI_ToggleButtomNum{rec.Ch(1).AmpGainOptNum};
        Panelette(S, WP, 'rec'); 
        rec.UI.H.hAmpGainA_Toggle1 = rec.UI.H0.Panelettes{WP.row,WP.column}.hToggle{1};
        rec.UI.H.hAmpGainA_Toggle2 = rec.UI.H0.Panelettes{WP.row,WP.column}.hToggle{2};
        set(rec.UI.H.hAmpGainA_Toggle1,    'tag',  'hAmpGainA_Toggle1');
        set(rec.UI.H.hAmpGainA_Toggle2,    'tag',  'hAmpGainA_Toggle2');
        clear WP;
    WP.name =	'Ch B: Amp Gain';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'ToggleSwitch';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.row =     S.PnltCurrent.row + 1; 
            S.PnltCurrent.column =  S.PnltCurrent.column - 1; 
        WP.text = { 'Amplification','Gain in dB'};
        WP.tip = {  'Amplifier''s Gain, in dB',...
                	'Amplifier''s Gain, in dB'};
        WP.inputOptions = rec.Amp_GainStr';
        WP.inputDefault = rec.GUI_ToggleButtomNum{rec.Ch(2).AmpGainOptNum};
        Panelette(S, WP, 'rec'); 
        rec.UI.H.hAmpGainB_Toggle1 = rec.UI.H0.Panelettes{WP.row,WP.column}.hToggle{1};
        rec.UI.H.hAmpGainB_Toggle2 = rec.UI.H0.Panelettes{WP.row,WP.column}.hToggle{2};
        set(rec.UI.H.hAmpGainB_Toggle1,    'tag',  'hAmpGainB_Toggle1');
        set(rec.UI.H.hAmpGainB_Toggle2,    'tag',  'hAmpGainB_Toggle2');
        clear WP;

    WP.name =	'Ch A: DAQ AI Ch';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'ToggleSwitch';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'NI-DAQ Analog','Input''s Channel'};
        WP.tip = {  'NI-DAQ Analog Input''s Channel',...
                    'NI-DAQ Analog Input''s Channel'};
        WP.inputOptions = rec.DAQ_AI_ChStr';
        WP.inputDefault = rec.GUI_ToggleButtomNum{rec.Ch(1).DAQ_AI_ChOptNum};
        Panelette(S, WP, 'rec'); 
        rec.UI.H.hDAQ_AI_ChA_Toggle1 = rec.UI.H0.Panelettes{WP.row,WP.column}.hToggle{1};
        rec.UI.H.hDAQ_AI_ChA_Toggle2 = rec.UI.H0.Panelettes{WP.row,WP.column}.hToggle{2};
        set(rec.UI.H.hDAQ_AI_ChA_Toggle1,  'tag',  'hDAQ_AI_ChA_Toggle1');
        set(rec.UI.H.hDAQ_AI_ChA_Toggle2,  'tag',  'hDAQ_AI_ChA_Toggle2');
        clear WP;
    WP.name =	'Ch B: DAQ AI Ch';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'ToggleSwitch';   
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            % S.PnltCurrent.column = S.PnltCurrent.column + 1; 
        WP.text = { 'NI-DAQ Analog','Input''s Channel'};
        WP.tip = {  'NI-DAQ Analog Input''s Channel',...
                    'NI-DAQ Analog Input''s Channel'};
        WP.inputOptions = rec.DAQ_AI_ChStr';
        WP.inputDefault = rec.GUI_ToggleButtomNum{rec.Ch(2).DAQ_AI_ChOptNum};
        Panelette(S, WP, 'rec'); 
        rec.UI.H.hDAQ_AI_ChB_Toggle1 = rec.UI.H0.Panelettes{WP.row,WP.column}.hToggle{1};
        rec.UI.H.hDAQ_AI_ChB_Toggle2 = rec.UI.H0.Panelettes{WP.row,WP.column}.hToggle{2};
        set(rec.UI.H.hDAQ_AI_ChB_Toggle1,  'tag',  'hDAQ_AI_ChB_Toggle1');
        set(rec.UI.H.hDAQ_AI_ChB_Toggle2,  'tag',  'hDAQ_AI_ChB_Toggle2');
        clear WP;

S.PnltCurrent.row = 1;      S.PnltCurrent.column =    3;
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
        Panelette(S, WP, 'rec');    
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
            S.PnltCurrent.row =     S.PnltCurrent.row + 1; 
        WP.text = { 'Start /Stop Recording'};
        WP.tip = {  'Start /Stop Recording'};
        WP.inputOptions =   {'Start','Stop',''};
        WP.inputDefault =   2;
        Panelette(S, WP, 'rec'); 
        rec.UI.H.hStartStop_Rocker = rec.UI.H0.Panelettes{WP.row,WP.column}.hRocker{1};
        set(rec.UI.H.hStartStop_Rocker,     'tag',  'hStartStop_Rocker');
        clear WP; 
    
    WP.name = 'Plot / Save';
        WP.handleseed =     'rec.UI.H0.Panelettes';
        WP.type =	'MomentarySwitch';
        WP.row =        S.PnltCurrent.row;
        WP.column =     S.PnltCurrent.column;
            S.PnltCurrent.row =     S.PnltCurrent.row + 1; 
        WP.text = { 'Plot','Save'}; 	
        WP.tip = {  '',''};
        WP.inputEnable = {'on','on'};
        Panelette(S, WP, 'rec');  
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
            S.PnltCurrent.row =     S.PnltCurrent.row + 1; 
        WP.text = { 'Load',''};	
        WP.tip = {  '',''};
        WP.inputEnable = {'on','off'};
        Panelette(S, WP, 'rec'); 
        rec.UI.H.hLoad_Momentary = rec.UI.H0.Panelettes{WP.row,WP.column}.hMomentary{1};
        set(rec.UI.H.hLoad_Momentary,       'tag',  'hLoad_Momentary');
        clear WP;

S.PnltCurrent.row = 2;      S.PnltCurrent.column =    4;
	% WP.name = 'Amp';
    %     WP.handleseed =     'rec.UI.H0.Panelettes';
    %     WP.type =	'RockerSwitch';
    %     WP.row =        S.PnltCurrent.row;
    %     WP.column =     S.PnltCurrent.column;
    %         S.PnltCurrent.column = S.PnltCurrent.column + 1; 
    %     WP.text = { 'NI PCIe-6323 / NI USB-6251'};
    %     WP.tip = {	'Select the right NI-DAQ card'};
    %     WP.inputOptions =   {'NI PCIe-6323','NI USB-6251','NI PCI-6115'};
    %     WP.inputDefault =   1;
    %     Panelette(S, WP, 'rec');  
    %     rec.UI.H.hDAQ_Rocker = rec.UI.H0.Panelettes{WP.row,WP.column}.hRocker{1};
    %     set(rec.UI.H.hDAQ_Rocker,         'tag',  'hDAQ_Rocker');
    %     clear WP; 
    % 
    % WP.name =	'NIDAQ Dyn Range';
    %     WP.handleseed =     'rec.UI.H0.Panelettes';
    %     WP.type =	'ToggleSwitch';   
    %     WP.row =        S.PnltCurrent.row;
    %     WP.column =     S.PnltCurrent.column;
    %         S.PnltCurrent.column = S.PnltCurrent.column + 1; 
    %     WP.text = { 'NI-DAQ AI','dynamic range'};
    %     WP.tip = {  'NI-DAQ AI''s dynamic range',...
    %                 'NI-DAQ AI''s dynamic range'};
    %     WP.inputOptions = {'10V','5V','2V';'1V','0.5V','0.2V'};
    %     WP.inputDefault = [2, 0];
    %     Panelette(S, WP, 'rec'); 
    %     rec.UI.H.hDR_Toggle1 = rec.UI.H0.Panelettes{WP.row,WP.column}.hToggle{1};
    %     rec.UI.H.hDR_Toggle2 = rec.UI.H0.Panelettes{WP.row,WP.column}.hToggle{2};
    %     set(rec.UI.H.hDR_Toggle1,           'tag',  'hDR_Toggle1');
    %     set(rec.UI.H.hDR_Toggle2,           'tag',  'hDR_Toggle2');
    %     clear WP;
    
%% Setup Callbacks
set(rec.UI.H.hMic_RockerA,          'SelectionChangeFcn',   'Xrecorder(''GUI_Rocker'')');
set(rec.UI.H.hMic_RockerB,          'SelectionChangeFcn',   'Xrecorder(''GUI_Rocker'')');
set(rec.UI.H.hAmpMode_RockerA,      'SelectionChangeFcn',   'Xrecorder(''GUI_Rocker'')');
set(rec.UI.H.hAmpMode_RockerB,      'SelectionChangeFcn',   'Xrecorder(''GUI_Rocker'')');
set(rec.UI.H.hAmpFilter_Rocker,     'SelectionChangeFcn',   'Xrecorder(''GUI_Rocker'')');

set(rec.UI.H.hAmpGainA_Toggle1,     'SelectionChangeFcn',	'Xrecorder(''GUI_Toggle'')');
set(rec.UI.H.hAmpGainA_Toggle2,     'SelectionChangeFcn',	'Xrecorder(''GUI_Toggle'')');
set(rec.UI.H.hAmpGainB_Toggle1,     'SelectionChangeFcn',	'Xrecorder(''GUI_Toggle'')');
set(rec.UI.H.hAmpGainB_Toggle2,     'SelectionChangeFcn',	'Xrecorder(''GUI_Toggle'')');

set(rec.UI.H.hDAQ_AI_ChA_Toggle1,   'SelectionChangeFcn',	'Xrecorder(''GUI_Toggle'')');
set(rec.UI.H.hDAQ_AI_ChA_Toggle2,   'SelectionChangeFcn',	'Xrecorder(''GUI_Toggle'')');
set(rec.UI.H.hDAQ_AI_ChB_Toggle1,   'SelectionChangeFcn',	'Xrecorder(''GUI_Toggle'')');
set(rec.UI.H.hDAQ_AI_ChB_Toggle2,   'SelectionChangeFcn',	'Xrecorder(''GUI_Toggle'')');

% set(rec.UI.H.hDAQ_Rocker,         'SelectionChangeFcn',   'Xrecorder(''GUI_Rocker'')');
% set(rec.UI.H.hDR_Toggle1,           'SelectionChangeFcn',  	'Xrecorder(''GUI_Toggle'')');

set(rec.UI.H.hRecTime_Edit,         'Callback',             'Xrecorder(''GUI_Edit'')');
set(rec.UI.H.hFileNameHead_Edit,	'Callback',             'Xrecorder(''GUI_Edit'')');
set(rec.UI.H.hStartStop_Rocker,     'SelectionChangeFcn',   'Xrecorder(''GUI_Rocker'')');
set(rec.UI.H.hSave_Momentary,       'Callback',             'Xrecorder(''RecordSave'')');
set(rec.UI.H.hPlot_Momentary,       'Callback',             'Xrecorder(''RecordPlot'')');
set(rec.UI.H.hLoad_Momentary,       'Callback',             'Xrecorder(''RecordLoad'')');

% Xrecorder('GUI_Rocker', 'hDAQ_Rocker',    rec.DAQ_Card);
% Xrecorder('GUI_Rocker', 'hMicSys_Rocker',   rec.MicSys);

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
        case 'hMic_Rocker'
            ChNum = int16(label(end))-64;
            switch val
                case rec.MicOptions(1).Name     % Mic #1
                    rec.Ch(ChNum).MicOptNum = 1;
                case rec.MicOptions(2).Name     % Mic #2
                    rec.Ch(ChNum).MicOptNum = 2;
                case rec.MicOptions(3).Name     % Not Connected
                    rec.Ch(ChNum).MicOptNum = 3;
            end
        case 'hAmpMode_Rocker'
            ChNum = int16(label(end))-64;
            switch val
                case rec.Amp_DirectMode{1}      % Direct
                    rec.Ch(ChNum).AmpModeOptNum = 1;
                case rec.Amp_DirectMode{2}      % Amplifier
                    rec.Ch(ChNum).AmpModeOptNum = 2;
                case rec.Amp_DirectMode{3}      % NA
                    rec.Ch(ChNum).AmpModeOptNum = 3;
            end
        case 'hAmpFilter_Rocke'
            switch val
                case rec.Amp_FilterOptions{1}   % Linear
                    rec.Amp_FilterOptNum = 1;
                case rec.Amp_FilterOptions{2}   % HighPass
                    rec.Amp_FilterOptNum = 2;
                case rec.Amp_FilterOptions{3}   % A-weighting
                    rec.Amp_FilterOptNum = 3;
            end

           %  rec.MicSys =    val;    
           %  rec.MicSysNum = 4-k;            
           %  rec.MicSys_Name =           rec.MicOptions(rec.MicSysNum).Name;
           %  rec.MicSys_MIC_Name =       rec.MicOptions(rec.MicSysNum).MIC_Name;
           %  rec.MicSys_MIC_mVperPa =    rec.MicOptions(rec.MicSysNum).MIC_mVperPa;
           %  rec.MicSys_Amp_Name =       rec.MicOptions(rec.MicSysNum).Amp_Name;            
           %  rec.MicSys_Amp_GaindB =     rec.MicOptions(rec.MicSysNum).Amp_GaindB;
           %      GUI_Toggle('hAmp_Toggle1',	[num2str(rec.MicSys_Amp_GaindB) ' dB']);
           %  rec.DAQ_DR =         rec.MicOptions(rec.MicSysNum).Amp_MaxDR;
           %      GUI_Toggle('hDR_Toggle1',	[num2str(rec.DAQ_DR) 'V']);
           % switch rec.MicSys
           %     case '4191+AM1800'
           %          ht =  get(rec.UI.H.hAmp_Toggle1, 'Children');	set(ht(3), 'Enable', 'on');
           %                                                          set(ht(2), 'Enable', 'on');
           %                                                          set(ht(1), 'Enable', 'inactive');
           %          ht =  get(rec.UI.H.hAmp_Toggle2, 'Children');   set(ht(3), 'Enable', 'on');
           %                                                          set(ht(2), 'Enable', 'inactive');
           %                                                          set(ht(1), 'Enable', 'inactive');
           % 
           %     case '4191+Ron''s'
           %          ht =  get(rec.UI.H.hAmp_Toggle1, 'Children');	set(ht(3), 'Enable', 'inactive');
           %                                                          set(ht(2), 'Enable', 'inactive');
           %                                                          set(ht(1), 'Enable', 'inactive');
           %          ht =  get(rec.UI.H.hAmp_Toggle2, 'Children');   set(ht(3), 'Enable', 'on');
           %                                                          set(ht(2), 'Enable', 'on');
           %                                                          set(ht(1), 'Enable', 'on');
           %     case '4189+2250'
           %          ht =  get(rec.UI.H.hAmp_Toggle1, 'Children');	set(ht(3), 'Enable', 'inactive');
           %                                                          set(ht(2), 'Enable', 'on');
           %                                                          set(ht(1), 'Enable', 'on');
           %          ht =  get(rec.UI.H.hAmp_Toggle2, 'Children');   set(ht(3), 'Enable', 'on');
           %                                                          set(ht(2), 'Enable', 'on');
           %                                                          set(ht(1), 'Enable', 'on');
           %     otherwise
           %         errordlg('Amp identification error')
           % end
        % case 'hAmpMode_Rocker'       
        % case 'hDAQ_Rocker'
        %     rec.DAQ_Card =  val;         
        %     switch rec.DAQ_Card
        %         case 'NI PCIe-6323'
        %             rec.DAQ_OptionNum = 1;
        %             rec.DAQ_DR =         rec.MicOptions(rec.MicSysNum).Amp_MaxDR;
        %                 GUI_Toggle('hDR_Toggle1',	[num2str(rec.DAQ_DR) 'V']);
        %             % Switch 2V/0.2V GUI
        %             ht =  get(rec.UI.H.hDR_Toggle1, 'Children');    set(ht(1), 'Enable', 'inactive');
        %             ht =  get(rec.UI.H.hDR_Toggle2, 'Children');    set(ht(2), 'Enable', 'inactive');
        %         case 'NI USB-6251'
        %             rec.DAQ_OptionNum = 2;
        %             % Switch 2V/0.2V GUI
        %             ht =  get(rec.UI.H.hDR_Toggle1, 'Children');    set(ht(1), 'Enable', 'on');
        %             ht =  get(rec.UI.H.hDR_Toggle2, 'Children');    set(ht(2), 'Enable', 'on');
        %         case 'NI PCI-6115'
        %             rec.DAQ_OptionNum = 3;
        %             % Switch 2V/0.2V GUI
        %             ht =  get(rec.UI.H.hDR_Toggle1, 'Children');    set(ht(1), 'Enable', 'on');
        %             ht =  get(rec.UI.H.hDR_Toggle2, 'Children');    set(ht(2), 'Enable', 'on');
        %         otherwise
        %     end
        case 'hStartStop_Rocke'       
            switch val
                case 'Start';   rec.recording = 1; RecordStart;
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
            rec.Ch(1).DAQ_AI_ChOptNum = find(matches(rec.DAQ_AI_ChStr, val));
        case 'hDAQ_AI_ChB_Toggle'
            rec.Ch(2).DAQ_AI_ChOptNum = find(matches(rec.DAQ_AI_ChStr, val));
        % case 'hAmp_Toggle'      
        %     rec.MicSys_Amp_GaindB =     str2double(val(1:end-3)); 
        %     if strcmp(rec.MicSys_Amp_Name, 'Ron''s')
        %         eval(['rec.MicSys_Amp_GainNum = rec.MicSys_AmpRon.Gain',sprintf('%02d',rec.MicSys_Amp_GaindB),';']);
        %     else
        %         rec.MicSys_Amp_GainNum = 10^(rec.MicSys_Amp_GaindB/20);
        %     end
        % case 'hDR_Toggle'
        %     rec.DAQ_DR =      str2double(val(1:end-1));
        otherwise
            errordlg('Toggle tag unrecognizable!');
    end
	msg = [datestr(now, 'yy/mm/dd HH:MM:SS.FFF'),'\GUI_Toggle\',label,' selected as ',val,'\r\n'];
    disp(msg);
        
function RecordStart

    global rec

    rec.recordtime = 0; 
    rec.waveform = [];    
    
    %% NI-DAQmx implementation through Matlab adaptor
    % disable the warning of adding clocked only channels
    ws = warning("off","daq:Session:clockedOnlyChannelsAdded");
    % restore warning state when cleared
    oc = onCleanup(@() warning(ws));

    % search for the recording device
    devall = daqlist("ni");
    for i = 1:size(devall,1)
        if strcmp(devall{i,3}, rec.DAQ_Card)
            rec.DAQ_DeviceID = devall{i,1};
        end
    end
    % create acquisition task
    rec.DAQ_dq = daq("ni");
    rec.DAQ_dq.Rate = rec.DAQ_SR;
    % adding ai channels
    for i = 1:2
    %     if ~(rec.Ch(i).MicOptNum == 3)
            rec.DAQ_dq_ch(i) = addinput(rec.DAQ_dq, rec.DAQ_DeviceID,...
                rec.DAQ_AI_ChStr{rec.Ch(i).DAQ_AI_ChOptNum}, "Voltage");
            rec.DAQ_dq_ch(i).Coupling =         'DC';
            rec.DAQ_dq_ch(i).TerminalConfig =   'PseudoDifferential';
    %     end
    end
    rec.DAQ_dq.ScansAvailableFcnCount =  rec.DAQ_SR/rec.DAQ_UR;
    rec.DAQ_dq.ScansAvailableFcn =       @RecordCallback;
    start(rec.DAQ_dq,   "Duration", seconds(rec.RecTime));


    %% NI-DAQmx implementation through scanimage interface
    % T =                         [];
    % T.taskName =                'CO Trigger Task';
    % T.chan(1).deviceNames =     rec.DAQ_devName;
    % T.chan(1).chanIDs =         rec.DAQ_Options(rec.DAQ_OptionNum).CO.chanIDs;
    % T.chan(1).chanNames =       'CO Trigger Channel';
    % T.chan(1).lowTime =         0.001;
    % T.chan(1).highTime =        0.001;
    % T.chan(1).initialDelay =    0.1;
    % T.chan(1).idleState =       'DAQmx_Val_Low';
    % T.chan(1).units =           'DAQmx_Val_Seconds';
    % rec.DAQ_D.CO =	T;
    % 
    % T =                             [];
    % T.taskName =                    'AI SoundRec Task';
    % T.chan(1).deviceNames =         rec.DAQ_devName;
    % T.chan(1).chanIDs =             rec.DAQ_Options(rec.DAQ_OptionNum).AI.chanIDs;
    % T.chan(1).chanNames =           'AI SoundRec Channel';
    % T.chan(1).minVal =          -   rec.DAQ_DR;
    % T.chan(1).maxVal =              rec.DAQ_DR;
    % T.chan(1).units =               'DAQmx_Val_Volts';
    % T.chan(1).terminalConfig =      'DAQmx_Val_Diff';
    % T.time.rate =                   rec.DAQ_SR; 
    % T.time.sampleMode =             'DAQmx_Val_ContSamps';
    % T.time.sampsPerChanToAcquire =  rec.RecTime*rec.DAQ_SR;
    % T.trigger.triggerSource =       ['Ctr',num2str(rec.DAQ_Options(rec.DAQ_OptionNum).CO.chanIDs),'InternalOutput'];
    % T.trigger.triggerEdge =         'DAQmx_Val_Rising';
    % 
    % T.everyN.callbackFunc =         @RecordCallback;
    % T.everyN.everyNSamples =        round(rec.DAQ_SR/rec.DAQ_UR);
    % T.everyN.readDataEnable =       true;
    % T.everyN.readDataTypeOption =   'Scaled';   % versus 'Native'
    % 
    % T.read.outputData =             [];
    % rec.DAQ_D.AI =    T;    
    % 
    % rec.DAQ_H =	CtrlNIDAQ('Creating',                   rec.DAQ_D);
    %                 CtrlNIDAQ('Commiting',  rec.DAQ_H,    rec.DAQ_D);
    % 
    % % Putting this function here is easier for callback 
	% rec.DAQ_H.hTask_AI.registerEveryNSamplesEvent(...
    %     rec.DAQ_D.AI.everyN.callbackFunc,     rec.DAQ_D.AI.everyN.everyNSamples,...
    %     rec.DAQ_D.AI.everyN.readDataEnable,   rec.DAQ_D.AI.everyN.readDataTypeOption);
    % 
    %                 CtrlNIDAQ('Starting',	rec.DAQ_H,    rec.DAQ_D);

function RecordPlot
    global rec
        
    rec.Marmoset.AudiogramFreq = 1000*[...
        0.1250	0.2500	0.5000	1.0000	2.0000	4.0000	6.0000	7.0000	8.0000	10.0000	12.0000 16.0000 32.0000 36.0000 ];
    rec.Marmoset.AudiogramLevel = [...
        51.2000 36.4250 26.5250 18.1250 21.2750 18.9500 10.7750 6.8875  10.5500 14.1000 17.5250 20.1500 27.8500 39.0500 ];

    rec.Marmoset.ERB_Freq = [...
        250     500     1000    7000    16000];
    rec.Marmoset.ERBraw = [...
        90.97   126.85  180.51  460.83  2282.71];
    
    %% Calculate the SPL, temporal & spectral
    L = size(rec.waveform,1);
    t_mV = rec.waveform*1000;              % voltage (in mV)
    for i = 1:2
        t_mV(:,i) = t_mV(:,i)/rec.Amp_GainNum(rec.Ch(i).AmpGainOptNum);     % voltage (in mV), output @ the microphone
        t_Pa(:,i) = t_mV(:,i)/rec.MicOptions(rec.Ch(i).MicOptNum).mVperPa;  % Sound Pressure (in Pascal), @ the microphone
    end	
    t_Parms = sqrt(mean(t_Pa.^2));   	% Sound Pressure (in Pascal(rms)), a single number now  
    t_dbspl = 20*log10(t_Parms)+ 94;	% in dB SPL, 94dB SPL = 1 pascal rms
                                                    
    S_sp = fft(t_Pa)/L;                             % Sound Pressure (in Pascal/freq bin), nomalized by L 
    S_sp = abs(S_sp(1:(floor(L/2)+1)));             % Sound Pressure (in Pascal/freq bin), through away phase, and cut half
	S_sp(2:ceil(L/2)) = S_sp(2:ceil(L/2))*sqrt(2);  % Sound Pressure (in Pascal/freq bin), combine mirrored power  
    S_dbspl = 10*log10(sum(S_sp.^2))+94;    % dB SPL, abosolute sound level, (1Pascal rms = 94dB SPL)
    S_dbspl_raw = 10*log10(S_sp.^2)+94; 	% the spectrum in dB SPL  
    N = length(S_dbspl_raw);
    freq = ( (0:N-1)*rec.DAQ_SR/2/N )';
    % switch rec.MicSys_Amp_Name                 % compensate the filter shape
    %     case 'Ron''s'
    %         S_dbspl_comp = S_dbspl_raw + 10*log10(1+(freq/rec.MicSys_AmpRon.CufFreq).^2);
    %     otherwise
            S_dbspl_comp = S_dbspl_raw;
    % end
    if abs(t_dbspl - S_dbspl)<0.001         % double check the SPL calculation
        disp(['the total acoutic power is ',num2str(t_dbspl),' dB SPL']);
    else
        disp('what''s the hell?');
    end
    S_FreqERB =     250*2.^(0:0.1:6);
    S_ERB =         interp1(rec.Marmoset.ERB_Freq, rec.Marmoset.ERBraw, S_FreqERB,'spline');
    S_ERB_dbspl =   zeros(1,length(S_ERB));
    for i = 1: length(S_FreqERB)
        ERBmin = S_FreqERB(i) - 0.5*S_ERB(i);
        ERBmax = S_FreqERB(i) + 0.5*S_ERB(i);
        binmin = find(freq>ERBmin,1);
        binmax = find(freq>ERBmax,1) -1;
        S_ERB_dbspl(i) = 10*log10( sum(S_sp(binmin:binmax).^2) )+94;
    end
    
	%% Figure
    t.FigurePosition =      [0.1 0.1 0.15 0.4];
    t.FigureFontSize =      10;
    
    t.AxesSideLeft =        0.11;
    t.AxesSideRight =      	0.12;
    t.AxesWidth =           1 - t.AxesSideLeft - t.AxesSideRight;
    t.AxesHeightT =         0.2;
    t.AxesHeightSpace =     0.05;
    t.AxesHeightS =         0.62;
    t.AxesHeightStart =     0.08;
    
    t.AxesTempYMax =        rec.DAQ_DR;
    t.AxesTempYLim =        rec.DAQ_DR*1.1;
    t.AxesTempXLabel =      'Time (in second)';
    t.AxesTempXLabelV =     'Bottom';
    t.AxesTempYLabel =      {'Amplitude','(norm.)'};
    t.AxesTempYLabelV =     'Cap';
    t.LineTempYMaxColor =   [   1       0       0];
    t.LineTempWaveColor =   [   0       0.447   0.741];
    
    t.AxesSpecYTick =       -60:20:100;
    t.AxesSpecXLim =        [50 50e3];
    t.AxesSpecYLim =        [-60 100];
    t.AxesSpecXLabel =      'Frequency (in Hz)';
    t.AxesSpecXLabelV =   	'Cap';
    t.AxesSpecYLabel1 =   	'Sound Pressure Level Density (dB/Hz)';
    t.AxesSpecYLabel1V =   	'Baseline';
    t.AxesSpecYLabel2 =   	'Sound Pressure Level (dB SPL)';
    t.AxesSpecYLabel2V =   	'Cap';
    t.AxesSpecLegText =     {   'Noise floor density (in dB/Hz)',...
                                'Marmoset audiogram (in dB SPL)',...
                                'Marmoset ERB weighted noise (in dB SPL)'};
    t.AxesSpecLegLocation = 'Northeast';    
    t.LineSpecNoiseRColor = [   0       0.447   0.741];
    t.LineSpecAudiogColor = [   1       0       0];
    t.LineSpecNoiseEColor = [   0       1       0];  
    
    % Figure
    figure( 'units',                'normalized',...
            'position',             t.FigurePosition);
    warning('off',                  'all');
    % Temporal Waveform    
    axes(   'Position',             [t.AxesSideLeft,    t.AxesHeightStart+t.AxesHeightS+t.AxesHeightSpace,...
                                    t.AxesWidth,        t.AxesHeightT]);
    hold on;
    plot(rec.waveform,...
            'Color',                t.LineTempWaveColor);
    set(gca,...
            'Xtick',                [1 L],...
            'XTickLabels',          {'0', num2str(L/rec.DAQ_SR)},...
            'XLim',                 [1, L],...
            'Box',                  'on');
    h = xlabel(t.AxesTempXLabel,...
            'FontSize',             t.FigureFontSize);
    set(h,  'VerticalAlignment',	t.AxesTempXLabelV);
    
    % Dynamic Range Max/Min lines
    plot(1:L,   +t.AxesTempYMax*ones(1,L),...
            'Color',                t.LineTempYMaxColor);
    plot(1:L,   -t.AxesTempYMax*ones(1,L),...
            'Color',                t.LineTempYMaxColor);
	set(gca,...        
            'Ytick',                [- t.AxesTempYMax  t.AxesTempYMax],...
            'YLim',                 [-t.AxesTempYLim,    t.AxesTempYLim],...
            'YTickLabels',          {'DR-', 'DR+'});
	h = ylabel(t.AxesTempYLabel,...
        	'FontSize',             t.FigureFontSize);
	set(h,  'VerticalAlignment', 	t.AxesTempYLabelV);
    

    % Spectrum
    axes(   'Position',             [t.AxesSideLeft,    t.AxesHeightStart,...
                                    t.AxesWidth,        t.AxesHeightS]);
    semilogx(freq, S_dbspl_comp,...
            'Color',                t.LineSpecNoiseRColor); 
    set(gca,...
            'Xlim',                 t.AxesSpecXLim,...
            'YTick',                t.AxesSpecYTick,...
            'Ylim',                 t.AxesSpecYLim,...
            'XGrid',              	'on',...
            'YGrid',              	'on',...
            'NextPlot',             'add');  
    
    % Marmoset audiogram
    plot(rec.Marmoset.AudiogramFreq, rec.Marmoset.AudiogramLevel,...
            'Color',            	t.LineSpecAudiogColor);
    
    % Marmoset ERB weighted noise
    rec.curve.Freq =    S_FreqERB;
    rec.curve.dBSPL =   S_ERB_dbspl;
    disp(['max peak on the ERB weighted level is ', num2str(max(rec.curve.dBSPL)), ' dB SPL']);
    plot(S_FreqERB, S_ERB_dbspl,...
            'Color',             	t.LineSpecNoiseEColor);
	h = xlabel(t.AxesSpecXLabel,...
           	'FontSize',             t.FigureFontSize);
   	set(h,  'VerticalAlignment', 	t.AxesSpecXLabelV);
    h = ylabel(t.AxesSpecYLabel1,...
         	'FontSize',             t.FigureFontSize);
  	set(h,  'VerticalAlignment', 	t.AxesSpecYLabel1V);
%     legend( t.AxesSpecLegText,...
%             'Location',             t.AxesSpecLegLocation,...
%             'Box',                  'off');
    axes(   'Position',             [t.AxesSideLeft,    t.AxesHeightStart,...
                                    t.AxesWidth,        t.AxesHeightS],...
            'Color',                'none',...
            'XAxisLocation',        'Top',...
            'YAxisLocation',        'Right',...
            'XTick',                [],...
            'YTick',                t.AxesSpecYTick,...
            'Ylim',                 t.AxesSpecYLim);
    h = ylabel(t.AxesSpecYLabel2,...
         	'FontSize',             t.FigureFontSize);
  	set(h,  'VerticalAlignment', 	t.AxesSpecYLabel2V);
        
    warning('on', 'all');
    
function RecordSave
    global rec
    
    ds = datestr(now);
    tt = [  rec.MicSys_MIC_Name,'; ',...
            rec.MicSys_Amp_Name,'@Gain=',num2str(rec.MicSys_Amp_GainNum),'; ',...
            'AI@',num2str(rec.DAQ_D.AI.chan.maxVal),'V'];
    wholename = [ds(1:11),'_',ds([end-7 end-6 end-4 end-3 end-1 end]),'_',rec.FileNameHead,'.wav'];
    audiowrite([rec.FileDir wholename],...
        int16(32767*rec.waveform/rec.DAQ_DR), 100e3,...
        'BitsPerSample',    16,...
        'Artist',           tt,...
        'Title',            rec.FileNameHead,...
        'Comment',          'Acoustic Calibration Recording, from Xrecorder by Xindong Song');
    
function RecordLoad
    global rec
    
    [t.filename, t.pathname] = uigetfile([rec.FileDir '*.wav']);
    t.wavefilename  = [t.pathname t.filename];
    t.info          = audioinfo(t.wavefilename);
    disp(t.info.Artist);
    t.sysinfo       = strsplit(t.info.Artist, '; ');
    t.sysinfo2      = strsplit(t.sysinfo{2}, '@Gain=');
    t.sysinfo3      = strsplit(t.sysinfo{3}(4:end), 'V');

    t.sys.MIC.name  = t.sysinfo{1};
    t.sys.Amp.name  = t.sysinfo2{1};
    t.sys.Amp.Gain  = str2double(t.sysinfo2{2});
    t.sys.NIDAQ.AI_ChanVoltage ...
                    = str2double(t.sysinfo3{1});

        [   rec.waveform,   rec.DAQ_SR] = audioread(t.wavefilename,'native');
            rec.DAQ_DR =         t.sys.NIDAQ.AI_ChanVoltage;
            rec.MicSys_Amp_GainNum =    t.sys.Amp.Gain;
            rec.MicSys_Amp_Name =       t.sys.Amp.name;
            rec.MicSys_MIC_Name =       t.sys.MIC.name;

            rec.waveform =              double(rec.waveform)/32767*rec.DAQ_DR;
    switch rec.MicSys_MIC_Name
        case '4191'
            rec.MicSys_MIC_mVperPa =    13.2;
        case '4189'
            rec.MicSys_MIC_mVperPa =    51.3;
        otherwise
            errordlg('Microphone not recognized!');
    end
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
    rec.waveform = [rec.waveform; data];
    if rec.recording == 0
        RecordPlot;
    end
    