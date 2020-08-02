function [Ct,T1_t] = calc_ct(T1_0,ref,dyn,TR,alpha)
% Claculates the concentration of contrast agent, [mM]
% T1_0 : Sec
% ref : 3D data pre-contrast (usually averaged over 4-5 baseline scans)
% dyn : 3D data (single time point)
% TR : sec
% alpha : deg

% TR = 3.9*(10^-3); %[sec]
% alpha=20; %flip_angle
r1=3.89; % [mM*sec]^-1, for DOTAREM in 3T

%% version 1 - WRONG!!!!!!   DO NOT USE  !!!!!!
%  adapted from 
% "Improved 3D Quantitative Mapping of Blood Volume and Endothelial Permeability in Brain Tumors", Li et al., j.MRI 2000
%  THERE IS AN ERROR IN THE EQUATION IN THE PAPER  !!!!!!!
% A = (dyn-ref)./(M0*sind(alpha));
% B = (1-exp(-TR./T1_0))./(1-cosd(alpha)*exp(-TR./T1_0));
% R1 = (-1/TR)*log((1-(A+B))./(1-cosd(alpha)*(A+B)));
% T1_t = 1./R1;
% Ct = (R1-1./T1_0)/r1;

%% version 2
%  adapted from 
% "Uncertainty and bias in contrast concentration measurements using spoiled gradient echo pulse sequences"
%  Schabel and Parker, Phys Med Biol 2008

% delta = dyn./ref;
% beta = (1-cosd(alpha)*exp(-TR./T1_0))./(1-exp(-TR./T1_0));
% R1 = (-1/TR)*log((delta-beta)./(delta*cosd(alpha)-beta));
% T1_t = 1./R1;
% Ct = (R1-1./T10)/r1;

%% version 3 (based on my development, from blue notebook)
E0 = exp(-TR./T1_0);
A = (dyn./ref).*((1-E0)./(1-cosd(alpha)*E0));
E1 = (1-A)./(1-cosd(alpha)*A);
T1_t = -TR./log(E1);
Ct = (1./T1_t-1./T1_0)/r1;
