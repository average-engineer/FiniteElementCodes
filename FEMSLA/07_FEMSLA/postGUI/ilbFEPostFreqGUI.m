function varargout = ilbFEPostFreqGUI(varargin)
%ILBFEPOSTFREQGUI M-file for ilbFEPostFreqGUI.fig
%      ILBFEPOSTFREQGUI, by itself, creates a new ILBFEPOSTFREQGUI or raises the existing
%      singleton*.
%
%      H = ILBFEPOSTFREQGUI returns the handle to a new ILBFEPOSTFREQGUI or the handle to
%      the existing singleton*.
%
%      ILBFEPOSTFREQGUI('propertyPanel','Value',...) creates a new ILBFEPOSTFREQGUI using the
%      given propertypanel value pairs. Unrecognized properties are passed via
%      varargin to ilbFEPostFreqGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      ILBFEPOSTFREQGUI('CALLBACK') and ILBFEPOSTFREQGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in ILBFEPOSTFREQGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ilbFEPostFreqGUI

% Last Modified by GUIDE v2.5 10-Sep-2012 15:42:51

% Begin initialization code - DO NOT EDIT
 gui_Singleton = 1;
 gui_State = struct('gui_Name',       mfilename, ...
                    'gui_Singleton',  gui_Singleton, ...
                    'gui_OpeningFcn', @ilbFEPostFreqGUI_OpeningFcn, ...
                    'gui_OutputFcn',  @ilbFEPostFreqGUI_OutputFcn, ...
                    'gui_LayoutFcn',  [], ...
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


% --- Executes just before ilbFEPostFreqGUI is made visible.
function ilbFEPostFreqGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ilbFEPostFreqGUI
 handles.output = hObject;

% Update handles structure
 guidata(hObject, handles);

% UIWAIT makes ilbFEPostFreqGUI wait for user response (see UIRESUME)
% uiwait(handles.ilbFEPostFreq);

% Initialize global variables
 global displacement nodes elements frequencies displayMode;
 set(handles.displacementTable, 'Data', displacement.data(:,2:end,frequencies.i));
 nodes.i = size(displacement.data,1); 
 displayMode.cSource = 'displacement.total';
 displayMode.cColumn = 1;
 displayMode.original = 1;
 displayMode.restraints = 1;
 handles.patch = -1;
 nodes = updatePostFreq(handles.resultDisplay, displacement, nodes, elements, frequencies);
 setAxes(handles.resultDisplay);
 guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = ilbFEPostFreqGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
 varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function ilbFEPostFreq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ilbFEPostFreq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in displacementTable.
function displacementTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to displacementTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
 global displacement frequencies  nodes elements;
 if ~isempty(eventdata.Indices)
    nodes.i = eventdata.Indices(1,1);
 else
     nodes.i = size(displacement.data,1);
 end
 nodes = updatePostFreq(handles.resultDisplay, displacement, nodes, elements, frequencies);
 guidata(hObject, handles);


% --------------------------------------------------------------------
function dataCursorMode_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to dataCursorMode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 global post_dcm_obj;
 post_dcm_obj = datacursormode(handles.output);
 set(post_dcm_obj,'DisplayStyle','datatip',...
             'SnapToDataVertex','on','Enable','on')
 set(post_dcm_obj,'UpdateFcn',@updatePostDataCursor);
 guidata(hObject,handles)


% --- Executes on button press in restraintCheck.
function restraintCheck_Callback(hObject, eventdata, handles)
% hObject    handle to restraintCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of restraintCheck
 global displayMode nodes displacement frequencies elements;
 displayMode.restraints = get(hObject, 'Value');
 nodes = updatePostFreq(handles.resultDisplay, displacement, nodes, elements, frequencies);
 guidata(hObject,handles)
 


% --- Executes on button press in originalCheck.
function originalCheck_Callback(hObject, eventdata, handles)
% hObject    handle to originalCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of originalCheck
 global displayMode nodes displacement frequencies elements;
 displayMode.original = get(hObject, 'Value');
 nodes = updatePostFreq(handles.resultDisplay, displacement, nodes, elements, frequencies);
 guidata(hObject,handles)

 
% --- Executes on button press in tDispRadio.
function tDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to tDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tDispRadio
 global displayMode displacement nodes frequencies elements;

 displayMode.cSource = 'displacement.total';
 displayMode.cColumn = 1;
 
 set(handles.tDispRadio, 'Value', 1.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0);
 
 nodes = updatePostFreq(handles.resultDisplay, displacement, nodes, elements, frequencies);
 guidata(hObject,handles)


% --- Executes on button press in zDispRadio.
function zDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to zDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zDispRadio
 global displayMode displacement nodes frequencies elements;

 displayMode.cSource = 'displacement.data';
 displayMode.cColumn = 4; 
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 1.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0);
 
 nodes = updatePostFreq(handles.resultDisplay, displacement, nodes, elements, frequencies);
 guidata(hObject,handles)


