function [info,PatientName]=Initials_maker(path)
% This function gets as input a path of original DICOM folder from
% Intelispace, e.g. contains subfolders with one sequence at each. Output
% is the initials for the subject.

d1=dir(path);
d2=dir([path '\' d1(end-1).name]);

try
    info=dicominfo([path '\' d1(end-1).name '\' d2(end-1).name]);
catch
    disp('This is a different DICOM folder, can''t analyzed');
    return
end

if isfield(info.PatientName,'GivenName')
    PatientName=sprintf('%s%s_%s', info.PatientName.FamilyName(1), info.PatientName.GivenName(1), info.PatientID(end-3:end));
else
    initials=cellfun(@(x) x(1),strsplit(info.PatientName.FamilyName,' '));
    initials=[initials(1) initials(end)];
    PatientName=sprintf('%s_%s', initials, info.PatientID(end-3:end));
end
   
disp(info.PatientName)
disp(['Patient ID: ' info.PatientID])
disp(['Patient Initials: ' PatientName ])