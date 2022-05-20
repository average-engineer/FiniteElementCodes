function varargout = ilbFEPostGUI(varargin)
%ILBFEPOSTGUI M-file for ilbFEPostGUI.fig
%      ILBFEPOSTGUI, by itself, creates a new ILBFEPOSTGUI or raises the existing
%      singleton*.
%
%      H = ILBFEPOSTGUI returns the handle to a new ILBFEPOSTGUI or the handle to
%      the existing singleton*.
%
%      ILBFEPOSTGUI('propertyPanel','Value',...) creates a new ILBFEPOSTGUI using the
%      given propertypanel value pairs. Unrecognized properties are passed via
%      varargin to ilbFEPostGUI_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      ILBFEPOSTGUI('CALLBACK') and ILBFEPOSTGUI('CALLBACK',hObject,...) call the
%      local function named CALLBACK in ILBFEPOSTGUI.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ilbFEPostGUI

% Last Modified by GUIDE v2.5 10-Sep-2012 14:46:58

% Begin initialization code - DO NOT EDIT
 gui_Singleton = 1;
 gui_State = struct('gui_Name',       mfilename, ...
                    'gui_Singleton',  gui_Singleton, ...
                    'gui_OpeningFcn', @ilbFEPostGUI_OpeningFcn, ...
                    'gui_OutputFcn',  @ilbFEPostGUI_OutputFcn, ...
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


% --- Executes just before ilbFEPostGUI is made visible.
function ilbFEPostGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for ilbFEPostGUI
 handles.output = hObject;

% Update handles structure
 guidata(hObject, handles);

% UIWAIT makes ilbFEPostGUI wait for user response (see UIRESUME)
% uiwait(handles.ilbFEPost);

% Initialize global variables
 global displacement stress nodes elements load displayMode;
 set(handles.displacementTable, 'Data', [displacement.data(:,1), displacement.total, displacement.data(:,2:end)]);
 nodes.i = size(displacement.data,1); 
 set(handles.stressTable, 'Data', []);
 elements.i = size(elements.data,1);
 displayMode.cSource = 'displacement.total';
 displayMode.cColumn = 1;
 displayMode.loads = 1;
 displayMode.original = 1;
 displayMode.restraints = 1;
 handles.patch = -1;
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 setAxes(handles.resultDisplay);
 guidata(hObject, handles);



% --- Outputs from this function are returned to the command line.
function varargout = ilbFEPostGUI_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
 varargout{1} = handles.output;


% --- Executes on button press in displacementToggle.
function displacementToggle_Callback(hObject, eventdata, handles)
% hObject    handle to displacementToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displacementToggle
 active = get(handles.displacementToggle, 'Value');
 if active > 0
    % set displacement to active
    set(handles.displacementTable, 'Visible', 'on');
    set(handles.stressToggle, 'Value', 0);   % set stress.data to active
    set(handles.stressTable, 'Visible', 'off');      
 else
    % set displacement to inactive
    set(handles.displacementTable, 'Visible', 'off');
    set(handles.stressToggle, 'Value', 1);   % set stress.data to active
    set(handles.stressTable, 'Visible', 'on');      
 end
 guidata(hObject, handles);

% --- Executes on button press in stressToggle.
function stressToggle_Callback(hObject, eventdata, handles)
% hObject    handle to stressToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of stressToggle
 active = get(handles.stressToggle, 'Value');
 if active > 0
    % set displacement to inactive
    set(handles.displacementTable, 'Visible', 'off');
    set(handles.displacementToggle, 'Value', 0);   % set displacement to active
    set(handles.stressTable, 'Visible', 'on');    
 else
    % set displacement to active
    set(handles.displacementTable, 'Visible', 'on');
    set(handles.displacementToggle, 'Value', 1);   % set stress.data to active
    set(handles.stressTable, 'Visible', 'off');   
 end
 guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function ilbFEPost_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ilbFEPost (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
 guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in displacementTable.
function displacementTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to displacementTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
 global displacement stress  nodes elements load;
 if ~isempty(eventdata.Indices)
    nodes.i = eventdata.Indices(1,1);
 else
     nodes.i = size(displacement.data,1);
 end
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in stressTable.
function stressTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to stressTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
 global displacement stress  nodes elements load;
 if ~isempty(eventdata.Indices)
     elements.i = ID2Index(stress.data(eventdata.Indices(1,1),1), elements.data(:,1));
	 nodes.i = ID2Index(stress.data(eventdata.Indices(1,1),4), nodes.data(:,1));
 else
     elements.i = size(elements.data,1);
	 nodes.i = size(displacement.data,1);
 end
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
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


% --- Executes on button press in loadCheck.
function loadCheck_Callback(hObject, eventdata, handles)
% hObject    handle to loadCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of loadCheck
 global displayMode nodes displacement stress elements load;
 displayMode.loads = get(hObject, 'Value');
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)


% --- Executes on button press in restraintCheck.
function restraintCheck_Callback(hObject, eventdata, handles)
% hObject    handle to restraintCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of restraintCheck
 global displayMode nodes displacement stress elements load;
 displayMode.restraints = get(hObject, 'Value');
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)
 


