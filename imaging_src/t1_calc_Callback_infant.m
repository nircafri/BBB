function handles=t1_calc_Callback_infant(hObject,handles)
allnames=cellstr(ls(handles.folderN));
deg=get(handles.angle1,'String');% find files based on deg='5;15';20;25'(e.g. wr442236513_1101_DESPOT1_5deg_CLEAR.img)
deg=str2num(deg);
fnames.deg={};
for i=3:length(allnames);
    this_file=allnames{i};
    if (strcmp(this_file(end-2:end),'img') || strcmp(this_file(end-2:end),'nii') ) && strcmp(this_file(1),'r')
        for n=1:length(deg)
            if  ~isempty(strfind(this_file,[ '_' num2str(deg(n)) 'deg']) )
                fnames.deg{n,1}=[allnames{i}];
            end
        end
    end
end
if length(deg)<length(fnames.deg)
    %         fnames.deg=fnames.deg(1:length(deg));
    msgbox({'There are duplicate degree files in the folder.';
        'REMOVE OR RENAME DUPLICATES!'});
    msgbox(fnames.deg)
    return
end
%% load deg images
img={};
for n=1:length(fnames.deg)
    vol = spm_vol(fullfile(handles.folderN,fnames.deg{n}));
    nii.img = spm_read_vols(vol);
    for m = 1:size(nii.img,3)
        img{m}(:,:,n) = rot90(nii.img(:,:,m));
    end
end


    %% from t1 wrapper 
TR=eval(get(handles.tr1,'String'));
if ~isa(TR,'double')
    TR=10;%milisec
end
disp(['TR is now: ' num2str(TR) ' ms']);
T1 = zeros(size(img{1}));
M0 = zeros(size(img{1}));
R2 = zeros(size(img{1}));

if isempty(gcp('nocreate'))
  parpool
end
tic
parfor n = 1:length(img)
    [T1(:,:,n),M0(:,:,n),R2(:,:,n)] = calc_t1_from_FA(TR,deg,img{n});
    disp(n);
end
toc
save(fullfile(handles.folderN,'t1_0.mat'),'T1','M0','R2','deg','img');
disp('T1 map calculation is done');
disp(['num of complex is ',num2str(length(find(imag(T1(:))~=0)))]);

handles.im_mat=T1;
set(handles.slice_text,'Visible','on');
set(handles.slice_slider,'Visible','on');
set(handles.slice_slider,'Min',1);
set(handles.slice_slider,'Value',1);
set(handles.slice_slider,'Max',size(handles.im_mat,3));
set(handles.slice_slider,'SliderStep',[1/(size(handles.im_mat,3)-1),2/(size(handles.im_mat,3)-1)]);
set(handles.slice_slider, 'Callback',@(hObject,eventdata)BBB_analysis('update_display_t1',handles));
set(handles.time_text,'Visible','on');
set(handles.time_slider,'Value',1);
set(handles.text25,'Visible','on');
set(handles.text27,'Visible','on');
set(handles.excluded,'Visible','on');
set(handles.x,'Visible','on');
set(handles.v,'Visible','on');  


