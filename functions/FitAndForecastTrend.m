function [train_pred, test_pred, params] = FitAndForecastTrend(all_data, degree)
train_data = all_data{1};
train_time = all_data{2};
test_data = all_data{3};
test_time = all_data{4};
% ======== initialization =================================================
R = zeros(degree+1,degree+1);
B = zeros(degree+1,1);
train_pred = zeros(270,1);
test_pred = zeros(30,1);
% ======== training =======================================================
for t=1:270
    fi = power( [1 repmat(t, 1, degree)], 0:degree)';
    R = R + fi*fi';
    B = B + fi*train_data(t);
end
params = R\B;  
% ======== predict training data ==========================================
for t=1:270
    fi = power( [1 repmat(t, 1, degree)], 0:degree);
    train_pred(t) = fi*params;
end
% ======== predict test data ==============================================
for t=271:300
    fi = power( [1 repmat(t, 1, degree)], 0:degree);
    test_pred(t-270) = fi*params;
end
% ======== compute error train set ========================================
train_nmse = 1- min([1 ... 
                   power( ... 
                     norm( train_data - train_pred) / ... 
                     norm( train_data - mean(train_data)) ... 
                         ,2) ... 
                ]);
% ======== compute error test set =========================================
test_nmse = 1- min([1 ... 
                   power( ... 
                     norm( test_data - test_pred) / ... 
                     norm( test_data - mean(test_data)) ... 
                         ,2) ... 
                ]);
% ======== plot results ===================================================
plot([train_time; test_time], [train_data; test_data])
hold on
plot(train_time, train_pred,"r")
plot(test_time, test_pred, "r:",'LineWidth',1.8)
legend("data", ... 
    sprintf('polynomial degree %d (NMSE: %.2f)', degree, train_nmse), ... 
    sprintf("forecast (NMSE: %.2f)", test_nmse), ... 
    'Location', "southeast")
title(sprintf("Polynomial degree %d", degree))
xlabel("Years")
ylabel("Millions of dollars")
hold off





