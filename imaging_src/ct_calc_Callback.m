function ct_calc_Callback(hObject,handles)

if ~exist(fullfile(handles.folderN,'t1_0.mat'), 'file') == 2
        msgbox('No t1_0.mat file');
        return
end 
t1_0_data = load(fullfile(handles.folderN,'t1_0.mat'));
%% find dynamic files
allnames=cellstr(ls(handles.folderN));
fnames.dyn={};
for i=3:length(allnames);
    this_file=allnames{i};
    if (strcmp(this_file(end-2:end),'img')||strcmp(this_file(end-2:end),'nii'))...
            && strcmp(this_file(1:2),'wr') &&...
            ~isempty(strfind(this_file,'dyn') ) %&& isempty(strfind(this_file,'Reg') )
        fnames.dyn{length(fnames.dyn)+1,1}=[allnames{i}];
    end
end ;
%%
disp('Loading files...');

vol = spm_vol(fullfile(handles.folderN,fnames.dyn{1}));
nii = spm_read_vols(vol);
for n=1:size(nii,4)
    for m = 1:size(nii,3)
        dyn_img{n}(:,:,m) = rot90(nii(:,:,m,n)); %--- number of cells = number of dynamics. each cell: rows X columns X slices
    end
end

disp('Loading done');
%% flip_angle and TR
TR = eval(get(handles.tr2,'String')); 
if ~isa(TR,'double')
    TR=4;%should be in sec after conversion from gui
end
TR=TR*(10^-3);% is now in sec
disp (['TR is now ' num2str(TR) ' sec']);
try
    alpha = eval(get(handles.angle2,'String'));  
catch
    tmp=get(handles.angle2,'String');
    alpha=eval(tmp{1});
end;
    
if ~isa(alpha,'double')
    alpha=20; 
end
%%
base_dyn = (dyn_img{1}+dyn_img{2}+dyn_img{3}+dyn_img{4})/4;
%base_dyn = (dyn_img{1});

disp('Calculating C(t) and T1(t)...');
tic
for n = 1:length(dyn_img)% TR must be in sec!!!!
    [Ct{n},T1_t{n}] = calc_ct(real(single(t1_0_data.T1))/1000,single(base_dyn),single(dyn_img{n}),TR,alpha); % dividing by 1000 since T1_0 is in mSec
    Ct{n} = real(Ct{n});
    %     disp(n);    
end
toc
%%
disp('Done');
disp('Saving...');
save(fullfile(handles.folderN,'C_t.mat'),'Ct','T1_t','TR','alpha','base_dyn','-v7.3');
disp('saved');