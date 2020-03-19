function [out_yield_series,out_yield_series_lower,out_yield_series_upper] = ...
    linear_project_yield(in_years,in_yield_series,predict_years)
% linear_project_yield - linear yield projection
%[out_yield_series,out_yield_series_lower,out_yield_series_upper] = ...
% linear_project_yield(in_years,in_yield_series,predict_years)
%





%length_predict_years: how many individual years into the future we need
%prediction


%convert in_years to go from 0 to max
max_year=max(in_years);
min_year=min(in_years);

obs_year=0:(length(in_yield_series)-1);

linear_yield = LinearModel.fit(obs_year,in_yield_series,'linear');
%coefficients=dataset2cell(linear_yield.Coefficients);
%intercept=cell2mat(coefficients(2,2));
%x1=cell2mat(coefficients(3,2));

intercept=table2array(linear_yield.Coefficients(1,1));
x1=table2array(linear_yield.Coefficients(2,1));

fitted_yield=x1*obs_year+intercept;


%do the prediction
%jamie will pass in specific years or a time series we have to return
%values for those specific years
predict_years_internal=(predict_years-min_year);

out_yield_series=x1.*predict_years_internal+intercept;




%95% confidence intervals
ci=coefCI(linear_yield);
intercept_lower=ci(1,1);
intercept_upper=ci(1,2);
x1_lower=ci(2,1);
x1_upper=ci(2,2);


out_yield_series_lower=x1_lower.*predict_years_internal+intercept_lower;
out_yield_series_upper=x1_upper.*predict_years_internal+intercept_upper;

end