function [train_pred, test_pred, train_seas_comp, test_seas_comp, ... 
                    params, train_nmse, test_nmse] = FitAndForecastSeasons(T, n_components, train_data, ... 
                                                                        test_data,trend_comp)
% =========================================================================
train_trend = trend_comp{1};
test_trend = trend_comp{2};
dt_train_data = train_data - train_trend;
% ======== initialization =================================================
R = zeros(2*n_components+1,2*n_components+1);
B = zeros(2*n_components+1,1);
train_seas_comp = zeros(270,1);
test_seas_comp = zeros(30,1);
% ======== training =======================================================
for t=1:270
    fi = [1];
    for s=1:n_components
        fi = [fi cos(2*s*pi/T*t) sin(2*s*pi/T*t)];
    end
    R = R + fi'*fi;
    B = B + fi'*dt_train_data(t);
end
params = R\B;  
% ======== predict training data ==========================================
for t=1:270
    fi = [1];
    for s=1:n_components
        fi = [fi cos(2*s*pi/T*t) sin(2*s*pi/T*t)];
    end
    train_seas_comp(t) = fi*params;
end
train_pred = train_seas_comp + train_trend;
% ======== predict test data ==============================================
for t=271:300
    fi = [1];
    for s=1:n_components
        fi = [fi cos(2*s*pi/T*t) sin(2*s*pi/T*t)];
    end
    test_seas_comp(t-270) = fi*params;
end
test_pred = test_seas_comp + test_trend;
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






