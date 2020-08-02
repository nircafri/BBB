function plot_multiple_slices_infant(res_file,FolderN,exstr)
load(res_file);

%% find anatomy and segmentation files (instead of using files = lbox2;)
allnames=cellstr(ls(FolderN));
files.anatomy={};
files.flair={};
files.T2={};

files.segment={};
for i=3:length(allnames);
    this_file=allnames{i};
    if  (strcmp(this_file(end-2:end),'img')||strcmp(this_file(end-2:end),'nii')) && strcmp(this_file(1),'r') &&...
        ~isempty(strfind(this_file,'T1'))&& (  ~isempty(strfind(this_file,'_NAV')) ||...
           ~isempty(strfind(this_file,'_3D')) || ~isempty(strfind(this_file,'_FFE'))    )
        
        files.anatomy{length(files.anatomy)+1,1}=[allnames{i}];
    end
    if (strcmp(this_file(end-2:end),'img')||strcmp(this_file(end-2:end),'nii')) && strcmp(this_file(1),'r') &&...
            ~isempty(strfind(this_file,'_FLAIR_') )
        files.flair{length(files.flair)+1,1}=fullfile(FolderN,allnames{i});
    end
    if (strcmp(this_file(end-2:end),'img')||strcmp(this_file(end-2:end),'nii')) && strcmp(this_file(1),'r') &&...
            ~isempty(strfind(this_file,'_T2W_') )
        files.T2{length(files.T2)+1,1}=fullfile(FolderN,allnames{i});
    end
    for ord=1:3
        if ~isempty(strfind(this_file,['c' num2str(ord) 'r']) )
            files.segment{ord}=fullfile(FolderN,allnames{i});
        end
    end
end ;
%% find first anatomy (401)
nums=[];
for i=1:length(files.anatomy)
    fname = strsplit(files.anatomy{i},'_');
    nums(i) = str2num(fname{2});
end
[b,inds] = sort(nums);

files.anatomy1=fullfile(FolderN,files.anatomy{inds(1)});
files.anatomy2=fullfile(FolderN,files.anatomy{inds(2)});

disp(files.anatomy1)
disp(files.anatomy2)
%% load first anatomy
nii = spm_read_vols(spm_vol(files.anatomy1));
for m = 1:size(nii,3)
    an_data1(:,:,m) = rot90(nii(:,:,m));
end
%% load second anatomy
nii = spm_read_vols(spm_vol(files.anatomy2));
for m = 1:size(nii,3)
    an_data2(:,:,m) = rot90(nii(:,:,m));
end
%% load flair
nii = spm_read_vols(spm_vol(files.flair{1}));
for m = 1:size(nii,3)
    flair(:,:,m) = rot90(nii(:,:,m));
end
%% load T2
nii = spm_read_vols(spm_vol(files.T2{1}));
for m = 1:size(nii,3)
    T2(:,:,m) = rot90(nii(:,:,m));
end
%% load segmentation files
nii = spm_read_vols(spm_vol(files.segment{1}));
gm_tmp = nii;
nii = spm_read_vols(spm_vol(files.segment{2}));
wm_tmp = nii;
nii = spm_read_vols(spm_vol(files.segment{3}));
csf_tmp = nii;
for i = 1:size(gm_tmp,3)
    gm(:,:,i) = rot90(gm_tmp(:,:,i));
    wm(:,:,i) = rot90(wm_tmp(:,:,i));
    csf(:,:,i) = rot90(csf_tmp(:,:,i));
end
%% INIT PPT
br_mask = double(gm+wm > 0.5);

