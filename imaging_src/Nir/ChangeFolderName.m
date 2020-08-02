
% d = dir('I:\TIA_Anat_Horev_Ofer\02 DICOM\analysed');
% dfolders = d([d(:).isdir]) ;

% 
% dfolders = dir('C:\Users\nircaf\Desktop\Nir\Dicom *')
% for k=1 : length(dfolders)
%     tempname = dfolders(k).name
%     movefile (tempname, '* Dicom');
% end

projectdir = 'C:\Users\nircaf\Desktop\Nir\Dicom *';
   dinfo = dir( fullfile(projectdir, '*.txt') );
   oldnames = {dinfo.name};
   unwanted = cellfun(@isempty, regexp(oldnames, '^[A-Z][^_].*') );
   oldnames(unwanted) = [];
   newnames = regexprep(oldnames, '^(.)', '$1_');
   for K = 1 : length(oldnames)
      movefile( fullfile(projectdir, oldnames{K}), fullfile(projectdir, newnames{K}) );
   end
