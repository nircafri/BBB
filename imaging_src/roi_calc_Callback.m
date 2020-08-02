function handles=roi_calc_Callback(hObject,handles)
allnames=cellstr(ls(handles.folderN));
dyn_names={};
for i=3:length(allnames);
    this_file=allnames{i};
    if (strcmp(this_file(end-2:end),'img') || strcmp(this_file(end-2:end),'nii'))...
            && strcmp(this_file(1:2),'wr') ...
            ...&& isempty(strfind(this_file,'Reg') )...
            && ~isempty(strfind(this_file,'dyn') ) && isempty(strfind(this_file,'deg') )
        dyn_names{length(dyn_names)+1,1}=[allnames{i}];
    end
end ;
disp('Loading images for ROI selection')
h = waitbar(0,'Loading Files');

vol = spm_vol(fullfile(handles.folderN,dyn_names{1}));
nii = spm_read_vols(vol);
handles.num_dyn = size(nii,4);
for n=1:size(nii,4)
    waitbar(n/handles.num_dyn,h);
    for m = 1:size(nii,3)
        handles.data{m,n} = rot90(nii(:,:,m,n)); %--- number of cells = number of dynamics. each cell: rows X columns X slices
        im_mat(:,:,m,n) = handles.data{m,n}; %--- number of cells = number of dynamics. each cell: rows X columns X slices
    end
end

% for the new dcm2niix format:

% nii = load_nii(fullfile(handles.folderN,dyn_names{1}));
% im_mat=fliplr(rot90(nii.img));


%for the old format:
% handles.num_dyn = length(dyn_names);
% disp('Loading images for ROI selection')
% h = waitbar(0,'Loading Files');
% for n=1:handles.num_dyn
%     waitbar(n/handles.num_dyn,h);
%     nii = load_nii(fullfile(handles.folderN,dyn_names{n}));
%     for m = 1:size(nii.img,3)
%         handles.data{m,n} = fliplr(rot90(nii.img(:,:,m)));
%         im_mat(:,:,m,n) = fliplr(rot90(nii.img(:,:,m)));
%     end
% end

close(h);

set(handles.slice_text,'Visible','on');
set(handles.time_slider,'Visible','on');
set(handles.time_slider,'Min',1);
set(handles.time_slider,'Value',1);
set(handles.time_slider,'Max',handles.num_dyn);
set(handles.time_slider,'SliderStep',[1/(handles.num_dyn-1),2/(handles.num_dyn-1)]);
set(handles.slice_slider,'Visible','on');
set(handles.slice_slider,'Min',1);
set(handles.slice_slider,'Value',1);
set(handles.slice_slider,'Max',size(im_mat,3));
set(handles.slice_slider,'SliderStep',[1/(size(im_mat,3)-1),2/(size(im_mat,3)-1)]);
handles.im_mat = im_mat;
set(handles.slice_slider, 'Callback',@(hObject,eventdata)BBB_analysis('update_display_aif',handles));
set(handles.time_slider, 'Callback',@(hObject,eventdata)BBB_analysis('update_display_aif',handles));
set(handles.mark_roi_button,'Visible','on');
set(handles.time_text,'Visible','on');
set(handles.time_slider,'Value',1);
set(handles.text25,'Visible','on');
set(handles.text27,'Visible','on');
set(handles.excluded,'Visible','on');
set(handles.x,'Visible','on');
set(handles.v,'Visible','on');
set(handles.cLow,'Visible','on');
set(handles.cHigh,'Visible','on');
set(handles.text29,'Visible','on');
set(handles.text30,'Visible','on');
