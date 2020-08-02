load('Linear_dynamic_atlas.mat');

path=uigetdir;
d=dir(path);
% Semi-pre-allocation cell arrays with structures names as titles
avslopeLinear={[],labels_index.name}; medslopeLinear={[],labels_index.name}; stdslopeLinear={[],labels_index.name};
avslopeTofts={[],labels_index.name}; medslopeTofts={[],labels_index.name}; stdslopeTofts={[],labels_index.name};

for k=3:length(d)
    % load anatomy, linear and tofts files
    an=dir([path,'\',d(k).name,'\**\*anatomy*.mat']);
    li=dir([path,'\',d(k).name,'\**\*Linear*.mat']);
    to=dir([path,'\',d(k).name,'\**\*Tofts*.mat']);
    load(fullfile(an(datenum({an.date})==max(cellfun(@(x) datenum(x), {an.date}))).folder,an(datenum({an.date})==max(cellfun(@(x) datenum(x), {an.date}))).name));
    load(fullfile(li(datenum({li.date})==max(cellfun(@(x) datenum(x), {li.date}))).folder,li(datenum({li.date})==max(cellfun(@(x) datenum(x), {li.date}))).name));
    load(fullfile(to(datenum({to.date})==max(cellfun(@(x) datenum(x), {to.date}))).folder,to(datenum({to.date})==max(cellfun(@(x) datenum(x), {to.date}))).name));
    tmp1=-p(:,:,:,1);
    avslopeLinear{k-1,1}=d(k).name; medslopeLinear{k-1,1}=d(k).name; stdslopeLinear{k-1,1}=d(k).name;
    avslopeTofts{k-1,1}=d(k).name; medslopeTofts{k-1,1}=d(k).name; stdslopeTofts{k-1,1}=d(k).name;
    counter=2;
    for m=[labels_index.index]
        % average, median and std for Linear analysis
        avslopeLinear{k-1,counter}=mean(tmp1(Dyn_atlas==m & wm+gm>0.5));
        medslopeLinear{k-1,counter}=median(tmp1(Dyn_atlas==m & wm+gm>0.5));
        stdslopeLinear{k-1,counter}=std(tmp1(Dyn_atlas==m & wm+gm>0.5));
        % average, median and std for Tofts analysis
        avslopeTofts{k-1,counter}=mean(tmp1(Dyn_atlas==m & wm+gm>0.5));
        medslopeTofts{k-1,counter}=median(tmp1(Dyn_atlas==m & wm+gm>0.5));
        stdslopeTofts{k-1,counter}=std(tmp1(Dyn_atlas==m & wm+gm>0.5));
        counter=counter+1;
    end
    disp(d(k).name)
end
       