% --- Executes on button press in originalCheck.
function originalCheck_Callback(hObject, eventdata, handles)
% hObject    handle to originalCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of originalCheck
 global displayMode nodes displacement stress elements load;
 displayMode.original = get(hObject, 'Value');
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)

% --- Executes on button press in mStressRadio.
function mStressRadio_Callback(hObject, eventdata, handles)
% hObject    handle to mStressRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of mStressRadio
 global displayMode displacement nodes stress elements load;

 displayMode.cSource = 'stress.mises';
 displayMode.cColumn = 1;
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0);  
 set(handles.mStressRadio, 'Value', 1.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 0.0);
 
 set(handles.stressTable, 'Data', [stress.data(:,1:4), stress.mises]);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)


% --- Executes on button press in zStressRadio.
function zStressRadio_Callback(hObject, eventdata, handles)
% hObject    handle to zStressRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zStressRadio
 global displayMode displacement nodes stress elements load;

 displayMode.cSource = 'stress.data';
 displayMode.cColumn = 7;

 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0);  
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 1.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 0.0);
 
 set(handles.stressTable, 'Data', [stress.data(:,1:4), stress.data(:,displayMode.cColumn)]);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)


% --- Executes on button press in yStressRadio.
function yStressRadio_Callback(hObject, eventdata, handles)
% hObject    handle to yStressRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of yStressRadio
 global displayMode displacement nodes stress elements load;

 displayMode.cSource = 'stress.data';
 displayMode.cColumn = 6;

 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0);  
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 1.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 0.0);
 
 set(handles.stressTable, 'Data', [stress.data(:,1:4), stress.data(:,displayMode.cColumn)]);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)


% --- Executes on button press in xStressRadio.
function xStressRadio_Callback(hObject, eventdata, handles)
% hObject    handle to xStressRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of xStressRadio
 global displayMode displacement nodes stress elements load;

 displayMode.cSource = 'stress.data';
 displayMode.cColumn = 5;

 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0); 
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 1.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 0.0);
 
 set(handles.stressTable, 'Data', [stress.data(:,1:4), stress.data(:,displayMode.cColumn)]);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)

% --- Executes on button press in rZStressRadio.
function rZStressRadio_Callback(hObject, eventdata, handles)
% hObject    handle to rZStressRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rZStressRadio
 global displayMode displacement nodes stress elements load;

 displayMode.cSource = 'stress.data';
 displayMode.cColumn = 8;

 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0); 
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 1.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 0.0);
 
 set(handles.stressTable, 'Data', [stress.data(:,1:4), stress.data(:,displayMode.cColumn)]);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)


% --- Executes on button press in rYStressRadio.
function rYStressRadio_Callback(hObject, eventdata, handles)
% hObject    handle to rYStressRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rYStressRadio
 global displayMode displacement nodes stress elements load;

 displayMode.cSource = 'stress.data';
 displayMode.cColumn = 9;

 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0); 
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 1.0);
 set(handles.rXStressRadio, 'Value', 0.0);
 
 set(handles.stressTable, 'Data', [stress.data(:,1:4), stress.data(:,displayMode.cColumn)]);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)


