%%
folder='J:\Calkin\big file\linear files +IR';
d=dir(folder);

%%
% first method
% normalize each subject [1-64], then average the norm values.

all_ind=zeros(189*157,27,2);
sub_num=0;
thresh = 0.04;
max_val = 0.07;

%
for k=3:2:length(d)
    load(fullfile(d(k).folder, d(k).name));
    load(fullfile(d(k).folder, d(k+1).name));
    disp(ct_path)
    
    br_mask = double(gm+wm > 0.5);
    tempVals = -p(:,:,:,1);
    tempVals=tempVals(gm+wm > 0.5);
    upper_outlier_th=2*nanstd(tempVals)+nanmean(tempVals);            % find 2 std threshold
    lower_outlier_th=-2*nanstd(tempVals)+nanmean(tempVals);           % find 2 std threshold
    
    for n=1:size(p,3)
        to_disp = -p(:,:,n,1).*br_mask(:,:,n);
        to_disp(to_disp>upper_outlier_th) = nan;
        sig_map=medfilt2(to_disp,[3 3]);
        anatomy_im=an_data1(:,:,n);
        sig_map(sig_map>max_val) = max_val;
        sig_mask=(sig_map>thresh).*(sig_map<=max_val);  %mask for pixels within range
        ind_relevant=find(sig_mask);            %1d indeces of relevant pixels
        vector_relevant=sig_map(ind_relevant);  %vector of relevant pixels values
        vector_relevant_grayscale=mat2gray(vector_relevant,[thresh,max_val]);%scale to [0 1]
        vector_relevant_grayscale_colormap=floor(vector_relevant_grayscale*(64-1)+1);%scale to [1 colormapDepth]
        all_ind(ind_relevant,n,1)=all_ind(ind_relevant,n,1)+vector_relevant_grayscale_colormap;    %sum all the subjects
        
        %mean of anatomy
        all_ind(:,n,2)=all_ind(:,n,2)+double(reshape(medfilt2(an_data1(:,:,n),[3 3]),[],1));
      
        
    end
    sub_num=sub_num+1          % count number of subjects
    
end

%
all_ind=all_ind/sub_num;
%
jetmat=jet(64);
slide=0;
big_im=zeros(189*5,157*6);
color_im=zeros(189*5,157*6);
for k=1:5
    for n=1:6
        if k>4 && n>3
            break
        end
        slide=slide+1;
        big_im((k-1)*189+(1:189),(n-1)*157+(1:157))=reshape(all_ind(:,slide,2),189,157);
        color_im((k-1)*189+(1:189),(n-1)*157+(1:157))=reshape(all_ind(:,slide,1),189,157);
    end
end
r_layer=mat2gray(big_im);
g_layer=mat2gray(big_im);
b_layer=mat2gray(big_im);

min_color=max(color_im(:))/4;                     % exclude voxels with very low grade becuse of averaging
disp_fact=1.5;                                     % factor to multiply scale, otherwise all little numbers will be blue.

r_layer(color_im>min_color)=jetmat(round(color_im(color_im>min_color)*disp_fact),1);  
g_layer(color_im>min_color)=jetmat(round(color_im(color_im>min_color)*disp_fact),2);
b_layer(color_im>min_color)=jetmat(round(color_im(color_im>min_color)*disp_fact),3);

comb_im(:,:,1)=r_layer;
comb_im(:,:,2)=g_layer;
comb_im(:,:,3)=b_layer;

figure; image(comb_im); axis image; axis off; colormap jet; caxis([0 64])

colorbar_step=(max_val-thresh)/64;
colorbar_min=thresh;
%colorbar_min=(thresh+min_color*colorbar_step)/disp_fact;

co=colorbar('YLimMode','manual','YLim',[colorbar_min,64],...
         'YTickMode','manual','YTick',[colorbar_min ceil((colorbar_min+64)/2) 64],...
         'YTickLabel',{num2str(colorbar_min/disp_fact,2),num2str((max_val+colorbar_min)/(disp_fact*2),2),num2str(max_val/disp_fact,2) }); 
%%
% second method
% average all subject's values, then normalize to [1-64]
all_ind=zeros(189,157,27,2);
sub_num=0;
thresh = 0.004;
max_val = 0.07;
clear big_im;

%
for k=3:2:length(d)
     load(fullfile(folder, d(k).name));
     load(fullfile(folder, d(k+1).name));
     disp(ct_path)
    
     br_mask = double(gm+wm > 0.5);
     to_disp = -p(:,:,:,1).*br_mask;
     all_ind(:,:,:,1)=all_ind(:,:,:,1)+to_disp;
     all_ind(:,:,:,2)=all_ind(:,:,:,2)+double(an_data1);
     sub_num=sub_num+1          % count number of subjects

end

all_ind=all_ind/sub_num;

SlicesPerRow=ceil(sqrt(size(an_data1,3)));
for n=1:27
    im_rgb = show_sig_on_anatomy(gca,all_ind(:,:,n,2),medfilt2(all_ind(:,:,n,1),[3 3]),thresh, max_val,64,0,0);
    big_im(size(im_rgb,1)*(floor((n-1)/SlicesPerRow))+[1:size(im_rgb,1)],size(im_rgb,2)*mod(n-1,SlicesPerRow)+[1:size(im_rgb,2)],:) = im_rgb;
end

figure; image(big_im); axis image; axis off; colormap jet; caxis([0 64])
set(gca,'DataAspectRatio',[1 1 1]);axis image;axis off;
colorbar('YLimMode','manual','YLim',[0,64],...
    'YTickMode','manual','YTick',[0:32:64],...
    'YTickLabel',{num2str(thresh),num2str((max_val+thresh)/2,3),num2str(max_val) }); colormap jet;

%%
% third method
% binar suprathreshold for each subject, then sum it
all_ind=zeros(189,157,27,2);
sub_num=0;
clear big_im;
thresh = 0.004;
max_val = 0.07;

%
for k=3:2:length(d)
    load(fullfile(folder, d(k).name));
    load(fullfile(folder, d(k+1).name));
    disp(ct_path)
    
    br_mask = double(gm+wm > 0.5);
    to_disp = -p(:,:,:,1).*br_mask;
    to_disp(to_disp>=thresh) = 1;
    to_disp(to_disp<thresh) = 0;
    to_disp(isnan(to_disp)) = 0;
    all_ind(:,:,:,1)=all_ind(:,:,:,1)+to_disp;
    all_ind(:,:,:,2)=all_ind(:,:,:,2)+double(an_data1);
    sub_num=sub_num+1          % count number of subjects
   
end
all_ind=all_ind/sub_num;
%
big_im=zeros(189*5,157*6);
slide=0;
for k=1:5
    for n=1:6
        if k>4 && n>3
            break
        end
        slide=slide+1;
        big_im((k-1)*189+(1:189),(n-1)*157+(1:157))=all_ind(:,:,slide,1);
    end
end
figure; imagesc(big_im); axis image; axis off; colormap jet; colorbar
%%
%print(gcf,'-dpdf','H:\recovered data\football\Dec\mean_map_high_perm_control_divide_2.pdf');
title(['mean map of BBBD in BD+IR subjects M3 (n=' num2str(sub_num) ')'])
print(gcf,'-dpdf','J:\Calkin\big file\mean map BD+IR M3.pdf');
