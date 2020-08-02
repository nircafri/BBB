function nii_Callback(hObject,handles)
curval = get(handles.mode, 'value');
outputd=uigetdir2('Select output folder');
outputd='I:\BBB\tests\converted'
if curval==1 % single convert
    % inputd=handles.folderN;
    inputd='I:\BBB\tests\S44341'
    cmdstr = sprintf('!dcm2niix -z n -o "%s" -f %%t_%%s_%%d%%p "%s"',outputd,inputd);
    eval(cmdstr)
else
    for 1=1:length(handles.folders)
        inputd=handles.folders{i};
        cmdstr = sprintf('!dcm2niix -z n -o "%s" -f %%t_%%s_%%d%%p "%s"',outputd,inputd);
        eval(cmdstr)
    end
end