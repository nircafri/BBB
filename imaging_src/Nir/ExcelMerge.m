y = cd();
    fpath=uigetdir;    % choose directory to copy from
cd(fpath);
powerpoints = dir(fpath);
for k=3: length(powerpoints)
    if~(powerpoints(k).isdir)
    powerpoints2 = dir('**/*.ppt');
    end

end
cd(y);