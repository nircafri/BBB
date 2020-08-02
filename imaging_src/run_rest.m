function run_rest(hObject,handles)
disp(['Running folder: ' handles.folderN]);
allnames=cellstr(ls(handles.folderN));
%% folder load
fnames.deg={};
handles.deg=[];
for i=3:length(allnames);
    this_file=allnames{i};
    if ~isempty(strfind(this_file,'deg') ) && (strcmp(this_file(end-2:end),'img') || strcmp(this_file(end-2:end),'nii') )
        fnames.deg{length(fnames.deg)+1,1}=[allnames{i}];
        in=strfind(allnames{i},'deg');
        thisnum=allnames{i}(in-2:in-1);
        thisnum(strfind(thisnum,'_'))=[];
        handles.deg=[handles.deg str2num(thisnum)];
    end
end
handles.deg=unique(handles.deg)';

% if length(handles.deg)<2
%     msgbox('At least 2 deg files are required');
%     return;
% end
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

set(handles.folder,'String',[handles.folderN]);
set(handles.folder,'ForegroundColor','k');
set(handles.folder,'BackgroundColor',[ 228 240 230 ]/255);
%% 
    handles=t1_calc_Callback(hObject,handles);
    ct_calc_Callback(hObject,handles);   
%     handles=tofts_calc_Callback(hObject,handles);
%     handles=linear_calc_Callback(hObject,handles);
