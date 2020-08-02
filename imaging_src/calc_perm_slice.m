function [kt,kep,vp] = calc_perm_slice(c_t, aif,dt,time_vec)
kt = zeros(size(c_t,1),size(c_t,2));
kep = zeros(size(c_t,1),size(c_t,2));
vp = zeros(size(c_t,1),size(c_t,2));
s= warning('off','MATLAB:lscov:RankDefDesignMat');


for r = 1:size(c_t,1)
    for c = 1:size(c_t,2)
        ct_vec = squeeze(c_t(r,c,:));
        if(sum(isnan(ct_vec))== length(ct_vec))
            continue;
        end
        if(sum(ct_vec<0)== length(ct_vec))
            continue;
        end
        [kt_tmp,kep_tmp,vp_tmp] = fast_tofts(ct_vec,aif,dt,time_vec);
        kt(r,c) = kt_tmp;
        kep(r,c) = kep_tmp;
        vp(r,c) = vp_tmp;
%         [msg, id] = lastwarn
    end
end