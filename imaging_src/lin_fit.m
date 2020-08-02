function [res, R_2] = lin_fit(im_mat,time_vec) %fast function
r = size(im_mat,1);
c = size(im_mat,2);
times = size(im_mat,3);

res = zeros(r,c,1,2);
R_2 = zeros(r,c);    
% N = eye(times)-ones(times,1)*ones(1,times)/times;

for n = 1:r
    for m = 1:c
        dat(1:times,1) = double(im_mat(n,m,:));
        dat=dat(time_vec);
        V = [time_vec',ones(size(time_vec'))];
        tmp_pol = V \ dat;
        res(n,m,1,:) =  tmp_pol;
        ev = V*tmp_pol;
        er = dat-ev;
        R_2(n,m) = 1-(er'*er)/((dat-mean(dat))'*(dat-mean(dat)));
    end
end