numf=3;
[pathstr,name,ext]  = fileparts(FolderN);
pptname=[FolderN '\' name];
SlicesPerRow=ceil(sqrt(size(an_data1,3)));
C=jet(64);
C=[1 1 1; C];


%set(handles.main, 'Visible', 'off');
fo=figure(1);
if ~(exist([pptname '.ppt'], 'file') == 2)
    ppt=saveppt2(pptname,'init');

    load([FolderN '\info.mat']);
    prompt = {'Project:','Patient Initials:','Sex:', 'Age:', 'Acquisition Date:','MD:','Clinical History:','Comments:'};
    dlg_title = 'Insert Scan Description';
    
    defans{2}=FolderN(length(fileparts(FolderN))+2:end);   %Initials
    defans{3}=info.PatientSex;
    defans{4}=info.PatientAge;
    defans{5}=[info.AcquisitionDate(7:8) '.' info.AcquisitionDate(5:6) '.' info.AcquisitionDate(1:4)];
    
    defans{1}='Infants';
    defans{6}='Dr Eilon';
    defans{7}='HIE';
    defans([ 8])={' '};
    answer=defans;
%     answer = inputdlg(prompt,dlg_title,1,defans);
%     if isempty(answer) %first info slide
%         answer={' ',' ',' ',' ',' ',' ',' ',' '};
%     end
    text=sprintf(['Project: '  answer{1} '\n',...
        'Patient Initials: ' answer{2} '\n',...
        'Sex: ' answer{3} '\n',...
        'Age: ' answer{4} '\n',...
        'Acquisition Date: ' answer{5} '\n',...
        'Dr: ' answer{6} '\n',...
        'Clinical History: ' answer{7} '\n',...
        'Comments: ' answer{8} '\n',...
        'Analyzed on: ' date '\n',...
        'Excluded frames: ' exstr]);
    saveppt2('ppt',ppt,'text',text);
    close(fo);
    %% CREATE BIG % anatomy data
    
    for n=1:size(an_data1,3)
        big1(size(an_data1,1)*(floor((n-1)/SlicesPerRow))+[1:size(an_data1,1)],size(an_data1,2)*mod(n-1,SlicesPerRow)+[1:size(an_data1,2)],:) = (an_data1(:,:,n));
        big2(size(an_data1,1)*(floor((n-1)/SlicesPerRow))+[1:size(an_data1,1)],size(an_data1,2)*mod(n-1,SlicesPerRow)+[1:size(an_data1,2)],:) = (an_data2(:,:,n));
        big3(size(an_data1,1)*(floor((n-1)/SlicesPerRow))+[1:size(an_data1,1)],size(an_data1,2)*mod(n-1,SlicesPerRow)+[1:size(an_data1,2)],:) = (T2(:,:,n));
        big4(size(an_data1,1)*(floor((n-1)/SlicesPerRow))+[1:size(an_data1,1)],size(an_data1,2)*mod(n-1,SlicesPerRow)+[1:size(an_data1,2)],:) = (flair(:,:,n));

    end
    
    h = figure(numf); imagesc(big1,[0 2000]);
    colormap gray;
    set(gca,'DataAspectRatio',[1 1 1]);axis image;axis off;
    saveppt2('ppt',ppt, 'title','T1 pre-Gd','Padding',[50 50 0 0]);
    close(h)
    numf=numf+1;
    h = figure(numf);imagesc(big2,[0 6500]);
    colormap gray;
    set(gca,'DataAspectRatio',[1 1 1]);axis image;axis off;
    saveppt2('ppt',ppt, 'title','T1 post-Gd','Padding',[50 50 0 0]);
    close(h)
    h = figure(numf);imagesc(big3);
    colormap gray;
    set(gca,'DataAspectRatio',[1 1 1]);axis image;axis off;
    saveppt2('ppt',ppt, 'title','T2','Padding',[50 50 0 0]);
    close(h)
    numf=numf+1;
    h = figure(numf);imagesc((big4));
    colormap gray;
    set(gca,'DataAspectRatio',[1 1 1]);axis image;axis off;
    saveppt2('ppt',ppt, 'title','FLAIR','Padding',[50 50 0 0]);
    close(h)
    saveppt2(pptname,'ppt',ppt,'close');
end
ppt=saveppt2(pptname,'init');
%%
big_im = zeros(size(an_data1,1)*ceil(size(an_data1,3)/SlicesPerRow),size(an_data1,2)*SlicesPerRow,3);
big_sl = nan(size(an_data1,1)*ceil(size(an_data1,3)/SlicesPerRow),size(an_data1,2)*SlicesPerRow);
big_int = nan(size(an_data1,1)*ceil(size(an_data1,3)/SlicesPerRow),size(an_data1,2)*SlicesPerRow);
if exist('p')
    vals = -p(:,:,:,1).*br_mask;    % inverted for parametric norm
    thresh = 0;
    max_val = 1;

    for n=1:size(p,3)
        disp(n);
        to_disp = -p(:,:,n,1).*br_mask(:,:,n);
        im_rgb = show_sig_on_anatomy(gca,an_data1(:,:,n),medfilt2(to_disp,[3 3]),thresh, max_val,64,0,0);
        big_im(size(im_rgb,1)*(floor((n-1)/SlicesPerRow))+[1:size(im_rgb,1)],size(im_rgb,2)*mod(n-1,SlicesPerRow)+[1:size(im_rgb,2)],:) = im_rgb;
        big_sl(size(im_rgb,1)*(floor((n-1)/SlicesPerRow))+[1:size(im_rgb,1)],size(im_rgb,2)*mod(n-1,SlicesPerRow)+[1:size(im_rgb,2)]) = medfilt2(-p(:,:,n,1),[3 3]);
        big_int(size(im_rgb,1)*(floor((n-1)/SlicesPerRow))+[1:size(im_rgb,1)],size(im_rgb,2)*mod(n-1,SlicesPerRow)+[1:size(im_rgb,2)]) = medfilt2(p(:,:,n,2),[3 3]);

    end
    
    %% plot raw slope
    numf=numf+1;
    h=figure(numf);
    imagesc(big_sl,[-0.4,0.8]); colorbar; axis image; axis image;axis off; colormap('jet');
    print(gcf,'-dpdf',[res_file(1:end-4),'-slope.pdf']);
    saveppt2('ppt',ppt, 'title',[ name ' ,Raw Slopes'],'Padding',[50 50 0 0]);
    close(h)
    %% plot slope over T1
    numf=numf+1;
    h = figure(numf);image(big_im);
    set(gca,'DataAspectRatio',[1 1 1]); axis image; axis off; colormap jet;
    colorbar('Ticks',[1,32.5,65],'TickLabels',[0,0.5,1])
    saveppt2('ppt',ppt, 'title',[ name ' ,Slope over T1'],'Padding',[50 50 0 0]);
    hgsave(h,[res_file(1:end-4),'-FIGURE.fig']);
    % print(h,'-dtiff','-r300',[fname(1:end-4),'-FIGURE_all.tiff']);
    print(h,'-dpdf',[res_file(1:end-4),'-FIGURE_all.pdf']);
    close(h)
    %% plot intercepts
    numf=numf+1;
    h= figure(numf);
    imagesc(big_int,[0,1]); colorbar; axis image; axis image;axis off; colormap('jet');
    hgsave(h,[res_file(1:end-4),'-FIGURE-INTERCEPT_1.fig']);
    % print(h,'-dtiff','-r300',[fname(1:end-4),'-FIGURE-INTERCEPT_1.tiff']);
    print(h,'-dpdf',[res_file(1:end-4),'-intercept1.pdf']);
    saveppt2('ppt',ppt, 'title','Intercept 1','Padding',[50 50 0 0]);
    close(h)
    numf=numf+1;
    h= figure(numf);
    imagesc(big_int,[0,0.1]); colorbar; axis image; axis image;axis off; colormap('jet');
    hgsave(h,[res_file(1:end-4),'-FIGURE-INTERCEPT_2.fig']);
    % print(h,'-dtiff','-r300',[fname(1:end-4),'-FIGURE-INTERCEPT_2.tiff']);
    print(h,'-dpdf',[res_file(1:end-4),'-intercept2.pdf']);
    saveppt2('ppt',ppt, 'title','Intercept 2','Padding',[50 50 0 0]);
    close(h)
    disp(['pdfs saved in ' res_file(1:end-4),'-FIGURE-INTERCEPT_2.fig'])
end
if exist('kt')
    for n=1:size(kt,3)
        big_k(size(kt,1)*(floor((n-1)/SlicesPerRow))+[1:size(kt,1)],size(kt,2)*mod(n-1,SlicesPerRow)+[1:size(kt,2)],:) = medfilt2(kt(:,:,n),[3 3]);%.*br_mask(:,:,n);
        big_kep(size(kt,1)*(floor((n-1)/SlicesPerRow))+[1:size(kt,1)],size(kt,2)*mod(n-1,SlicesPerRow)+[1:size(kt,2)],:) = medfilt2(kep(:,:,n),[3 3]);%.*br_mask(:,:,n);
        big_vp(size(kt,1)*(floor((n-1)/SlicesPerRow))+[1:size(kt,1)],size(kt,2)*mod(n-1,SlicesPerRow)+[1:size(kt,2)],:) = medfilt2(vp(:,:,n),[3 3]);%.*br_mask(:,:,n);
    end
    big_k(big_k==0)=nan;
    big_kep(big_kep==0)=nan;
    big_vp(big_vp==0)=nan;
    %% plot raw
    numf=numf+1;
    h=figure(numf);
    imagesc(big_k,[-0.3,0.2]); colorbar; axis image; axis image;axis off; colormap('jet');
    print(gcf,'-dpdf',[res_file(1:end-4),'-big_k.pdf']);
    saveppt2('ppt',ppt, 'title','Kt','Padding',[50 50 0 0]);
    close(h)
    numf=numf+1;
    h=figure(numf);
    imagesc(big_kep,[-0.08,0.08]); colorbar; axis image; axis image;axis off; colormap('jet');
    print(gcf,'-dpdf',[res_file(1:end-4),'-big_kep.pdf']);
    saveppt2('ppt',ppt, 'title','Kep','Padding',[50 50 0 0]);
    close(h)
    numf=numf+1;
    h=figure(numf);
    imagesc(big_vp,[-0.08,0.08]); colorbar; axis image; axis image;axis off; colormap('jet');
    print(gcf,'-dpdf',[res_file(1:end-4),'-big_vp.pdf']);
    saveppt2('ppt',ppt, 'title','Vp','Padding',[50 50 0 0]);
    close(h)
end
%% close ppt
saveppt2(pptname,'ppt',ppt,'close');
save([ pptname 'anatomy.mat'],'an_data1','gm','wm');
%set(handles.main, 'Visible', 'on');


