import mlreportgen.ppt.*
powerpoint = actxserver('Powerpoint.Application');

ppttoadd = Presentation('myFirstPresentation');

add(ppttoadd,'Comparison');
contents = find(ppttoadd,'Right Content');
% slidetoadd = ppttoadd.Slides.Item(1);  %to get the first slide
% shapetoadd = slidetoadd.Shapes.Item(2); %to get the 2nd shape

% presentation = powerpoint.Presentations.Open(powerpoints(k).name);
presentation = powerpoint.Presentations.Open('I:\LOSARTAN_FELIX_BENNINGER\03Results\HYY_971913022020\HYY_9719.ppt');

slide = presentation.Slides.Item(5);  %to get the first slide
shape = slide.Shapes.Item(2); %to get the 2nd shape
% replace(slides(2),shape);
replace(ppttoadd,'Left Content',shape);
% replace(ppttoadd,'Right Content','dummy content');

% slideObj = add(slide,object)
