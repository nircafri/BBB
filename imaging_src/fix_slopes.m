d=dir('J:\MCI\linear files\*Linear*.mat');
for k=1:length(d)
    load(fullfile(d(k).folder,d(k).name),'roi_slope','dt')
    roi_slope=roi_slope/dt*600;
    save(fullfile(d(k).folder,d(k).name),'roi_slope','-append')
end
    