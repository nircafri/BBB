function handles=linear_calc_Callback(hObject,handles)

%% FIND LAST MODIFIED VIF FILE
allnames=cellstr(ls(handles.folderN));
di=dir(handles.folderN);
files.vif={};
num=[];
for i=3:length(allnames);
    this_file=allnames{i};
    if strcmp(this_file(end-2:end),'mat') && ...
            strcmp(this_file(1:3),'VIF')
       files.vif{length(files.vif)+1,1}=[allnames{i}];
       num(length(num)+1)=di(i).datenum;
    end
   end ;

if isempty(files.vif)
    msgbox('No VIF file in the folder')
    return;
end
[a b] =max(num);
mask_name=files.vif{b};

load(fullfile(handles.folderN,mask_name),'roi_mask','mask_slice');
%%
ct_path=handles.folderN;
ct_name= 'C_t.mat';
if ~exist(fullfile(ct_path,ct_name))
    msgbox('C_t.mat file not found');
    return
end

%% load CT mat file

Ct = load(fullfile(ct_path,ct_name),'Ct');
Ct = Ct.Ct;

%% build reference ROI
for t = 1:length(Ct)
    tmp = real(Ct{t}(:,:,mask_slice));
    full_VIF(t) = mean(tmp(roi_mask));
end

%%  Find start_scan

dt=str2double(get(handles.dt,'String'));


if get(handles.inf,'Value')
    set(handles.start_scan,'String',eval(get(handles.dt,'String'))*length(Ct)*360/1000);
end
start_scan_in=eval(get(handles.start_scan,'String'));      % sec

max_ind = find(full_VIF == max(full_VIF));                 % find maximal point
start_scan = max_ind+round(start_scan_in/dt)-1;            % after injection  

disp(['Fitting from t= ' num2str(start_scan_in/dt) '[sec]']);
%% Which frames to exclude
ex=get(handles.excluded,'String');
exclude=str2double(ex)';
exclude=exclude(~isnan(exclude))
exclude=exclude-start_scan+1;
exclude=sort(exclude);
exclude(exclude<1)=[];
%% Find VIF slope and int

roi_vals = full_VIF(start_scan:end);
times = length(Ct)-start_scan+1;
time_vec=1:times;

time_vec(exclude)=[];
roi_vals(exclude)=[];

pol = polyfit(time_vec, roi_vals,1);
roi_slope = pol(1);
roi_int = pol(2);
r_sq = 1- ( sum((polyval(pol,time_vec)- roi_vals).^2)...
    /sum((mean(roi_vals)- roi_vals).^2) );
plot(roi_vals,'.-','Parent',handles.aif_axes);
disp(['r_sq=' num2str(r_sq)]);


%% rearrange data
disp('Rearranging data...');
slices = size(Ct{1},3);
for sl = 1:slices
    for t = 1:times
        ct_pass{sl}(:,:,t) = real(Ct{t+start_scan-1}(:,:,sl));
    end
    disp(sl);
end
disp('Rearranging data done');

%%
r = size(Ct{1},1);
c = size(Ct{1},2);
res = zeros(r,c,slices,2);
R_2 = zeros(r,c,slices);

if isempty(gcp('nocreate'))
  parpool
end
tic
parfor s = 1:slices
    disp(s);
    im_mat=ct_pass{s};
    [p_tmp, R_2_tmp] = lin_fit(im_mat,time_vec);
    p_tmp(:,:,1,2) = p_tmp(:,:,1,2)/roi_int;
    p_tmp(:,:,1,1) = p_tmp(:,:,1,1)/roi_slope;
    p(:,:,s,:) = p_tmp;
    R_2(:,:,s) = R_2_tmp;
end
toc

p(:,:,:,3)=p(:,:,:,1)*(roi_slope^2)/(dt^2);     % p(:,:,:,3) is the multiplication of voxel slope and VIF slope
p(:,:,:,4)=-(p(:,:,:,1)*roi_slope-roi_slope);   %p(:,:,:,4) is the difference between voxel slope and VIF slope
% The "minus" is for compatibility with dimensions 1 and 3, for using
    % in plot_multiple_slices.m and other functions
p(:,:,:,5)=-p(:,:,:,1)*roi_slope;               % p(:,:,:,5) is the "raw", unnormalized slopes.

%%
pat_name=handles.folderN;
ind=strfind(pat_name,'\');
pat_name=pat_name(ind(end)+1:end);
disp('Saving...');
if isempty(exclude)
    exstr='_none';
else
exstr= num2str(exclude+start_scan-1);
exstr(strfind(exstr,' '))='_';
end
linearfile=[ pat_name '_Linear_for_' mask_name(1:end-4) '_excluding(' exstr ').mat'];

save(fullfile(ct_path,linearfile),'ex','ct_path','ct_name','roi_vals','roi_slope','roi_int',...
    'start_scan','p','R_2','max_ind','start_scan','dt','full_VIF');
disp(['Saved in : ' linearfile]);
if get(handles.inf,'Value');
    plot_multiple_slices_infant(fullfile(ct_path,linearfile),handles.folderN,exstr);
else
    plot_multiple_slices(fullfile(ct_path,linearfile),handles.folderN, exstr);
end
disp('Linear done');
