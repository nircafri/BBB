function location = nir_DeletingXXCopy(location)
% dirData = dir('**/*.xx');
y = cd();
cd(location);
addpath(genpath(location))

%Delete all .xx files
    dirData = dir('**/XX_*');
    for k = 1 : length(dirData)
        delete( fullfile( dirData(k).folder, dirData(k).name ) )
    end

% Delete all .copy files
dirData = dir('**/*.copy');
    for k = 1 : length(dirData)
        delete( fullfile( dirData(k).folder, dirData(k).name ) )
    end
%Deleting _Series0000
     if isfolder('_Series0000')
    rmdir '_Series0000';
     end
    
    cd(y)
end
