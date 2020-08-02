function [kt,kep,vp]=fast_tofts_wrapper(Ct,dt,full_VIF)

% clear; clc;

% dt = 1/6; % [min]

% [ct_name,ct_path] = uigetfile('*.mat','Choose C(t) file','E:\research\football');
% [linear_name,linear_path] = uigetfile('*.mat','Choose Linear res file file',ct_path);

% Ct = load(fullfile(ct_path,ct_name),'Ct');
% Ct = Ct.Ct;
% 
% lin_res = load(fullfile(linear_path,linear_name),'an_data','gm','wm','csf','mask_slice','roi_mask');
% 
% an_data = lin_res.an_data;
% gm = lin_res.gm;
% wm = lin_res.wm;
% csf = lin_res.csf;

r = size(Ct{1},1);
c = size(Ct{1},2);
% %% build reference ROI
% for t = 1:length(Ct)
%     tmp = real(Ct{t}(:,:,lin_res.mask_slice));
%     vif(t) = mean(tmp(lin_res.roi_mask));
% end

% max_ind = find(vif == max(vif)); %% find maximal point

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
parfor sl = 1:slices
    [kt_tmp,kep_tmp,vp_tmp] = calc_perm_slice(ct_pass{sl}, full_VIF,dt);
    kt(:,:,sl) = kt_tmp;
    kep(:,:,sl) = kep_tmp;
    vp(:,:,sl) = vp_tmp;
    disp(sl);
end
toc
%%% ADD SAVE