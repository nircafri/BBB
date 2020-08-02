function im_rgb= show_sig_on_anatomy(axes_handle,anatomy_im,sig_map,sig_from,sig_to,colormapDepth,flip_colormap,inv_flag)
%inv_flag=1: display pixels OUT of range
if(inv_flag == 1)
    sig_mask=(sig_map<sig_from)+(sig_map>sig_to);   %mask for pixels OUT of range
else
    sig_map(sig_map>sig_to) = sig_to;  %%%%%%%%%%%%%%%%5
    sig_mask=(sig_map>sig_from).*(sig_map<=sig_to);  %mask for pixels within range
%     [f,x] = ecdf(sig_map(sig_map>sig_from));
%     up_lim = x(find(f>0.95,1,'first'));
    up_lim = sig_to;
end

% sig_mask=(sig_map>sig_from);%mask for pixels within range
if(and(sum(sig_mask(:))>0,(sig_to-sig_from)>0))
    ind_relevant=find(sig_mask);            %1d indeces of relevant pixels
    vector_relevant=sig_map(ind_relevant);  %vector of relevant pixels values
    if(~inv_flag)
        vector_relevant_grayscale=mat2gray(vector_relevant,[sig_from,up_lim]);%scale to [0 1]
    else
        vector_relevant_grayscale=mat2gray(vector_relevant,[sig_from,sig_to]);%scale to [0 1]
    end
    vector_relevant_grayscale_colormap=floor(vector_relevant_grayscale*(colormapDepth-1)+1);%scale to [1 colormapDepth]
    if(flip_colormap)
        jetmat=flipud(jet(colormapDepth));% e.g. 64,128...
    else
        jetmat=jet(colormapDepth);% e.g. 64,128...
    end
    jetmat_r=jetmat(:,1);% red channel
    jetmat_g=jetmat(:,2);% green channel
    jetmat_b=jetmat(:,3);% blue channel
    r_channel=mat2gray(anatomy_im);
    g_channel=mat2gray(anatomy_im);
    b_channel=mat2gray(anatomy_im);
    r_channel(ind_relevant)=jetmat_r(vector_relevant_grayscale_colormap);
    g_channel(ind_relevant)=jetmat_g(vector_relevant_grayscale_colormap);
    b_channel(ind_relevant)=jetmat_b(vector_relevant_grayscale_colormap);
    im_rgb(:,:,1)=r_channel;
    im_rgb(:,:,2)=g_channel;
    im_rgb(:,:,3)=b_channel;
else
    im_rgb(:,:,1)=mat2gray(anatomy_im);
    im_rgb(:,:,2)=mat2gray(anatomy_im);
    im_rgb(:,:,3)=mat2gray(anatomy_im);
end
% 
% set(gcf,'CurrentAxes',axes_handle);
% colormap jet; h = imagesc(im_rgb); axis image; axis off;% colorbar('peer',axes_handle,'location','eastOutside');

