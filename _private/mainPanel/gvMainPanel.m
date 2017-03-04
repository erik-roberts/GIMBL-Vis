function varargout = gvMainPanel(varargin)
% gvMainPanel MATLAB code for gvMainPanel.fig
%      gvMainPanel, by itself, creates a new gvMainPanel or raises the existing
%      singleton*.
%
%      H = gvMainPanel returns the handle to a new gvMainPanel or the handle to
%      the existing singleton*.
%
%      gvMainPanel('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in gvMainPanel.M with the given input arguments.
%
%      gvMainPanel('Property','Value',...) creates a new gvMainPanel or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gvMainPanel_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gvMainPanel_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gvMainPanel

% Last Modified by GUIDE v2.5 04-Mar-2017 15:49:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gvMainPanel_OpeningFcn, ...
                   'gui_OutputFcn',  @gvMainPanel_OutputFcn, ...
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


% --- Executes just before gvMainPanel is made visible.
function gvMainPanel_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gvMainPanel (see VARARGIN)

gvMainPanelSetup(hObject, eventdata, handles, varargin{:});

% UIWAIT makes gvMainPanel wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gvMainPanel_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function sliderVal1_Callback(hObject, eventdata, handles)
% hObject    handle to sliderVal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of sliderVal1 as text
%        str2double(get(hObject,'String')) returns contents of sliderVal1 as a double


% --- Executes during object creation, after setting all properties.
function sliderVal1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderVal1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sliderVal2_Callback(hObject, eventdata, handles)
% hObject    handle to sliderVal2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of sliderVal2 as text
%        str2double(get(hObject,'String')) returns contents of sliderVal2 as a double


% --- Executes during object creation, after setting all properties.
function sliderVal2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderVal2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sliderVal3_Callback(hObject, eventdata, handles)
% hObject    handle to sliderVal3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of sliderVal3 as text
%        str2double(get(hObject,'String')) returns contents of sliderVal3 as a double


% --- Executes during object creation, after setting all properties.
function sliderVal3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderVal3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sliderVal4_Callback(hObject, eventdata, handles)
% hObject    handle to sliderVal4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of sliderVal4 as text
%        str2double(get(hObject,'String')) returns contents of sliderVal4 as a double


% --- Executes during object creation, after setting all properties.
function sliderVal4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderVal4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sliderVal5_Callback(hObject, eventdata, handles)
% hObject    handle to sliderVal5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of sliderVal5 as text
%        str2double(get(hObject,'String')) returns contents of sliderVal5 as a double


% --- Executes during object creation, after setting all properties.
function sliderVal5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderVal5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sliderVal6_Callback(hObject, eventdata, handles)
% hObject    handle to sliderVal6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of sliderVal6 as text
%        str2double(get(hObject,'String')) returns contents of sliderVal6 as a double


% --- Executes during object creation, after setting all properties.
function sliderVal6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderVal6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sliderVal7_Callback(hObject, eventdata, handles)
% hObject    handle to sliderVal7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of sliderVal7 as text
%        str2double(get(hObject,'String')) returns contents of sliderVal7 as a double


% --- Executes during object creation, after setting all properties.
function sliderVal7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderVal7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function sliderVal8_Callback(hObject, eventdata, handles)
% hObject    handle to sliderVal8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvSliderChangeCallback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of sliderVal8 as text
%        str2double(get(hObject,'String')) returns contents of sliderVal8 as a double


% --- Executes during object creation, after setting all properties.
function sliderVal8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderVal8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in viewDim1.
function viewDim1_Callback(hObject, eventdata, handles)
% hObject    handle to viewDim1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvViewDimCallback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of viewDim1


% --- Executes on button press in viewDim2.
function viewDim2_Callback(hObject, eventdata, handles)
% hObject    handle to viewDim2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvViewDimCallback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of viewDim2


% --- Executes on button press in viewDim3.
function viewDim3_Callback(hObject, eventdata, handles)
% hObject    handle to viewDim3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvViewDimCallback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of viewDim3


% --- Executes on button press in viewDim4.
function viewDim4_Callback(hObject, eventdata, handles)
% hObject    handle to viewDim4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvViewDimCallback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of viewDim4


% --- Executes on button press in viewDim5.
function viewDim5_Callback(hObject, eventdata, handles)
% hObject    handle to viewDim5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvViewDimCallback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of viewDim5


% --- Executes on button press in viewDim6.
function viewDim6_Callback(hObject, eventdata, handles)
% hObject    handle to viewDim6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvViewDimCallback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of viewDim6


% --- Executes on button press in viewDim7.
function viewDim7_Callback(hObject, eventdata, handles)
% hObject    handle to viewDim7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvViewDimCallback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of viewDim7


% --- Executes on button press in viewDim8.
function viewDim8_Callback(hObject, eventdata, handles)
% hObject    handle to viewDim8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvViewDimCallback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of viewDim8


% --- Executes on button press in iterateToggle.
function iterateToggle_Callback(hObject, eventdata, handles)
% hObject    handle to iterateToggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvIterateCallback(hObject, eventdata, handles)
% Hint: get(hObject,'Value') returns toggle state of iterateToggle



function delayBox_Callback(hObject, eventdata, handles)
% hObject    handle to delayBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvDelayCallback(hObject, eventdata, handles)
% Hints: get(hObject,'String') returns contents of delayBox as text
%        str2double(get(hObject,'String')) returns contents of delayBox as a double


% --- Executes during object creation, after setting all properties.
function delayBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to delayBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in imageButton.
function imageButton_Callback(hObject, eventdata, handles)
% hObject    handle to imageButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvImagePanel(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of imageButton


% --- Executes on button press in makePlotButton.
function makePlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to makePlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvPlotPanel(hObject, eventdata, handles);


% --- Executes on slider movement.
function markerSizeSlider_Callback(hObject, eventdata, handles)
% hObject    handle to markerSizeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvMarkerSizeSliderCallback(hObject, eventdata, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function markerSizeSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markerSizeSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in imageTypeMenu.
function imageTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to imageTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imageTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imageTypeMenu


% --- Executes during object creation, after setting all properties.
function imageTypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imageTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in autoSizeMarkerCheckbox.
function autoSizeMarkerCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to autoSizeMarkerCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvAutoSizeMarkerCheckboxCallback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of autoSizeMarkerCheckbox


% --- Executes on selection change in markerTypeMenu.
function markerTypeMenu_Callback(hObject, eventdata, handles)
% hObject    handle to markerTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvMarkerTypeMenuCallback(hObject, eventdata, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns markerTypeMenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from markerTypeMenu


% --- Executes during object creation, after setting all properties.
function markerTypeMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markerTypeMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in legendButton.
function legendButton_Callback(hObject, eventdata, handles)
% hObject    handle to legendButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gvLegendPanel(hObject, eventdata, handles)