% --- Executes on button press in rXStressRadio.
function rXStressRadio_Callback(hObject, eventdata, handles)
% hObject    handle to rXStressRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rXStressRadio
 global displayMode displacement nodes stress elements load;

 displayMode.cSource = 'stress.data';
 displayMode.cColumn = 10;

 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0); 
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 1.0);
 
 set(handles.stressTable, 'Data', [stress.data(:,1:4), stress.data(:,displayMode.cColumn)]);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load); 
 guidata(hObject,handles)


% --- Executes on button press in tDispRadio.
function tDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to tDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tDispRadio
 global displayMode displacement nodes stress elements load;

 displayMode.cSource = 'displacement.total';
 displayMode.cColumn = 1;
 
 set(handles.tDispRadio, 'Value', 1.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0);
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 0.0); 
 
 set(handles.stressTable, 'Data', []);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)


% --- Executes on button press in zDispRadio.
function zDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to zDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of zDispRadio
 global displayMode displacement nodes stress elements load;

 displayMode.cSource = 'displacement.data';
 displayMode.cColumn = 4; 
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 1.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0);
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 0.0); 

 set(handles.stressTable, 'Data', []);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)


% --- Executes on button press in yDispRadio.
function yDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to yDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of yDispRadio
 global displayMode displacement nodes stress elements load;

 displayMode.cSource = 'displacement.data';
 displayMode.cColumn = 3;
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 1.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0);
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 0.0); 
 
 set(handles.stressTable, 'Data', []);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)


% --- Executes on button press in xDispRadio.
function xDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to xDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of xDispRadio
 global displayMode displacement nodes stress elements load;

 displayMode.cSource = 'displacement.data';
 displayMode.cColumn = 2; 
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 1.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0);
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 0.0); 
 
 set(handles.stressTable, 'Data', []);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)


% --- Executes on button press in rZDispRadio.
function rZDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to rZDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rZDispRadio
 global displayMode displacement nodes stress elements load;

 displayMode.cSource = 'displacement.data';
 displayMode.cColumn = 7; 
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 1.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 0.0);
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 0.0); 
 
 set(handles.stressTable, 'Data', []);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)


% --- Executes on button press in rYDispRadio.
function rYDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to rYDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rYDispRadio
 global displayMode displacement nodes stress elements load;
 
 displayMode.cSource = 'displacement.data';
 displayMode.cColumn = 6;
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 1.0);
 set(handles.rXDispRadio, 'Value', 0.0);
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 0.0); 
 
 set(handles.stressTable, 'Data', []);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
 guidata(hObject,handles)


% --- Executes on button press in rXDispRadio.
function rXDispRadio_Callback(hObject, eventdata, handles)
% hObject    handle to rXDispRadio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rXDispRadio
 global displayMode displacement nodes stress elements load;
 
 displayMode.cSource = 'displacement.data';
 displayMode.cColumn = 5; 
 
 set(handles.tDispRadio, 'Value', 0.0);
 set(handles.zDispRadio, 'Value', 0.0);
 set(handles.yDispRadio, 'Value', 0.0);
 set(handles.xDispRadio, 'Value', 0.0);
 set(handles.rZDispRadio, 'Value', 0.0);
 set(handles.rYDispRadio, 'Value', 0.0);
 set(handles.rXDispRadio, 'Value', 1.0);
 set(handles.mStressRadio, 'Value', 0.0);
 set(handles.zStressRadio, 'Value', 0.0);
 set(handles.yStressRadio, 'Value', 0.0);
 set(handles.xStressRadio, 'Value', 0.0);
 set(handles.rZStressRadio, 'Value', 0.0);
 set(handles.rYStressRadio, 'Value', 0.0);
 set(handles.rXStressRadio, 'Value', 0.0); 
 
 set(handles.stressTable, 'Data', []);
 nodes = updatePost(handles.resultDisplay, displacement, nodes, stress, elements, load);
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

