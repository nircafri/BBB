% xlswrite('filename', M, sheet, 'range')
y = cd();
    fpath=uigetdir;    % choose directory to copy from
cd(fpath);
powerpoints = dir('**/*.ppt');
powerpoint = actxserver('Powerpoint.Application');
filename = 'Patients.xlsx';
sheet = 1;
% c = (1:99);
xlRange = 'A1';
A = cell(1,4);                % preallocate cell array
S = {'Patient Initials','Sex','Acquisition Date','Analyzed on'};
                xlswrite(filename,S,sheet,xlRange)

for k=1: length(powerpoints)
    if( (isempty(strfind(powerpoints(k).folder,'batch')) && (isempty(strfind(powerpoints(k).folder,'_wo5'))) && (isempty(strfind(powerpoints(k).folder,'control')))))
presentation = powerpoint.Presentations.Open(fullfile(powerpoints(k).folder,powerpoints(k).name));
slide = presentation.Slides.Item(1);  %to get the first slide
shape = slide.Shapes.Item(2); %to get the 2nd shape
str = shape.Texteffect.Text();
PatientInitials  = strfind(str,'Patient Initials: ')
PatientSex  = strfind(str,'Sex: ')
A{1} = str(PatientInitials+18:PatientSex-1);
A{2} = str(PatientSex+5:PatientSex+6);
PatientAcquisition  = strfind(str,'Acquisition Date: ')
A{3} = str(PatientAcquisition+18:PatientAcquisition+28);

PatientAnalyzed  = strfind(str,'Analyzed on: ')
A{4} = str(PatientAnalyzed+13:PatientAnalyzed+23);

xlRange = append('A',string(k+1))
                xlswrite(filename,A,sheet,xlRange)
       
    end
end

cd(y);
