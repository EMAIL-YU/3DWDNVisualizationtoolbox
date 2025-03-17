function [value_f]=make_time_accident(FD,A,B,min_va,max_va,ac_time)

%     case weibul
%
%     case normal
%
%
%     case exponential
%
%
%     case gamma
%
%
%     case uniform
%
%
%     case lognormal

pd = makedist(FD,A,B);
x = linspace(min_va+0.1, max_va, ac_time)
min_va+0.1:.1:max_va;
[value_f]=normalize(pdf(pd,x),'range');

end


% switch FD
%
%     case weibul
%
%     case normal
%
%
%     case exponential
%
%
%     case gamma
%
%
%     case uniform
%
%
%     case lognormal
