
fileFolder=fullfile('I:\TIA_Anat_Horev_Ofer\AA_7621');
files=dir(fullfile(fileFolder, '20200630094723_1901_dyn_100_dyn_100*.nii'));
fileNames={files.name};

for k = 1:numel(fileNames)
    fname = fullfile(fileFolder, fileNames{k});
    z(k) = load_untouch_nii(fname);
    y(:,:,:,k) = z(k).img;
end

% Create the ND Nifti file
output = make_nii(y);

% Save it to a file
save_nii(output,fileNames{1})