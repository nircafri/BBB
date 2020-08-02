function [T1,M0,R2] = calc_t1_from_FA(TR,angles,s)
% S: 3D: slice X flip angles
% TR,TE : miliseconds
% angles: deg
% adopted from: 
%     Optimized and combined T1 and B1 mapping technique for 
%     fast and accurate T1 quantification in contrast-enhanced abdominal
%     MRI, Treier et al., MRM, 2007

T1 = zeros(size(s,1),size(s,2));
M0 = zeros(size(s,1),size(s,2));
R2 = zeros(size(s,1),size(s,2));

for n = 1:size(s,1)
    for m = 1:size(s,2)
        dat = double(s(n,m,:));
        dat = dat(:);
        if(sum(dat)>0)
            y = dat./sind(angles(:));
            x = dat./tand(angles(:));
            V = [x(:),ones(length(x),1)];
            pol = V\y;
            T1(n,m) = -TR/log(pol(1));%a
            M0(n,m) = pol(2)/(1-pol(1));%may be inaccurate- b=Mo(1-E1)E2
            ev = V*pol;
            er = y-ev;
            R2(n,m) = 1-(er'*er)/((y-mean(y))'*(y-mean(y)));

%% version for 2 angles
%             if length(angles)==2
%                 X = (s(:,:,1)*sind(angles(2))-s(:,:,2)*sind(angles(1)))./(s(:,:,1)*sind(angles(2))*cosd(angles(1))-s(:,:,1)*sind(angles(1))*cosd(angles(2)));
%                 X=abs(X);
%                 X(X>=1)=0.999;
%                 T1 =  -TR./log(X);
%                 M0=s(:,:,1).*(1-cosd(angles(1)).*X)./( sind(angles(2)).*(1-X));
%             end

%%
        end
    end
end
