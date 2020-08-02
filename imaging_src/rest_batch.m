function rest_batch(hObject,handles)

handles.folders=uipickfiles('Prompt','Select converted patient folders');
if ~isfield(handles,'folders')
    return
end
ind=strfind(handles.folders{end},'\');
folderTemp=handles.folders{end}(1:ind(end));
set(handles.current_folder,'String',[folderTemp]);
set(handles.current_folder,'ForegroundColor','k');
set(handles.current_folder,'BackgroundColor',[ 228 240 230 ]/255);
%%

for f=1:length(handles.folders);
    thisfolder=handles.folders{f};
    d = dir(thisfolder);
    d(1:2)=[];
    isub = [d(:).isdir];
    isub=double(isub);
    if mean(isub)>0.5; %# are there folders inside
        nameFolds = {d(:).name}';
        
        for sf=1:length(nameFolds)
            
            thisSubfolder=[ thisfolder '\' nameFolds{sf}];
            handles.folderN=thisSubfolder;
            run_rest(hObject,handles);%thisSubfolder
        end
        
    else
        handles.folderN=thisfolder;
        run_rest(hObject,handles);    
    end
end