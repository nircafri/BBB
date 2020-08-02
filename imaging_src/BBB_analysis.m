function varargout = BBB_analysis(varargin)
% BBB_ANALYSIS MATLAB code for BBB_analysis.fig
%      BBB_ANALYSIS, by itself, creates a new BBB_ANALYSIS or raises the existing
%      singleton*.
%
%      H = BBB_ANALYSIS returns the handle to a new BBB_ANALYSIS or the handle to
%      the existing singleton*.
%
%      BBB_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BBB_ANALYSIS.M with the given input arguments.
%
%      BBB_ANALYSIS('Property','Value',...) creates a new BBB_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BBB_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BBB_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BBB_analysis

% Last Modified by GUIDE v2.5 07-Nov-2016 12:31:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @BBB_analysis_OpeningFcn, ...
    'gui_OutputFcn',  @BBB_analysis_OutputFcn, ...
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


function BBB_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BBB_analysis (see VARARGIN)





% Choose default command line output for BBB_analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

function varargout = BBB_analysis_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function run_Callback(hObject, eventdata, handles)
% hObject    handle to run (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.folderN=get(handles.current_folder,'String');
if ~exist(handles.folderN,'dir')
    msgbox('Choose patient folder first')
    return
end

allnames=cellstr(ls(handles.folderN));
fnames.deg={};
handles.deg=[];
IsDicomFolder=sum(cellfun(@(x) x(1)=='S' && x(end)=='0', allnames))>10;

if IsDicomFolder
    
    for k=3:length(allnames)
        d=dir([handles.folderN '\' allnames{k}]);
        if length(d)>1000
            info=dicominfo([handles.folderN '\' allnames{k} '\' d(end-1).name]);
            if ~isempty(strfind(info.ProtocolName,'dyn'))
                dt=round(info.AcquisitionDuration/info.NumberOfTemporalPositions);
                ang=info.FlipAngle;
                set(handles.dt,'String',dt);
                set(handles.angle2,'String',ang);
                break
            end
        end
    end
elseif ~all(cellfun(@isempty,strfind(allnames,'nii')))   % case of loading nifti folder
    for k=3:length(allnames)
        this_file=allnames{k};
        if ~isempty(strfind(this_file,'deg') ) && (strcmp(this_file(end-2:end),'img') || strcmp(this_file(end-2:end),'nii') )
            fnames.deg{length(fnames.deg)+1,1}=[allnames{k}];
            in=strfind(allnames{k},'deg');
            thisnum=allnames{k}(in-2:in-1);
            thisnum(strfind(thisnum,'_'))=[];
            handles.deg=[handles.deg str2num(thisnum)];
        end
    end
    d1=dir(fileparts(handles.folderN));
    dicom_path=[fileparts(handles.folderN) '\' d1(~cellfun('isempty',strfind({d1.name},'DICOM'))).name];
    allnames=cellstr(ls(strcat(dicom_path)));
    if length(allnames)>100                      % data from console and not from intellispace
        [info_file,info_path,~]=uigetfile('*.*','Data from console. choose manually a file from DINAMIC sequence' ,dicom_path);
        info=dicominfo([info_path '\' info_file]);
    else
        for k=4:length(allnames)
            d=dir([dicom_path '\' allnames{k}]);
            if length(d)>1000
                info=dicominfo([dicom_path '\' allnames{k} '\' d(end-1).name]);
                if ~isempty(strfind(info.ProtocolName,'dyn'))
                    break
                end
            end
        end
    end
    if exist('info')~=1
            load([handles.folderN '\info.mat']);
    end
    try
        dt=round(info.AcquisitionDuration/info.NumberOfTemporalPositions);
    catch
        dt=inputdlg('Enter dt value:','Manual dt value',[1 40]);
    end
    try
        ang=info.FlipAngle;
    catch
        ang=inputdlg('Enter dynamic flip angle value:','Manual flip angle',[1 40]);
    end
    set(handles.dt,'String',dt);
    set(handles.angle2,'String',ang);
else                                % case of loading different folder
    msgbox({'This is not our regular folder, values should inserted manually:';
        'dt, dynamic angle, flip angles sacns'});
end

handles.deg=unique(handles.deg)';
if length(handles.deg)<2
    msgbox(['At least 2 deg files are required for T1 map calculation,'...
        'you can only perform nii conversion at this point']);
    
    %     return;
else
    angs=[num2str(handles.deg(1))];
    for n=2:length(handles.deg)
        angs=[ angs ';' num2str(handles.deg(n))];
    end
    set(handles.tr1,'String','10');
    set(handles.angle1,'String',angs);
    set(handles.tr2,'String','4');
    if isempty(get(handles.angle2,'string'))
        set(handles.angle2,'String','20');
    end
end

%% Anonymize
if get(handles.anonymize, 'Value')
    dicomdict('set',fullfile(pwd,'dicom-dict-BBB.txt'));
    if ~(exist(get(handles.destination,'string'))==7)  % destination path is folder
        msgbox('First choose destination folder');
        return;
    end
    if ~(exist(get(handles.index,'string'))==2)        % index path is a file
        msgbox('First choose index file');
        return;
    end
    
    anon_new_subject(handles.folderN,get(handles.index,'string'),get(handles.destination,'string'));
end

%% nii
if get(handles.nii, 'Value');
    %
      system('dcm2niix.exe')
    nir_DeletingXXCopy(handles.folderN)
%     system('C:\Users\nircaf\Desktop\Nir\imaging_src\dcm2niix.exe')
 
    %
    NiftiFolder=nii_single(handles.folderN);
    set(handles.current_folder, 'String', NiftiFolder);
    handles.folderN=get(handles.current_folder,'String');
 
    %% 
    %   This section searchs again for files in the new folder that
    %   automatically changed. It has copied from function folder_ButtonDownFcn
    allnames=cellstr(ls(handles.folderN));
    fnames.deg={};
    handles.deg=[];
    for i=3:length(allnames);
        this_file=allnames{i};
        if strcmp(this_file(end-2:end),'img') || strcmp(this_file(end-2:end),'nii')
            if ~isempty(strfind(this_file,'deg') )
                fnames.deg{length(fnames.deg)+1,1}=[allnames{i}];
                in=strfind(allnames{i},'deg');
                thisnum=allnames{i}(in-2:in-1);
                thisnum(strfind(thisnum,'_'))=[];
                handles.deg=[handles.deg str2num(thisnum)];
            end
        end
    end
    handles.deg=unique(handles.deg)';
    if length(handles.deg)<2
        msgbox(['At least 2 deg files are required for T1 map calculation,'...
            'you can only perform nii conversion at this point']);
        %     return;
    else
        angs=[num2str(handles.deg(1))];
        for n=2:length(handles.deg)
            angs=[ angs ';' num2str(handles.deg(n))];
        end
        set(handles.tr1,'String','10');
        set(handles.angle1,'String',angs);
        set(handles.tr2,'String','4');
        set(handles.angle2,'String','20');
    end
    set(handles.current_folder,'Visible','on');
    set(handles.openf,'Visible','on');

    set(handles.current_folder,'String',[handles.folderN]);
    set(handles.current_folder,'ForegroundColor','k');
    set(handles.current_folder,'BackgroundColor','w');
    set(hObject,'ForegroundColor','k');
    set(hObject,'BackgroundColor','w');
    guidata(hObject, handles);
end

%% SPM
% dbstop in I:\TIA_Anat_Horev_Ofer\01Results\AA_7621_F\20200630094723_1201_DESPOT1_3deg_DESPOT1_3deg.nii;
if get(handles.spm, 'Value');
 SPM_single(handles.folderN, get(handles.inf,'Value'));
end
%% ROI
if get(handles.roi,'Value');
    dissable_axs(hObject,handles);
    if get(handles.inf,'Value');
        handles=roi_calc_Callback_infant(hObject,handles);
    else
        handles=roi_calc_Callback(hObject,handles);
    end
    update_display_aif(handles);
end
%% T1
if get(handles.t1, 'Value');
    dissable_axs(hObject,handles);
    if get(handles.inf,'Value');
        handles=t1_calc_Callback_infant(hObject,handles);
    else
        handles=t1_calc_Callback(hObject,handles);
    end
    update_display_t1(handles);
end
%% CT calculation
if get(handles.Ct,'Value');
    dissable_axs(hObject,handles);
    if get(handles.inf,'Value');
        ct_calc_Callback_infant(hObject,handles);
    else
        ct_calc_Callback(hObject,handles);
    end
end
%% Linear
if get(handles.linear,'Value');
    dbstop if error
    dissable_axs(hObject,handles)
    handles=linear_calc_Callback(hObject,handles);
end
%% Tofts
if get(handles.tofts,'Value');
    dissable_axs(hObject,handles)
    handles=tofts_calc_Callback(hObject,handles);
%     CopyResults(handles.folderN);
end
guidata(hObject,handles);

function mark_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to mark_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = imfreehand(handles.im_axes);
handles.mask = createMask(h);
slice = round(get(handles.slice_slider,'Value'));
handles.mask_slice = slice;
times = size(handles.im_mat,4);
handles.roi_vals = zeros(times,1);
for t = 1:times
    tmp = handles.im_mat(:,:,slice,t);
    handles.roi_vals(t) = mean(tmp(handles.mask));
end
if(exist(fullfile(handles.folderN,'C_t.mat'),'file')) %% then display Ct of ROI
    if(strcmp(questdlg('C_t file exists, display Ct values of ROI?','Yes','No'),'Yes'))
        disp('using stored Ct data');
        if(~isfield(handles,'ct_data'))
            disp('loading C_t file');
            handles.ct_data = load(fullfile(handles.folderN,'C_t.mat'),'Ct');
        end
        for n = 1:length(handles.ct_data.Ct)
            tmp = handles.ct_data.Ct{n}(:,:,slice);
            disp_vals(n) = mean(tmp(handles.mask));
        end
        plot(handles.aif_axes,disp_vals);
    else
        plot(handles.aif_axes,handles.roi_vals);
    end
else
    plot(handles.aif_axes,handles.roi_vals);
end
set(handles.aif_axes,'Visible','on');
set(handles.aif_axes,'Xcolor','w','YColor','w');
set(handles.aif_roi_button,'Visible','on');
set(handles.vif_roi_button,'Visible','on');
guidata(hObject,handles);


function aif_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_as_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% [fname fpath]=uiputfile([handles.folderN '\*.mat'],'Save Results');
orig_path = handles.folderN;
roi_vals = handles.roi_vals;
roi_mask = handles.mask;
mask_slice = handles.mask_slice;
if hObject==handles.aif_roi_button
    handles.roifile=fullfile(handles.folderN,['AIF_ROI_generated_on_' datestr(now,30)]);
else
    handles.roifile=fullfile(handles.folderN,['VIF_ROI_generated_on_' datestr(now,30)]);
end
save(handles.roifile,'orig_path','roi_vals','roi_mask','mask_slice');
disp(['Results saved in: ' handles.roifile]);
guidata(hObject,handles);

function update_display_aif(handles)
if isfield(handles,'im_mat')
    slice = round(get(handles.slice_slider,'Value'));
    time = round(get(handles.time_slider,'Value'));
    set(handles.slice_text,'String',num2str(slice));
    set(handles.time_text,'String',num2str(time));
    imagesc(handles.im_mat(:,:,slice,time),'Parent',handles.im_axes,[ 0 170000]);
    set(handles.im_axes,'DataAspectRatio',[1 1 1]);
    axis(handles.im_axes,'off');%or image
    cLow=str2double(get(handles.cLow,'String'));
    cHigh=str2double(get(handles.cHigh,'String'));
    if isnan(cLow)
        clims = get(handles.im_axes, 'CLim');
        cLow=clims(1);
        cHigh=clims(2);
        set(handles.cLow,'String',cLow);
        set(handles.cHigh,'String',cHigh);
    end
    set(handles.im_axes, 'CLim', [cLow, cHigh]);
    colormap gray;
end

function update_display_t1(handles)
if isfield(handles,'im_mat')

slice = round(get(handles.slice_slider,'Value'));
set(handles.slice_text,'Visible','on');

imagesc(real(handles.im_mat(:,:,slice)),'Parent',handles.im_axes,[ 250 3500]);
title('T1 Map','color','w','Parent',handles.im_axes);
set(handles.slice_text,'String',num2str(slice));
axis(handles.im_axes,'image');  colorbar('peer',handles.im_axes);
colormap  jet;
end

function dissable_axs(hObject,handles)
set(handles.im_axes,'visible','off');
set(handles.aif_axes,'visible','off');
set(handles.mark_roi_button,'Visible','off');
set(handles.slice_text,'Visible','off');
set(handles.time_text,'Visible','off');
set(handles.text25,'Visible','off');
set(handles.text27,'Visible','off');
set(handles.time_slider,'Visible','off');
set(handles.aif_roi_button,'Visible','off');
set(handles.vif_roi_button,'Visible','off');
set(handles.excluded,'Visible','off');
set(handles.x,'Visible','off');
set(handles.v,'Visible','off');
guidata(hObject,handles);


function tr1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function angle1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function tr2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function angle2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to angle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function start_scan_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function folder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function folder_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.folderN=uigetdir2;
if ~handles.folderN
    return
end
allnames=cellstr(ls(handles.folderN));
%%
fnames.deg={};
handles.deg=[];
IsDicomFolder=sum(cellfun(@(x) x(1)=='S' && x(end)=='0', allnames))>10;
if IsDicomFolder
    for k=3:length(allnames)
        d=dir([handles.folderN '\' allnames{k}]);
        if length(d)>1000
            info=dicominfo([handles.folderN '\' allnames{k} '\' d(end-1).name]);
            if ~isempty(strfind(info.ProtocolName,'dyn'))
                dt=round(info.AcquisitionDuration/info.NumberOfTemporalPositions);
                set(handles.dt,'String',dt);
                break
            end
        end
    end
elseif ~all(cellfun(@isempty,strfind(allnames,'nii')))   % case of loading nifti folder
    for k=3:length(allnames)
        this_file=allnames{k};
        if ~isempty(strfind(this_file,'deg') ) && (strcmp(this_file(end-2:end),'img') || strcmp(this_file(end-2:end),'nii') )
            fnames.deg{length(fnames.deg)+1,1}=[allnames{k}];
            in=strfind(allnames{k},'deg');
            thisnum=allnames{k}(in-2:in-1);
            thisnum(strfind(thisnum,'_'))=[];
            handles.deg=[handles.deg str2num(thisnum)];
        end
    end
    allnames=cellstr(ls([fileparts(handles.folderN) '\DICOM']));
    for k=3:length(allnames)
        d=dir([fileparts(handles.folderN) '\DICOM\' allnames{k}]);
        if length(d)>1000
            info=dicominfo([fileparts(handles.folderN) '\DICOM\' allnames{k} '\' d(end-1).name]);
            if ~isempty(strfind(info.ProtocolName,'dyn'))
                dt=round(info.AcquisitionDuration/info.NumberOfTemporalPositions);
                set(handles.dt,'String',dt);
                break
            end
        end
    end
    if exist('info')~=1
        load([handles.folderN '\info.mat']);
    end
    try
        dt=round(info.AcquisitionDuration/info.NumberOfTemporalPositions);
    catch
        dt=inputdlg('Enter dt value:','Manual dt value',[1 40]);
    end
    try
        ang=info.FlipAngle;
    catch
        ang=inputdlg('Enter flip angle value:','Manual dt value',[1 40]);
    end
    
    set(handles.dt,'String',dt);
    set(handles.angle2,'String',ang);
else                                % case of loading different folder
    msgbox({'This is not our regular folder, values should inserted manually:';
        'dt, dynamic angle, flip angles sacns'});
end

handles.deg=unique(handles.deg)';
if length(handles.deg)<2
    msgbox(['At least 2 deg files are required for T1 map calculation,'...
        'you can only perform nii conversion at this point']);
    
    %     return;
else
    angs=[num2str(handles.deg(1))];
    for n=2:length(handles.deg)
        angs=[ angs ';' num2str(handles.deg(n))];
    end
    set(handles.tr1,'String','10');
    set(handles.angle1,'String',angs);
    set(handles.tr2,'String','4');
    set(handles.angle2,'String','20');
end
ex{1}='Excluded'; ex{2}='None';
set(handles.excluded,'String',ex);       % initialize excluded list
set(handles.current_folder,'Visible','on');
set(handles.openf,'Visible','on');

set(handles.current_folder,'String',[handles.folderN]);
set(handles.current_folder,'ForegroundColor','k');
set(handles.current_folder,'BackgroundColor','w');
set(hObject,'ForegroundColor','k');
set(hObject,'BackgroundColor','w');
guidata(hObject, handles);

function slice_slider_Callback(hObject, eventdata, handles)

function slice_slider_Callback_t1(hObject, eventdata, handles)


function slice_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slice_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function time_slider_Callback(hObject, eventdata, handles)

function time_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to time_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function slice_text_Callback(hObject, eventdata, handles)
% hObject    handle to slice_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of slice_text as text
%        str2double(get(hObject,'String')) returns contents of slice_text as a double

function slice_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slice_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tr1_Callback(hObject, eventdata, handles)
% hObject    handle to tr1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of tr1 as text
%        str2double(get(hObject,'String')) returns contents of tr1 as a double



function angle1_Callback(hObject, eventdata, handles)
% hObject    handle to angle1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of angle1 as text
%        str2double(get(hObject,'String')) returns contents of angle1 as a double



function tr2_Callback(hObject, eventdata, handles)
% hObject    handle to tr2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of tr2 as text
%        str2double(get(hObject,'String')) returns contents of tr2 as a double



function angle2_Callback(hObject, eventdata, handles)
% hObject    handle to angle2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of angle2 as text
%        str2double(get(hObject,'String')) returns contents of angle2 as a double


% --- Executes on button press in t1.
function t1_Callback(hObject, eventdata, handles)
% hObject    handle to t1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of t1


% --- Executes on button press in spm.
function spm_Callback(hObject, eventdata, handles)
% hObject    handle to spm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of spm


% --- Executes on button press in ct.
function ct_Callback(hObject, eventdata, handles)
% hObject    handle to ct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of ct


% --- Executes on button press in roi.
function roi_Callback(hObject, eventdata, handles)
% hObject    handle to roi (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of roi


% --- Executes on button press in tofts.
function tofts_Callback(hObject, eventdata, handles)
% hObject    handle to tofts (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of tofts


% --- Executes on button press in linear.
function linear_Callback(hObject, eventdata, handles)
% hObject    handle to linear (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of linear



function start_scan_Callback(hObject, eventdata, handles)
% hObject    handle to start_scan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of start_scan as text
%        str2double(get(hObject,'String')) returns contents of start_scan as a double


% --- Executes on button press in nii.
function nii_Callback(hObject, eventdata, handles)
% hObject    handle to nii (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of nii


% --- Executes on button press in vif_roi_button.
function vif_roi_button_Callback(hObject, eventdata, handles)
% hObject    handle to vif_roi_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Mode_Callback(hObject, eventdata, handles)
% hObject    handle to Mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function single_Callback(hObject, eventdata, handles)
% hObject    handle to single (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function batch_Callback(hObject, eventdata, handles)
% hObject    handle to batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in mode.
function mode_Callback(hObject, eventdata, handles)
% hObject    handle to mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns mode contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mode


% --- Executes during object creation, after setting all properties.
function mode_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nii_batch.
function nii_batch_Callback(hObject, eventdata, handles)
% hObject    handle to nii_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
nii_batch(hObject,handles)

% --- Executes on button press in spm_batch.
function spm_batch_Callback(hObject, eventdata, handles)
% hObject    handle to spm_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SPM_batch(hObject,handles)


% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Batch_rest.
function Batch_rest_Callback(hObject, eventdata, handles)
% hObject    handle to Batch_rest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rest_batch(hObject,handles)


% --- Executes on button press in x.
function x_Callback(hObject, eventdata, handles)
% hObject    handle to x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
time = round(get(handles.time_slider,'Value'));
set(handles.time_text,'String',num2str(time));
ex=get(handles.excluded,'String');
ex{end+1}=num2str(time);
if strcmp(ex{2},'None')
    ex(2)=[];
end
set(handles.excluded,'String',ex);

% --- Executes on button press in v.
function v_Callback(hObject, eventdata, handles)
% hObject    handle to v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ind=get(handles.excluded,'Value');
ex=get(handles.excluded,'String');
ex(ind)=[];
set(handles.excluded,'String',ex,'Value', 1);
if length(get(handles.excluded,'String'))==1
    ex=get(handles.excluded,'String');
    ex{2}='None';
    set(handles.excluded,'String',ex);
end


% --- Executes on selection change in excluded.
function excluded_Callback(hObject, eventdata, handles)
% hObject    handle to excluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ind=get(handles.excluded,'Value');
ex=get(handles.excluded,'String');
time=str2num(ex{ind});
set(handles.time_slider,'Value',time);
update_display_aif(handles)



% Hints: contents = cellstr(get(hObject,'String')) returns excluded contents as cell array
%        contents{get(hObject,'Value')} returns selected item from excluded


% --- Executes during object creation, after setting all properties.
function excluded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to excluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nii_batch.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to nii_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in spm_batch.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to spm_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton14.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in Batch_rest.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to Batch_rest (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function folder_Callback(hObject, eventdata, handles)
% hObject    handle to folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of folder as text
%        str2double(get(hObject,'String')) returns contents of folder as a double
folder_ButtonDownFcn(hObject, eventdata, handles)


% --- Executes on key press with focus on folder and none of its controls.
function folder_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to folder (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)


function current_folder_Callback(hObject, eventdata, handles)
% hObject    handle to current_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of current_folder as text
%        str2double(get(hObject,'String')) returns contents of current_folder as a double
winopen(get(handles.current_folder,'String'));

% --- Executes during object creation, after setting all properties.
function current_folder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over current_folder.
function current_folder_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to current_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
winopen(get(handles.current_folder,'String'));


% --- Executes on key press with focus on current_folder and none of its controls.
function current_folder_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to current_folder (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
winopen(get(handles.current_folder,'String'));


% --- Executes on button press in openf.
function openf_Callback(hObject, eventdata, handles)
% hObject    handle to openf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
winopen(get(handles.current_folder,'String'));



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to current_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of current_folder as text
%        str2double(get(hObject,'String')) returns contents of current_folder as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in openf.
function pushbutton16_Callback(hObject, eventdata, handles)
% hObject    handle to openf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function cHigh_Callback(hObject, eventdata, handles)
update_display_aif(handles);


% --- Executes during object creation, after setting all properties.
function cHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cLow_Callback(hObject, eventdata, handles)
update_display_aif(handles);

% --- Executes during object creation, after setting all properties.
function cLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in inf.
function inf_Callback(hObject, eventdata, handles)
% hObject    handle to inf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of inf


% --- Executes during object creation, after setting all properties.
function uipanel10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in anonymize.
function anonymize_Callback(hObject, eventdata, handles)
% hObject    handle to anonymize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of anonymize



function source_Callback(hObject, eventdata, handles)
% hObject    handle to source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of source as text
%        str2double(get(hObject,'String')) returns contents of source as a double


% --- Executes during object creation, after setting all properties.
function source_CreateFcn(hObject, eventdata, handles)
% hObject    handle to source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function destination_Callback(hObject, eventdata, handles)
% hObject    handle to destination (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of destination as text
%        str2double(get(hObject,'String')) returns contents of destination as a double


% --- Executes during object creation, after setting all properties.
function destination_CreateFcn(hObject, eventdata, handles)
% hObject    handle to destination (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function index_Callback(hObject, eventdata, handles)
% hObject    handle to index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of index as text
%        str2double(get(hObject,'String')) returns contents of index as a double


% --- Executes during object creation, after setting all properties.
function index_CreateFcn(hObject, eventdata, handles)
% hObject    handle to index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object deletion, before destroying properties.
function uipanel10_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to uipanel10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function uipanel10_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to uipanel10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in anonymize_explanation.
function anonymize_explanation_Callback(hObject, eventdata, handles)
% hObject    handle to anonymize_explanation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=msgbox({'Destination folder- a folder that will contain the anonymized data'...
'Index file- a file that save all the original details with the appropriate initials'},'HELP','help');

% --- Executes on button press in Ct.
function Ct_Callback(hObject, eventdata, handles)
% hObject    handle to Ct (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of Ct



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton17.
function radiobutton17_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton17


% --- Executes on button press in radiobutton18.
function radiobutton18_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton18



function edit23_Callback(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit23 as text
%        str2double(get(hObject,'String')) returns contents of edit23 as a double


% --- Executes during object creation, after setting all properties.
function edit23_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit23 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit24_Callback(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit24 as text
%        str2double(get(hObject,'String')) returns contents of edit24 as a double


% --- Executes during object creation, after setting all properties.
function edit24_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit24 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radiobutton19.
function radiobutton19_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton19


% --- Executes on button press in radiobutton20.
function radiobutton20_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton20


% --- Executes on button press in select_source.
function select_source_Callback(hObject, eventdata, handles)
% hObject    handle to select_source (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.source_folder=uigetdir2('','Select source folder (DICOM):');
if ~handles.source_folder
    return
end
set(handles.source,'string',[handles.source_folder]);


% --- Executes on button press in select_destination.
function select_destination_Callback(hObject, eventdata, handles)
% hObject    handle to select_destination (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dest_folder=uigetdir2('','Select destination folder:');
if ~handles.dest_folder
    return
end
set(handles.destination,'string',[handles.dest_folder]);
guidata(hObject, handles);



% --- Executes on button press in select_index.
function select_index_Callback(hObject, eventdata, handles)
% hObject    handle to select_index (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path]=uigetfile('F:\Research\*.xlsx','Select index file:');
handles.index_folder=[path file];
if ~handles.index_folder
    return
end
set(handles.index,'string',[handles.index_folder]);
guidata(hObject, handles);



function dt_Callback(hObject, eventdata, handles)
% hObject    handle to dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of dt as text
%        str2double(get(hObject,'String')) returns contents of dt as a double


% --- Executes during object creation, after setting all properties.
function dt_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dt (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
