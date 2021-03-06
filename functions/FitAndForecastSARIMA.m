function [train_pred, test_pred, ... 
    train_nmse, test_nmse] = FitAndForecastSARIMA(p, d, q, P, Seasonality, Q, train_data, test_data)
% ======== fit model ======================================================

model = estimate(arima( ...
   'ARLags', p, 'D', d,'ARLags', q, 'SARLags', P, 'Seasonality', Seasonality, 'SMALags', Q), ...
   train_data, 'Display', 'off');
residuals = infer(model, train_data);
train_pred = train_data + residuals;
% ======== compute train error ============================================
train_nmse = 1- min([1 ... 
                   power( ... 
                     norm( train_data - train_pred ) / ... 
                     norm( train_data - mean(train_data)) ... 
                         ,2) ... 
                ]);
% ======== forecast =======================================================
[test_pred, ~] = forecast(model, numel(test_data), train_data);
% ======== compute test error =============================================
test_nmse = 1- min([1 ... 
                   power( ... 
                     norm( test_data - test_pred) / ... 
                     norm( test_data - mean(test_data)) ... 
                         ,2) ... 
                ]);
