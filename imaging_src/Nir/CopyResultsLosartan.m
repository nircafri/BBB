%  function CopyPPT_PDF(location1)

y = cd();
%     fpath=uigetdir;    % choose directory to copy from
 fpath1 = 'I:\LOSARTAN_FELIX_BENNINGER\03Results';
%  cd(fpath1);
     location=dir(fpath1);% 

%     location=dir(location1);% 
%     fpath2=uigetdir;    % choose directory to copy to

%  destfolder = cellfun(@(s) ~isempty(strfind(location1, s)), [])
% switch destfolder
%     case  'TIA_Anat_Horev_Ofer'
%      fpath2 =   'I:\Google Drive\BBB\Results\TIA_AnatHorev'
%         case  'LOSARTAN_FELIX_BENNINGER'
%      fpath2 =   'I:\Google Drive\BBB\Results\Losartan'
% end
fpath2 = 'I:\Google Drive\BBB\Results\Losartan';
    location2=dir(fpath2);% 
    for k = 3 : length(location)
        cd(fpath1);
        copyFrom = dir(location(k).name);
        disp(copyFrom(k).folder)
       CopyPPT_PDF(copyFrom(1).folder, location2(1).folder,location(k).name);        
    end
 cd(y);
%  end