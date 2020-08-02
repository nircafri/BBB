function handles=tofts_calc_Callback(hObject,handles);
 
 %%
allnames=cellstr(ls(handles.folderN));
di=dir(handles.folderN);
files.aif={};
num=[];
for i=3:length(allnames);
    this_file=allnames{i};
    if strcmp(this_file(end-2:end),'mat') && ...
            strcmp(this_file(1:3),'AIF')
        files.aif{length(files.aif)+1,1}=[allnames{i}];
        num(length(num)+1)=di(i).datenum;
    end
end ;

if isempty(files.aif)
    msgbox('No AIF file in the folder')
    return;
end
[a b] =max(num);
mask_name=files.aif{b};
%%
load(fullfile(handles.folderN,mask_name),'roi_mask','mask_slice');
%%
ct_path=handles.folderN;
ct_name= 'C_t.mat';
if ~exist(fullfile(ct_path,ct_name))
    msgbox('C_t.mat file not found');
    return
end
Ct = load(fullfile(ct_path,ct_name),'Ct');
Ct = Ct.Ct;



dt=str2double(get(handles.dt,'String'));
% if ~isa(dt,'double')
%     dt=10;%sec
% end
%convert to min
dt = dt/60 % [convert to min]

% lin_res = load(fullfile(linear_path,linear_name),'an_data','gm','wm','csf','mask_slice','roi_mask');
% an_data = lin_res.an_data;
% gm = lin_res.gm;
% wm = lin_res.wm;
% csf = lin_res.csf;
%% Which frames to exclude
ex=get(handles.excluded,'String');
if ~strcmp(ex(2),'None');
    ex(1)=[];
    for e=1:length(ex)
        exclude(e)=str2num(ex{e});
    end
else
    exclude=[];
end
%%
r = size(Ct{1},1);
c = size(Ct{1},2);
% %% build reference ROI
for t = 1:length(Ct)
    tmp = real(Ct{t}(:,:,mask_slice));
    full_aif(t) = mean(tmp(roi_mask));
end
time_vec=1:length(Ct);
time_vec(exclude)=[];
%% rearrange data
disp('Rearranging data...');
slices = size(Ct{1},3);
times = length(Ct);
for sl = 1:slices
    for t = 1:times
        ct_pass{sl}(:,:,t) = real(Ct{t}(:,:,sl));
    end
    disp(sl);
end
disp('Rearranging data done');

kt = zeros(size(ct_pass{1},1),size(ct_pass{1},2),slices);
kep = zeros(size(ct_pass{1},1),size(ct_pass{1},2),slices);
vp = zeros(size(ct_pass{1},1),size(ct_pass{1},2),slices);

rows = size(ct_pass{1},1);
cols = size(ct_pass{1},2);
tic

gcp('nocreate');
parfor sl = 1:slices
    [kt_tmp,kep_tmp,vp_tmp] = calc_perm_slice(ct_pass{sl}, full_aif,dt,time_vec);
    kt(:,:,sl) = kt_tmp;
    kep(:,:,sl) = kep_tmp;
    vp(:,:,sl) = vp_tmp;
    disp(sl);
end
toc
disp('Done');
disp('Saving...');
%%
pat_name=handles.folderN;
ind=strfind(pat_name,'\');
pat_name=pat_name(ind(end)+1:end);
if isempty(exclude)
    exstr='_none';
else
exstr= num2str(exclude);
exstr(strfind(exstr,' '))='_';
end

toftsfile=[pat_name '_Tofts_for_' mask_name(1:end-4) '_excluding(' exstr ').mat'];

save(fullfile(handles.folderN,toftsfile),'ex','kt','kep','vp','dt','full_aif');
disp(['Saved in : ' toftsfile]);
if get(handles.inf,'Value');
    plot_multiple_slices_infant(fullfile(handles.folderN,toftsfile),handles.folderN,exstr);
else
    plot_multiple_slices(fullfile(handles.folderN,toftsfile),handles.folderN,exstr);
end
disp('Tofts done');
