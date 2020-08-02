function anon_new_subject(path,xlFullPath,destFolder)

%% this section is for standalone run
% for multiple subjects:
% import javax.swing.JFileChooser;
% jchooser = javaObjectEDT('javax.swing.JFileChooser','G:\football\batch 2');
% jchooser.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);
% jchooser.setMultiSelectionEnabled(true);
% 
% status = jchooser.showOpenDialog([]);
% if status == JFileChooser.APPROVE_OPTION
%     jFile = jchooser.getSelectedFiles();
%     for i=1:size(jFile, 1)
%         allDirs{i,1} = char(jFile(i).getAbsolutePath);
%     end
% end

% for one subject:
% path=uigetdir('G:\Original scans','Select Original DICOM folder of one subject');
% [xlFile,xlPath]=uigetfile('F:\Research\*.xlsx','Choose index file');
% xlFullPath=[xlPath xlFile];
% destFolder=uigetdir('F:\','Choose destination folder:');
    
%% this is for a call from GUI
tic
[info,PatientName]=Initials_maker(path);

try
    PatientAge=info.PatientAge;
catch
    PatientAge=floor((str2num(info.StudyDate)-str2num(info.PatientBirthDate))/10000);
end

% write original data to excel file
e = actxserver('Excel.Application');
e.Workbooks.Open(xlFullPath);
data=e.ActiveSheet.UsedRange;
cell_write=sprintf('A%d', size(data.value,1)+1);
if isfield(info.PatientName,'GivenName')
    sub_data={PatientName, info.PatientName.FamilyName, info.PatientName.GivenName, info.PatientID, PatientAge, info.StudyDate};
else 
    sub_data={PatientName, info.PatientName.FamilyName,[], info.PatientID, PatientAge, info.StudyDate};
end
e.Quit
e.delete
xlswrite(xlFullPath,sub_data,1,cell_write);


FolderName=['DICOM ' PatientName];
mkdir([destFolder '\' FolderName]);

%anonymization
dicomdict('set',[pwd '\dicom-dict-BBB.txt'])
zevel={'.';'..';'dirty'};
d1=dir(path);
for m=1:length(d1)
    if any(strcmp(d1(m).name,zevel))
        continue
    elseif  strcmp(d1(m).name,'DIRFILE')
        copyfile([path  '\DIRFILE'],[destFolder '\' FolderName  '\DIRFILE']);
        continue
    end
    
    mkdir([destFolder '\' FolderName '\' d1(m).name]);
    d2=dir([path '\' d1(m).name]);
    for n=1:length(d2)
        if any(strcmp(d2(n).name,zevel)) || any(strfind(d2(n).name,'anon'))
            continue
        elseif  strcmp(d2(n).name,'DIRFILE')
            copyfile([path '\'  d1(m).name '\DIRFILE'],[destFolder '\' FolderName '\' d1(m).name '\DIRFILE']);
            continue
        end
        
        try
            info=dicominfo([path '\' d1(m).name '\' d2(n).name]);
        catch
            disp([path '\' d1(m).name '\' d2(n).name ' is not a DICOM file'])
            continue
        end
        
        info.PatientName=PatientName;               % convert the field Name to initials
        info.PatientID='';                          % delete ID
        [X,~]=dicomread([path '\' d1(m).name '\' d2(n).name]);
        dicomwrite(X, [destFolder '\' FolderName '\' d1(m).name '\anon' d2(n).name], info, 'createmode', 'copy','WritePrivate',true,'UseMetadataBitDepths',true); 
    end
    disp([num2str(m) ' from ' num2str(length(d1)) ' dicom folders'])
end

zip([destFolder '\' FolderName],[destFolder '\' FolderName]);
disp(['completed anonymizing: ' path]);

% if ~strcmp(path, fullfile(fileparts(path),FolderName))
%     movefile(path, fullfile(fileparts(path),FolderName));
% end

toc