function [kt,kep,vp] = fast_tofts(c_t,aif,dt,time_vec)
% Murase, Efficient Method for Calculating Kinetic Parameters Using.., MRM, 2004
% c_t(t): single voxel over time. 

% aif and c_t are taken only at non-excluded timepoints 
% (time_vec=1:length(Ct);time_vec(exclude)=[]);

aif=aif(time_vec); 
c_t=c_t(time_vec);

tmp_aif_sum = dt*cumtrapz(time_vec,aif);
tmp_ct_sum = dt*cumtrapz(time_vec,c_t);
A = [tmp_aif_sum(:), -tmp_ct_sum(:), aif'];
B = lscov(A,c_t);
% B = A\c_t(:);
kt = B(1)-B(2)*B(3);
kep = B(2);
vp = B(3);