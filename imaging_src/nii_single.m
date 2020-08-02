function [FolderNewName]=nii_single(thisfolder)
path_parts = strsplit(fileparts(thisfolder),filesep);
% path_parts{2}='Nifti and analysis';
path_parts_full=cellfun(@(x) [x filesep], path_parts,'UniformOutput',0);
outputd=strcat(path_parts_full{:});
if ~isdir(outputd)
    mkdir(outputd);
end

h=msgbox(['Converting ' thisfolder ' to: ' outputd]);

d1=dir(thisfolder);
for k=4:length(d1)
    d2=dir(fullfile(thisfolder,d1(k).name));
    if(length(d2)>1) %meaning that d2 is a folder
        if(isdicom(fullfile(thisfolder,d1(k).name,d2(max(3,end-1)).name)))
            info=dicominfo(fullfile(thisfolder,d1(k).name,d2(max(3,end-1)).name));
        else
            continue;
        end
    else
        if(isdicom(fullfile(thisfolder,d1(k).name)))
            info=dicominfo(fullfile(thisfolder,d1(k).name));
        else
            continue;
        end
    end
    
    if(isfield(info,{'PatientName';'ProtocolName'}))
        if(~isempty(info.PatientName)) && ~isempty(strfind(info.ProtocolName,'dyn'))
            break;
        end
    end
end

% rename the folder (-anonymize)
try
    PatientNameSplit=strsplit([info.PatientName.FamilyName ' ' info.PatientName.GivenName],' ');
catch
    PatientNameSplit=strsplit(info.PatientName.FamilyName);
end

gender=[find(ismember(PatientNameSplit,'BEN')) find(ismember(PatientNameSplit,'BAT')) ];
if ~isempty(gender)
    PatientNameSplit(gender(1))=[];
end

ShortName=cellfun(@(x) x(1), PatientNameSplit);
try
    FolderNewName=[outputd ShortName '_' info.PatientID(end-3:end)];
catch
    FolderNewName=[outputd info.PatientName.FamilyName];
end

if(~isdir(FolderNewName))
    mkdir(FolderNewName);
end

for k=1:length(d1)
    thisfolder2=[thisfolder '\' d1(k).name];
    if any(strcmp(d1(k).name,{'.','..','DIRFILE'})) || ~isdir(thisfolder2)
        continue
    end
    d2=dir(thisfolder2);
    if ~isempty(strfind(d2(end).name,'_'))
       continue
    else
%         cmdstr = sprintf('!dcm2niix -z n -o "%s" -f %%t_%%s_%%d_%%p "%s"',FolderNewName,thisfolder2);
         cmdstr = sprintf('!dcm2niix -m y -z n -o "%s" -f %%t_%%s_%%d_%%p "%s"',FolderNewName,thisfolder2);

        eval(cmdstr)
        disp(k)
    end
end

close(h)
h=msgbox(['DONE converting ' thisfolder ' to: ' outputd]); pause(0.5); close(h)

save(fullfile(FolderNewName, 'info.mat'), 'info')


