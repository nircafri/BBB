function []=imageVector(vector2plot,badNums,keepNums,min,max)

load('SPM_atlas_full_mask.mat')


supAtlas=full_mask;
supAtlas(supAtlas==0)=nan;

for ac=1:length(badNums)
    supAtlas(supAtlas==badNums(ac))=min;    
end

for ac=1:length(keepNums)
    supAtlas(supAtlas==keepNums(ac))=vector2plot(keepNums(ac));  
end

bigSPM=[];
SlicesPerRow=4;
s1=size(supAtlas,1);
s2=size(supAtlas,2);
count=1;
for slice=32:4:94
    bigSPM(s2*(floor((count-1)/SlicesPerRow))+[1:s2],s1*mod(count-1,SlicesPerRow)+[1:s1],:) =  imrotate(supAtlas(:,:,slice),90);
    count=count+1;
end
%%
figure



imAlpha=ones(size(bigSPM));
imAlpha(isnan(bigSPM))=0;
imagesc(bigSPM,'AlphaData',imAlpha);
set(gca,'color',0*[1 1 1]);
set(gcf,'Color','w');
set ( gca, 'ydir', 'reverse' )
%caxis([0 50]) 
caxis([min max]) 
load('cred2.mat');
colormap(cred2);
cbh = colorbar ;
axis image;axis off;