% --- Executes on button press in yDispRadio.
function yDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to yDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of yDispRadio
 global displayMode displacement nodes frequencies elements;

 displayMode.cSource = 'displacement.data';
 displayMode.cColumn = 3;
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 1.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0); 
 
 nodes = updatePostFreq(handles.resultDisplay, displacement, nodes, elements, frequencies);
 guidata(hObject,handles)


% --- Executes on button press in xDispRadio.
function xDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to xDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of xDispRadio
 global displayMode displacement nodes frequencies elements;

 displayMode.cSource = 'displacement.data';
 displayMode.cColumn = 2; 
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 1.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0);
 
 nodes = updatePostFreq(handles.resultDisplay, displacement, nodes, elements, frequencies);
 guidata(hObject,handles)


% --- Executes on button press in rZDispRadio.
function rZDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to rZDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rZDispRadio
 global displayMode displacement nodes frequencies elements;

 displayMode.cSource = 'displacement.data';
 displayMode.cColumn = 7; 
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 1.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0);

 nodes = updatePostFreq(handles.resultDisplay, displacement, nodes, elements, frequencies);
 guidata(hObject,handles)


% --- Executes on button press in rYDispRadio.
function rYDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to rYDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rYDispRadio
 global displayMode displacement nodes frequencies elements;
 
 displayMode.cSource = 'displacement.data';
 displayMode.cColumn = 6;
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 1.0);
 set(handles.rXDispRadio, 'Value', 0.0);
 
 nodes = updatePostFreq(handles.resultDisplay, displacement, nodes, elements, frequencies);
 guidata(hObject,handles)


% --- Executes on button press in rXDispRadio.
function rXDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to rXDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rXDispRadio
 global displayMode displacement nodes frequencies elements;
 
 displayMode.cSource = 'displacement.data';
 displayMode.cColumn = 5; 
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 1.0);

 nodes = updatePostFreq(handles.resultDisplay, displacement, nodes, elements, frequencies);
 guidata(hObject,handles)


% --- Executes on slider movement.
function frequencySlider_Callback(hObject, eventdata, handles)
% hObject    handle to frequencySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

global displacement nodes frequencies elements;

 frequencies.i = get(hObject, 'Value');
 
 set(handles.frequencyDisplay, 'String', [num2str(frequencies.i) ':  ' num2str(frequencies.data(frequencies.i))]);

 nodes = updatePostFreq(handles.resultDisplay, displacement, nodes, elements, frequencies); 
 guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function frequencySlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frequencySlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
 global frequencies
 
 if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
 end
 set(hObject, 'Min', 1)
 set(hObject, 'Max', size(frequencies.data,1))
 set(hObject, 'SliderStep', [1/(size(frequencies.data,1)-1) 1/(size(frequencies.data,1)-1)]);
 set(hObject, 'Value', frequencies.i)
 
 guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function frequencyDisplay_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frequencyDisplay (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 
 global frequencies

 set(hObject, 'String', [num2str(frequencies.i) ':  ' num2str(frequencies.data(frequencies.i))]);

 guidata(hObject,handles)


% --------------------------------------------------------------------
function uipushtool8_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
 set(handles.resultDisplay, 'Units', 'points');
 axesOuterPos = get(handles.resultDisplay, 'OuterPosition');

 hFig = figure;
 set(hFig, 'Units', 'points',...
           'Position', [150 150 axesOuterPos(3:4)]);
 
 hAxes = copyobj(handles.resultDisplay, hFig);
 set(hAxes, 'Units', 'points');
 width = axesOuterPos(3);
 height = axesOuterPos(4);
 set(hAxes, 'OuterPosition', [0 0 width height]);
 
 set(hFig, 'PaperUnits', 'points',...
           'PaperSize', [width height],...
           'PaperPositionMode', 'auto');
 
 printpreview(hFig);
 %print(hFig,'testprint', '-depsc', '-noui', '-r300');
 %close(hFig);
 
 guidata(hObject,handles)


% --------------------------------------------------------------------
function uipushtool9_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

 set(handles.resultDisplay, 'Units', 'points');
 axesOuterPos = get(handles.resultDisplay, 'OuterPosition');

 hFig = figure;
 set(hFig, 'Units', 'points',...
           'Position', [0 0 axesOuterPos(3:4)]);
 
 hAxes = copyobj(handles.resultDisplay, hFig);
 colorbar;
 
 set(hAxes, 'Units', 'points');
 width = axesOuterPos(3);
 height = axesOuterPos(4);
 set(hAxes, 'OuterPosition', [0 0 width height]);
 set(hFig, 'PaperUnits', 'points',...
           'PaperSize', [width height],...
           'PaperPositionMode', 'auto',...
           'Renderer', 'painters');
 
 answer = inputdlg({'Enter a filename with extension to save:'}, 'Save As...');
 
 if ~isempty(answer) 
    % saveas(hFig,answer{1},'epsc');
    export_fig(answer{1}, '-transparent');    % better quality export 
                                              % (needs GS and XPDF)
    % if strfind(answer{1}, '.eps') ~= -2     % if eps file as output file
        % fix_lines(answer{1});               % improves lines
    % end
 end

 close(hFig);
 
 guidata(hObject,handles)

