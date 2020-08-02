%choose folder with multiple runs. create lyna script image for each

% ---------  NOTE ------------
% Before running that code, you should first have a variable-
% "thresh_from_all_divide_All" for the threshold, according to your data
% (see file named "Thresholds.m")

fpath=uigetdir;    % choose directory with folders after BBB analysis
d_main=dir(fpath); % 

xA=spm_atlas('load','C:\Users\nircaf\Desktop\Nir\imaging_src\spm12\tpm\labels_Neuromorphometrics.nii'); %open SPM atlas
load('SPM_atlas_full_mask.mat')
load('Lyna regions\Control_young.mat')
load('Lyna regions\LABEL_INDEX.mat')

control_group = Control_young; %choose refrence group for Zscore



Linear_result_matrix = cell(length(d_main)-1,137); %create matrix for the results
Linear_result_matrix(1,2:137) = {xA.labels.name};

for n=3:length(d_main)

    % loading data
    main_path=fullfile(fpath,d_main(n).name);
    flag=[0 0 0];
    d1=dir([main_path '\*.mat']);
    for k=1:length(d1)
        if ~isempty(strfind(d1(k).name,'anatomy'))
            load(fullfile(d1(k).folder,d1(k).name))
            flag(1)=1;
        elseif ~isempty(strfind(d1(k).name,'Linear'))
            load(fullfile(d1(k).folder,d1(k).name))
            flag(2)=1;
        end
    end

    d2=[dir([main_path '\wr*.nii']);dir([main_path '\wr*.img'])];
    for k=1:length(d2)
        if ~isempty(strfind(d2(k).name,'dyn'))
            xB=spm_atlas('load',fullfile(d2(k).folder,d2(k).name));
            flag(3)=1;
            break
        end
    end

    if ~all(flag)
        error_array(n) = n;
        disp('error: can not load all files')
    end    

    tmp1=-p(:,:,:,1);

    % find anatomical indices of voxels
    [y_an_ind,x_an_ind]=find(wm+gm>0.5);
    z_an_ind=floor(x_an_ind/size(wm,2))+1;      % because second output of find return continuous indexing along 3rd dimension % could use ind2sub instead...
    x_an_ind=mod(x_an_ind,size(wm,2));
    y_an_ind=size(wm,1)-y_an_ind;               % becuase spm atlas is 90 degrees rotated
    xyz_an_ind=[x_an_ind y_an_ind z_an_ind];

    % find suprathreshold indices of voxels
    [y_bbbd_ind, x_bbbd_ind]=find(tmp1>thresh_from_all_divide_All);
    z_bbbd_ind=floor(x_bbbd_ind/size(wm,2))+1;
    x_bbbd_ind=mod(x_bbbd_ind,size(wm,2));
    y_bbbd_ind=size(wm,1)-y_bbbd_ind;
    xyz_bbbd_ind=[x_bbbd_ind y_bbbd_ind z_bbbd_ind];

    % find voxels that both anatomical and bbbd
    xyz_comb_ind=intersect(xyz_an_ind,xyz_bbbd_ind,'rows');                 

    % convert image coordinates to MNI
    anatomymm=xB.VA(1).mat*[xyz_comb_ind';ones(1,size(xyz_comb_ind,1))];    

    % convert back from MNI to SPM template
    spm_template_cor=round(xA.VA(1).mat\anatomymm); 
    spm_template_cor=unique(spm_template_cor(1:3,:)','rows')';               % there are duplicates becuase of dimensions reduction

    % remove single coordintes (non connected)
    z=zeros(121,145,121);
    z(sub2ind(size(z),spm_template_cor(1,:),spm_template_cor(2,:),spm_template_cor(3,:)))=1;
    CC = bwconncomp(z,26);
    vox_con={CC.PixelIdxList{cellfun(@length,CC.PixelIdxList)>1}};
    linear_indices=cell2mat(vox_con');
    [a,b,c]=ind2sub(size(z),linear_indices);
    spm_filtered_cor=[a';b';c'];

    % match the coordinates to brain areas
    patho_area=full_mask(sub2ind(size(full_mask),spm_filtered_cor(1,:),spm_filtered_cor(2,:),spm_filtered_cor(3,:)));

    % final results
    [d,e]=hist(patho_area,unique(patho_area));
    [f,g]=hist(full_mask(:),unique(full_mask(:)));

    result={'Unknown', xA.labels(ismember([xA.labels.index],e)).name}';        % names of structures
    result(:,2)=num2cell(d);                                                   % number of disrupted voxels
    result(:,3)=num2cell(d/sum(d));                                            % percent from disrupted voxels in brain
    result(2:end,4)=num2cell(d(2:end)./f(ismember(g,e(2:end))));               % percent from specific brain structure

    % arrange data of specific subject with all structures in brain
    xC=cell(137,4);
    xC(1:136,1)={xA.labels.name};
    xC(ismember({xA.labels.name},result(2:end,1)),2:4)=result(2:end,2:4);
    xC(137,:)=result(~cellfun(@isempty, strfind(result(:,1),'Unknown')),:);
    
    newStr = strrep(d_main(n).name,' ','_');
    linear_segment.(newStr)=xC;
    result_array = xC(:,4)';    
    
    %% lyna code
    pathological_group = result_array(1:136);
    for i = 1:length(pathological_group)
        if isempty(cell2mat(pathological_group(i)))
            pathological_group(i) = {0};
        end
    end
    pathological_group = cell2mat(pathological_group);

    
    concatinate_all = [pathological_group' control_group']';
    isnan_index = find(isnan(concatinate_all));
    concatinate_all(isnan_index) = 0;
    for i = 1:(size(concatinate_all,2))
        zscore_all(:,i) = zscore(concatinate_all(:,i));
    end
    zscore_pathological_f = zscore_all(1:size(pathological_group,1),:);
    zscore_control = zscore_all(size(pathological_group,1)+1:end,:);

    isnan_index_c = find(isnan(control_group));
    control_group(isnan_index_c) = 0;
    isnan_index_p = find(isnan(pathological_group));
    pathological_group(isnan_index_p) = 0;
    %% create figure
    vector2plot_temp = zscore_pathological_f;
    vector2plot = ones(1,207);
    for r=1:length(labels_index)
        vector2plot(labels_index(r).index) = vector2plot_temp(r);    
    end
    badNums = find(vector2plot <= 0);
    keepNums = find(vector2plot > 0);
    imageVector(vector2plot,badNums,keepNums,2,5)
    saveas(gcf,fullfile(main_path,[d_main(n).name '_regions_Zscore.tiff'])) 
    close Figure 1
    clear result_array zscore_all
end
