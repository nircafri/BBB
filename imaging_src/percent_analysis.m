%% Percentage analysis

% There are three sections here: 1- extracting data, 2- determine
% thresholds, 3- BBB disruption percentage.

% If thresholds are exist already, the second section can be commented with
% patrs of 1st and 3rd sections, and it can be run as a single for-loop.


%% Exctract data

% Select here a folder that contains "linear" and "anatomy" .mat files of
% all subjects
fpath='Q:\jonathas_o\control\football';
d=dir(fpath);
for n=3:2:length(d)-1
    
    if ~strcmp(d(n).name(1:7),d(n+1).name(1:7))
        disp('non consistent files in folder, analysis has stopped.')
        break
    end

    load(fullfile(fpath,d(n).name));
    load(fullfile(fpath,d(n+1).name));
   
    tmp1=-p(:,:,:,1);       % normalized data
    tmp3=-p(:,:,:,3);       % multiplicated data
    tmp4=-p(:,:,:,4);       % differented data
    if size(p,4)==5
        tmp5=-p(:,:,:,5);       % raw data
    end
    name=strsplit(ct_path,'\');
    
    index=(n-1)/2;
    BBBanalysis(index).initials=name(end);
    BBBanalysis(index).slope=roi_slope;
    BBBanalysis(index).divide=tmp1(gm+wm>0.5);
    BBBanalysis(index).WmDivide=tmp1(wm>0.5);
    BBBanalysis(index).GmDivide=tmp1(gm>0.5);
    BBBanalysis(index).raw=tmp5(gm+wm>0.5);
    BBBanalysis(index).WmRaw=tmp5(wm>0.5);
    BBBanalysis(index).GmRaw=tmp5(gm>0.5);
    BBBanalysis(index).multi=tmp3(gm+wm>0.5);
    BBBanalysis(index).diff=tmp4(gm+wm>0.5);
    disp(d(n).name)
    
% end
% 
% %% Threshold determination
% % this section is only for control subjects, for determining the threshold.
% 
% AllDivide=[]; prAD=[];      % percentage for all brain normalyzed
% GmDivide=[];  prGD=[];      % percentage for gray matter normalyzed
% WmDivide=[];  prWD=[];      % percentage for white matter normalyzed
% AllRaw=[];    prAR=[];      % percentage for all brain raw
% GmRaw=[];     prGR=[];      % percentage for gray matter raw
% WmRaw=[];     prWR=[];      % percentage for white matter raw
% 
% for k=1:length(BBBanalysis) AllDivide=[AllDivide; BBBanalysis(k).divide]; prAD=[prAD prctile(BBBanalysis(k).divide,95)]; end
% for k=1:length(BBBanalysis) GmDivide=[GmDivide; BBBanalysis(k).GmDivide]; prGD=[prGD prctile(BBBanalysis(k).GmDivide,95)];  end
% for k=1:length(BBBanalysis) WmDivide=[WmDivide; BBBanalysis(k).WmDivide]; prWD=[prWD prctile(BBBanalysis(k).WmDivide,95)]; end
% for k=1:length(BBBanalysis) AllRaw=[AllRaw; BBBanalysis(k).raw]; prAR=[prAR prctile(BBBanalysis(k).raw,95)];end
% for k=1:length(BBBanalysis) GmRaw=[GmRaw; BBBanalysis(k).GmRaw];  prGR=[prGR prctile(BBBanalysis(k).GmRaw,95)];end
% for k=1:length(BBBanalysis) WmRaw=[WmRaw; BBBanalysis(k).WmRaw];  prWR=[prWR prctile(BBBanalysis(k).WmRaw,95)];end
% 
% % thresholds as 95 percentile of all control's voxels
% thresh_from_all_divide_All=prctile(AllDivide,95)
% thresh_from_all_divide_Gm=prctile(GmDivide,95)
% thresh_from_all_divide_Wm=prctile(WmDivide,95)
% thresh_from_all_raw_All=prctile(AllRaw,95)
% thresh_from_all_raw_Gm=prctile(GmRaw,95)
% thresh_from_all_raw_Wm=prctile(WmRaw,95)
% 
% % thresholds as mean of all 95 percentiles from each control 
% thresh_from_each_divide_All=mean(prAD)
% thresh_from_each_divide_Gm=mean(prGD)
% thresh_from_each_divide_Wm=mean(prWD)
% thresh_from_each_raw_All=mean(prAR)
% thresh_from_each_raw_Gm=mean(prGR)
% thresh_from_each_raw_Wm=mean(prWR)
% 
% 
% %% BBB disrution percents
% 
% for index=1:length(BBBanalysis)
%     
    BBBanalysis(index).perDivEach=100*sum(BBBanalysis(index).divide> thresh_from_each_divide_All)/length(BBBanalysis(index).divide);
    BBBanalysis(index).perDivWmEach=100*sum(BBBanalysis(index).WmDivide> thresh_from_each_divide_Wm)/length(BBBanalysis(index).WmDivide);
    BBBanalysis(index).perDivGmEach=100*sum(BBBanalysis(index).GmDivide> thresh_from_each_divide_Gm)/length(BBBanalysis(index).GmDivide);
    BBBanalysis(index).perRawEach=100*sum(BBBanalysis(index).raw> thresh_from_each_raw_All)/length(BBBanalysis(index).raw);
    BBBanalysis(index).perRawWmEach=100*sum(BBBanalysis(index).WmRaw> thresh_from_each_raw_Wm)/length(BBBanalysis(index).WmRaw);
    BBBanalysis(index).perRawGmEach=100*sum(BBBanalysis(index).GmRaw> thresh_from_each_raw_Gm)/length(BBBanalysis(index).GmRaw);
    
    BBBanalysis(index).perDivAll=100*sum(BBBanalysis(index).divide> thresh_from_all_divide_All)/length(BBBanalysis(index).divide);
    BBBanalysis(index).perDivWmAll=100*sum(BBBanalysis(index).WmDivide> thresh_from_all_divide_Wm)/length(BBBanalysis(index).WmDivide);
    BBBanalysis(index).perDivGmAll=100*sum(BBBanalysis(index).GmDivide> thresh_from_all_divide_Gm)/length(BBBanalysis(index).GmDivide);
    BBBanalysis(index).perRawAll=100*sum(BBBanalysis(index).raw> thresh_from_all_raw_All)/length(BBBanalysis(index).raw);
    BBBanalysis(index).perRawWmAll=100*sum(BBBanalysis(index).WmRaw> thresh_from_all_raw_Wm)/length(BBBanalysis(index).WmRaw);
    BBBanalysis(index).perRawGmAll=100*sum(BBBanalysis(index).GmRaw> thresh_from_all_raw_Gm)/length(BBBanalysis(index).GmRaw);

end


%%
% K-trans analysis

% Select here a folder that contains "tofts" and "anatomy" .mat files of
% all subjects
fpath='Q:\jonathas_o\control\football';
d=dir(fpath);
for n=3:2:length(d)
    
    if ~strcmp(d(n).name(1:7),d(n+1).name(1:7))
        disp('non consistent files in folder, analysis has stopped.')
        break
    end

    load(fullfile(fpath,d(n+1).name));
    load(fullfile(fpath,d(n+2).name));
    name= d(n+1).name(1:7);
    
    index=(n)/3;
    BBBkt(index).initials=name;
    BBBkt(index).KT=kt(gm+wm>0.5);
    BBBkt(index).WmKT=kt(wm>0.5);
    BBBkt(index).GmKT=kt(gm>0.5);
    disp(d(n).name)
    
end

%% Threshold determination
% this section is only for control subjects, for determining the threshold.

AllKT=[]; prAK=[];      % percentage for all brain normalyzed
GmKT=[];  prGK=[];      % percentage for gray matter normalyzed
WmKT=[];  prWK=[];      % percentage for white matter normalyzed

for k=1:length(BBBkt) AllKT=[AllKT; BBBkt(k).KT]; prAK=[prAK prctile(BBBkt(k).KT,95)]; end
for k=1:length(BBBkt) GmKT=[GmKT; BBBkt(k).GmKT]; prGK=[prGK prctile(BBBkt(k).GmKT,95)];  end
for k=1:length(BBBkt) WmKT=[WmKT; BBBkt(k).WmKT]; prWK=[prWK prctile(BBBkt(k).WmKT,95)]; end

% thresholds as 95 percentile of all control's voxels
thresh_from_all_KT_All=prctile(AllKT,95)
thresh_from_all_KT_Gm=prctile(GmKT,95)
thresh_from_all_KT_Wm=prctile(WmKT,95)

% thresholds as mean of all 95 percentiles from each control 
thresh_from_each_KT_All=mean(prAK)
thresh_from_each_KT_Gm=mean(prGK)
thresh_from_each_KT_Wm=mean(prWK)


%% BBB disruption percents

for index=1:length(BBBkt)
    
    BBBkt(index).perKtEach=100*sum(BBBkt(index).KT> thresh_from_each_KT_All)/length(BBBkt(index).KT);
    BBBkt(index).perKtWmEach=100*sum(BBBkt(index).WmKT> thresh_from_each_KT_Wm)/length(BBBkt(index).WmKT);
    BBBkt(index).perKtGmEach=100*sum(BBBkt(index).GmKT> thresh_from_each_KT_Gm)/length(BBBkt(index).GmKT);
    
    BBBkt(index).perKtAll=100*sum(BBBkt(index).KT> thresh_from_all_KT_All)/length(BBBkt(index).KT);
    BBBkt(index).perKtWmAll=100*sum(BBBkt(index).WmKT> thresh_from_all_KT_Wm)/length(BBBkt(index).WmKT);
    BBBkt(index).perKtGmAll=100*sum(BBBkt(index).GmKT> thresh_from_all_KT_Gm)/length(BBBkt(index).GmKT);

end
