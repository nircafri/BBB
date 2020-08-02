function SPM_batch(hObject,handles)
nrun = 1; % enter the number of runs here
jobfile = {'spm12_batch_football_job.m'};
jobs = repmat(jobfile, 1, nrun);
%%
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
            try
                SPM_single(thisSubfolder);
            catch
                disp(['spm did not succeed for:' thisfolder])
                continue
            end
            thisSubfolder
        end
        
    else
        try
            SPM_single(thisfolder, get(handles.inf,'Value'));thisfolder
        catch
            disp(['spm did not succeed for:' thisfolder])
            continue
        end
    end
end
                 
