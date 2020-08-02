function nii_batch(hObject,handles)
handles.folders=uipickfiles('Prompt','Select raw patient folders');
if ~isfield(handles,'folders')
    return
end
% outputd=uigetdir2('Select output folder');
% if outputd==0
%     return
% end
ind=strfind(handles.folders{end},'\');
folderTemp=handles.folders{end}(1:ind(end));
set(handles.current_folder,'String',[folderTemp]);
set(handles.current_folder,'ForegroundColor','k');
set(handles.current_folder,'BackgroundColor',[ 228 240 230 ]/255);
%%
for f=1:length(handles.folders);
    thisfolder=handles.folders{f};
    try 
        nii_single(thisfolder);
    catch
        disp(['nii did not succeed for:' thisfolder])
        continue
    end
    thisfolder
    
end
% for f=1:length(handles.folders);
%     thisfolder=handles.folders{f};
%     d = dir(thisfolder);
%     d(1:2)=[];
%     isub = [d(:).isdir];
%     isub=double(isub);
%     if mean(isub)>0.5; %# are there folders inside
%         nameFolds = {d(:).name}';
%
%         for sf=1:length(nameFolds)
%             thisSubfolder=[ thisfolder '\' nameFolds{sf}];
%             nii_single(thisSubfolder);thisSubfolder
%         end
%
%     else
%         nii_single(thisfolder);thisfolder
%     end
% end
