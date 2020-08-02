function nii_batch_Callback(hObject,handles)
%%
handles.folders=uipickfiles('Prompt','Select folders with raw dicom data');
if isempty( handles.folders)
    msgbox('No patients selected');
    return;
end
ind=strfind(handles.folders{end},'\');
folderTemp=handles.folders{end}(1:ind(end));
set(hObject,'String',[folderTemp]);
set(hObject,'ForegroundColor','k');
set(hObject,'BackgroundColor',[ 228 240 230 ]/255);
%%

outputd=uigetdir2('Select output folder');
if outputd==0
    return
end
for i=1:length(handles.folders)
    thisfolder=handles.folders{i};
    cmdstr = sprintf('!dcm2niix -z n -o "%s" -f %%t_%%s_%%d%%p "%s"',outputd,thisfolder);

    eval(cmdstr)
end
