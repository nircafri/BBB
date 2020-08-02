clear; clc
%load('G:\football\T1 maps\controls_T1_without_5deg.mat');   
% ###--- ONLY ON THE FIRST RUN ---###, Save a variable 
% with the name "T1_without_5deg" (same as the name of the file) as an 
% empty cell, one time in the beginning of the project. You can run
% those 2 commented-lines: 
%
%  T1_without_5deg={};
%  save('G:\football\T1 maps\T1_without_5deg.mat','T1_without_5deg');


% -> choosing multiple directories (JAVA)
% Choose here the main subject directories, that contains the nifti and
% DICOM directories. This way you can choose multiple subjects
% (CTRL+clicks) to analyse.
% For the old dialog-box format, this is the only way to choose multiple
% directories.
import javax.swing.JFileChooser;
jchooser = javaObjectEDT('javax.swing.JFileChooser','G:\football\batch 2');
jchooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
jchooser.setMultiSelectionEnabled(true);

status = jchooser.showOpenDialog([]);
if status == JFileChooser.APPROVE_OPTION
    jFile = jchooser.getSelectedFiles();
    for i=1:size(jFile, 1)
        allDirs{i,1} = char(jFile(i).getAbsolutePath);
    end
end


% T1_calc
for k=1:length(allDirs)     % loop over subjects
    InDirs=cellstr(ls(allDirs{k}));
    nifti_folder=fullfile(allDirs{k},InDirs{~cellfun('isempty',strfind(InDirs,'_'))}); % find the nifti folder
    allnames=cellstr(ls(nifti_folder));
    deg=[];
    wrnames={};
    for m=3:length(allnames);       % loop over the nifti files
        this_file=allnames{m};
        if strcmp(this_file(end-2:end),'img') &&...
           ~isempty(strfind(this_file,'deg') ) &&...
           strcmp(this_file(1:2),'wr')
       
                in=strfind(this_file,'deg');
                thisnum=this_file(in-2:in-1);
                thisnum(strfind(thisnum,'_'))=[];
                deg=[deg str2num(thisnum)];
                wrnames{length(wrnames)+1,1}=this_file;
        end
    end
    deg=unique(deg)';       % "unique" also sort the numbers
    
    fnames={};
    for n=1:length(deg)
        for p=1:length(wrnames)
            if  ~isempty(strfind(wrnames{p},[ '_' num2str(deg(n)) 'deg']) )
                fnames{n,1}=wrnames{p};
            end
        end
    end
    
    % load deg images
    img={};
    for n=1:length(fnames)
        nii = load_nii(fullfile(nifti_folder,fnames{n}));
        for m = 1:size(nii.img,3)
            img{m}(:,:,n) = fliplr(rot90(nii.img(:,:,m)));
        end
    end
    
    
    % from t1 wrapper
    TR=10;%milisecna
    
    disp(['TR is now: ' num2str(TR) ' ms']);
    T1 = zeros(size(img{1}));
    M0 = zeros(size(img{1}));
    R2 = zeros(size(img{1}));
    
    [Selection,ok] = listdlg('PromptString',{['Subject ' num2str(k) '/'...
        num2str(length(allDirs))]; 'Select angles to include:'},...
        'ListString',num2str(deg));
    spec_deg=deg(Selection);
    
    if isempty(gcp('nocreate'))
        parpool
    end

    tic
    parfor n = 1:length(img)
        [T1(:,:,n),M0(:,:,n),R2(:,:,n)] = calc_t1_from_FA(TR,spec_deg,img{n}(:,:,Selection));
        disp(n);
    end
    toc
    disp(['done: ' allDirs{k}])
%     controls_T1_without_5deg{end+1,1}=InDirs{~cellfun('isempty',strfind(InDirs,'_'))}(1:3);
%     controls_T1_without_5deg{end,2}=T1;
    save([nifti_folder '\t1_0.mat'],'T1','M0','R2','img','spec_deg');
    
end

%save('G:\football\T1 maps\controls_T1_without_5deg.mat','controls_T1_without_5deg');