function est = api_sim(x,rain)
%this is the API function, where x are the 3 coeff
%y is the soil moisture to fit to and rain is the input.

beta = x(1);
gamma = x(2);
const = x(3);
est = zeros(length(rain),1);

for t = 1:length(rain)
    sum = 0;
    for n = 0:min([6 t-1]) %go back over the last 6 dekads
        sum = sum + gamma^n * rain(t-n);
    end
    est(t) = beta * sum + const;
end