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

%% find anatomy and segmentation files (instead of using files = lbox2;)
allnames=cellstr(ls(handles.folderN));
files.anatomy={};
files.segment={};
for i=3:length(allnames);
    this_file=allnames{i};
    if strcmp(this_file(end-2:end),'img') && strcmp(this_file(1:2),'wr') &&...
            ~isempty(strfind(this_file,'NAV') )
        files.anatomy{length(files.anatomy)+1,1}=[allnames{i}];
    end
    for ord=1:4
        if ~isempty(strfind(this_file,['c' num2str(ord) 'wr']) )
            files.segment{ord}=[handles.folderN '\' allnames{i}];
        end
    end
end ;
%% find first anatomy (401)
nums=[];
for i=1:length(files.anatomy)
    in=strfind(files.anatomy{i},'_T1_NAV');
    thisnum=files.anatomy{i}(in-4:in-1);
    if strcmp(thisnum(1),'_');
        thisnum(1)=[];
    end
    nums=[ nums   str2num(thisnum)];
end
[a b] =min(nums);
files.anatomy=[  handles.folderN '\' files.anatomy{b}];
%% load anatomy
nii = load_nii(files.anatomy);
for m = 1:size(nii.img,3)
    an_data(:,:,m) = fliplr(rot90(nii.img(:,:,m)));
end
%% load segmentation files
% segmentation
nii = load_nii(files.segment{1});
gm_tmp = nii.img;
nii = load_nii(files.segment{2});
wm_tmp = nii.img;
nii = load_nii(files.segment{3});
csf_tmp = nii.img;
nii = load_nii(files.segment{4});
frame_tmp = nii.img;
for i = 1:size(gm_tmp,3)
    gm(:,:,i) = fliplr(rot90(gm_tmp(:,:,i)));
    wm(:,:,i) = fliplr(rot90(wm_tmp(:,:,i)));
    csf(:,:,i) = fliplr(rot90(csf_tmp(:,:,i)));
    frame(:,:,i) = fliplr(rot90(frame_tmp(:,:,i)));
end

%%

% [linear_name,linear_path] = uigetfile('*.mat','Choose Linear res file file',ct_path);
%% load CT mat file

Ct = load(fullfile(ct_path,ct_name),'Ct');
Ct = Ct.Ct;

% lin_res = load(fullfile(linear_path,linear_name),'an_data','gm','wm','csf','mask_slice','roi_mask');

% an_data = lin_res.an_data;
% gm = lin_res.gm;
% wm = lin_res.wm;
% csf = lin_res.csf;


%% build reference ROI
for t = 1:length(Ct)
    tmp = real(Ct{t}(:,:,mask_slice));
    full_VIF(t) = mean(tmp(roi_mask));
end

%%  Find start_scan

dt=eval(get(handles.dt,'String'));
if ~isa(dt,'double')
    dt=10;%sec
end
start_scan_in=eval(get(handles.start_scan,'String'));%sec
max_ind = find(full_VIF == max(full_VIF)); %% find maximal point
start_scan = max_ind+start_scan_in/dt-1; %after injection

disp(['Fitting from t= ' num2str(start_scan_in/dt) '[sec]']);
%% Which frames to exclude
ex=get(handles.excluded,'String');
if ~strcmp(ex(2),'None');
    ex(1)=[];
    for e=1:length(ex)
        exclude(e)=str2num(ex{e});
    end
    exclude=exclude-start_scan+1;
    exclude=sort(exclude);
    exclude(exclude<1)=[];
else
    exclude=[];
end
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
% disp('Rearranging data...');
% slices = size(Ct{1},3);
% ct_pass={};
% for sl = 1:slices
%     for t = 1:times
%         ct_pass{sl}(:,:,t) = real(Ct{t+start_scan-1}(:,:,sl));
%     end
%     disp(sl);
% end
% disp('Rearranging data done');

% %% find slopes per slice
% r = size(Ct{1},1);
% c = size(Ct{1},2);
% res = zeros(r,c,slices,2);
% R_2 = zeros(r,c,slices);
% 
% if(matlabpool('size') == 0)
%     matlabpool;
% end
% 
% tic
% parfor s = 1:slices
%     disp(s);
%     im_mat=ct_pass{s};
%     [p_tmp, R_2_tmp] = lin_fit(im_mat,time_vec);
%     p_tmp(:,:,1,2) = p_tmp(:,:,1,2)/roi_int;
%     p_tmp(:,:,1,1) = p_tmp(:,:,1,1)/roi_slope;
%     p(:,:,s,:) = p_tmp;
%     R_2(:,:,s) = R_2_tmp;
% end
% toc
%% find aif
%% rearrange data full
disp('Rearranging data from t=1');
slices = size(Ct{1},3);
ct_pass={};
for sl = 1:slices
    for t = 1:100 % changed to include full trace
        ct_pass{sl}(:,:,t) = real(Ct{t}(:,:,sl));
    end
    disp(sl);
end
disp('Rearranging all data done');
r = size(Ct{1},1);
c = size(Ct{1},2);
max_val = zeros(r,c,slices);
area_under = zeros(r,c,slices);

if isempty(gcp('nocreate'))
  parpool
end
br_mask=nan*ones(size(gm));
% br_mask((gm+wm)>0.5)=1;
br_mask((gm+wm)>0.5)=1;
br_mask((gm+wm)<=0.5)=nan;
% br_mask=nan*ones(size(gm));
% br_mask(csf>0.4)=1;
% frame
frame_mask=0*ones(size(gm));
frame_mask(frame>0)=1;
se = strel('disk',13);


% par
for s = [9 12]
%% skull mask
% % closed_im=imclose(frame_mask(:,:,s),se);
% % closed_im=~closed_im;figure;
% % closed_im=frame_mask(:,:,12);imagesc(closed_im)
% % [labeledImage, numberOfBlobs] = bwlabel(closed_im);
% % blobMeasurements = regionprops(labeledImage, 'area');
% % allAreas = [blobMeasurements.Area];
% % [sortedAreas, sortIndexes] = sort(allAreas, 'descend');
% % temp_frame = double(ismember(labeledImage, sortIndexes(1)));
% % temp_frame(temp_frame<1)=nan;
% % figure;imagesc(temp_frame)
%% brain mask
    temp_br=br_mask(:,:,s);
    im_mat=ct_pass{s};
    for i=1:size(im_mat,3)
    im_mat2(:,:,i)=im_mat(:,:,i);%.*temp_br;
    end
    im_temp=reshape(im_mat2, 1 ,size(im_mat,1)*size(im_mat,2)*size(im_mat,3));
    stdTh=nanstd(im_temp);
    im_mat2(im_mat2>stdTh*2)=nan;
%     [area_under(:,:,s) max_val(:,:,s)] = seg_features(im_mat,time_vec);
    for n = 1:r
        for m = 1:c
            dat(1:100,1) = double(im_mat2(n,m,:));
%             dat(exclude)=nan;
            area_under(n,m,s) = trapz(dat);
            max_val(n,m,s) = max(dat);
         end
    end
end

au=area_under(:,:,12);
figure
imagesc(au,[-2 5])
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
    'start_scan','p','R_2','an_data','gm','wm','csf','max_ind','start_scan','dt','full_VIF');
disp(['Saved in : ' linearfile]);
plot_multiple_slices(fullfile(ct_path,linearfile),handles.folderN);
