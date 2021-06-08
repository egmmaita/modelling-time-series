function [best_train_pred, best_test_pred, ...
    best_train_nmse, best_test_nmse, ... 
    best_ar_order, best_x_order, best_ma_order] = FindBestARMAX(ar_order_sequence, x_order_sequence, ma_order_sequence, ... 
                                      all_data, input, components)
% =========================================================================
train_data = all_data{1};
train_time = all_data{2};
test_data = all_data{3};
test_time = all_data{4};
% ======== initialization ({:,4} position is the best test_nmse) =========
best_models = cell(6,7);
best_models(1:6,4) = num2cell(repmat(-1000, 6,1));
% ======== fit ============================================================
for x_order = x_order_sequence
    for ar_order = ar_order_sequence
        for ma_order = ma_order_sequence
           if ~(ma_order==0 && ar_order==0)
            try
                [train_pred, test_pred, train_nmse, test_nmse] = FitAndForecastARMAX(ar_order, x_order, ma_order, train_data, test_data, input,components);
                if test_nmse>best_models{1,4}
                    best_models = [ {train_pred, test_pred, train_nmse, test_nmse, ar_order, x_order, ma_order }; ...
                        best_models(1:5, 1:7) ];
                elseif test_nmse>best_models{2,4}
                    best_models = [ best_models(1, 1:7); {train_pred, test_pred, train_nmse, test_nmse, ar_order, x_order, ma_order}; ...
                        best_models(2:5, 1:7) ];
                elseif test_nmse>best_models{3,4}
                    best_models = [ best_models(1:2, 1:7); {train_pred, test_pred, train_nmse, test_nmse, ar_order, x_order, ma_order}; ...
                        best_models(3:5, 1:7) ];
                elseif test_nmse>best_models{4,4}
                   best_models = [ best_models(1:3, 1:7); {train_pred, test_pred, train_nmse, test_nmse, ar_order, x_order, ma_order}; ...
                        best_models(4:5, 1:7) ];
                elseif test_nmse>best_models{5,4}
                   best_models = [ best_models(1:4, 1:7); {train_pred, test_pred, train_nmse, test_nmse, ar_order, x_order, ma_order}; ...
                        best_models(5, 1:7) ];
                elseif test_nmse>best_models{6,4}
                   best_models = [ best_models(1:5, 1:7); ...
                        {train_pred, test_pred, train_nmse, test_nmse, ar_order, x_order, ma_order} ];
                end
            catch
                warning('ARMAX(%d,%d,%d) unstable, discharged',ar_order, x_order, ma_order);
            end
           end
        end 
    end
end
% ======== plot best models (2x (3x1) plots)===============================
for model_index=1:6
    train_pred = best_models{model_index,1};
    test_pred = best_models{model_index, 2};
    train_nmse = best_models{model_index, 3};
    test_nmse = best_models{model_index, 4};
    ar_order = best_models{model_index, 5};
    x_order = best_models{model_index, 6};
    ma_order = best_models{model_index, 7};

    if model_index < 4
        if model_index==1
            % ========== save for output the first model only =============
            best_train_pred = train_pred;
            best_test_pred = test_pred;
            best_train_nmse = train_nmse;
            best_test_nmse = test_nmse;
            best_ar_order = ar_order;
            best_x_order = x_order;
            best_ma_order = ma_order;

        end
        subplot(3,1,model_index)
    else
        if model_index == 4
            figure()
        end
        subplot(3,1,model_index-3)
    end
    plot([train_time; test_time], [train_data; test_data])
    hold on
    plot(train_time, train_pred, "r")
    plot(test_time, test_pred, "r:", 'LineWidth',1.8)
    hold off
    legend("data", ... 
    sprintf('ARMAX(%d,%d,%d) (NMSE: %.2f)', ar_order, x_order, ma_order, train_nmse), ... 
    sprintf("forecast (NMSE: %.2f)", test_nmse), ... 
    'Location', "southeast")
    title(sprintf('ARMAX(%d,%d,%d)', ar_order, x_order, ma_order));
    xlabel("Years");
    ylabel("Millions of dollars");
end
            