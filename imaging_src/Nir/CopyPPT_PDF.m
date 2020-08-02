 function CopyPPT_PDF(location,location2,fodldername)
  y = cd();
%         fpath=uigetdir;    % choose directory to copy from
% fpath = location;
%     location1=dir(fpath);% 
%   cd(location);
%         foldername = location.name(1:7);

%     d_main=dir(location2); 
    cd(location2);
    % Creates a new folder if doesn't exist
    if ~exist(fodldername)
    mkdir(fodldername);
    end
    % Finds destination folder
        destination = dir(location2);
        for k = 3 : length(destination)
            if (strcmp(destination(k).name,fodldername))
                dest = dir(destination(k).name);
                break;
            end
        end
  cd(location);
  %Copy files
      pdfData = dir('*.pdf');
    for k = 1 : length(pdfData)
   status = copyfile(pdfData(k).name,dest(1).folder);
    end
        pptData = dir('*.ppt');
      for k = 1 : length(pptData)
   status = copyfile(pptData(k).name,dest(1).folder);
      end
          tiffData = dir('*.tiff');
      for k = 1 : length(tiffData)
   status = copyfile(tiffData(k).name,dest(1).folder);
      end
    
      matData = dir('*.mat');
      for k = 1 : length(matData)
   status = copyfile(matData(k).name,dest(1).folder);
    end
    
    
    
    cd(y); 
end
