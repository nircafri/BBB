function SPM_single(thisfolder,mode)
tic


disp([ 'Started: ' thisfolder]);
nrun = 1; % enter the number of runs here
jobfile = {'spm12_batch_football_job.m'};
if mode
    jobfile = {'spm12_batch_infant_job.m'};
end
disp(['using: ' jobfile]);
jobs = repmat(jobfile, 1, nrun);
inputs = cell(4, nrun);
allnames=cellstr(ls(thisfolder));
%%
fnames.anatomy={};
fnames.dynamic={};
fnames.others={};
for i=3:length(allnames);
    this_file=allnames{i};
    if (strcmp(this_file(end-2:end),'img')||strcmp(this_file(end-2:end),'nii'))...
            && ~strcmp(this_file(1),'r')&& ~strcmp(this_file(1),'w')
        
        if ~isempty(strfind(this_file,'T1') )&& (~isempty(strfind(this_file,'_NAV') ) || ~isempty(strfind(this_file,'_3D') )) && this_file(1)>=48 && this_file(1)<=57
            fnames.anatomy{length(fnames.anatomy)+1,1}=[  allnames{i} ];
        elseif ~isempty(strfind(this_file,'dyn'))
            tmp_dyn_vol = spm_vol(fullfile(thisfolder,this_file));
            for n=1:length(tmp_dyn_vol)
                fnames.dynamic{n} = [tmp_dyn_vol(n).fname,',',num2str(n)];
            end             
        elseif ~isempty(strfind(this_file,'T2W'))...
                || ~isempty(strfind(this_file,'FLAIR'))...
                || ~isempty(strfind(this_file,'DESPOT'))...
                || ~isempty(strfind(this_file,'SINUS'))
                
            fnames.others{length(fnames.others)+1,1}= fullfile(thisfolder,allnames{i});
        end
    end
end
%%

nums=[];
for i=1:length(fnames.anatomy)
    fname = strsplit(fnames.anatomy{i},'_');
    nums(i) = str2num(fname{2});
end
[b,inds] = sort(nums);

if length(inds)==2
    fnames.others{length(fnames.others)+1,1}=fullfile(thisfolder,fnames.anatomy{inds(2)});
end
 fnames.anatomy=fullfile(thisfolder,fnames.anatomy{inds(1)});


%%

for crun = 1:nrun
    inputs{1, crun} = {fnames.anatomy}; % Named File Selector: File Set - cfg_files
    inputs{2, crun} = fnames.dynamic'; % Named File Selector: File Set - cfg_files
    inputs{3, crun} = fnames.others; % Named File Selector: File Set - cfg_files
    %     inputs{4, crun} = MATLAB_CODE_TO_FILL_INPUT; % Coregister: Estimate & Reslice: Other Images - cfg_files
end
    %%
% spm fmri;
% spm('defaults', 'FMRI');
spm_jobman('run', jobs, inputs{:});
disp([ 'Done with SPM for ' thisfolder]);
toc
