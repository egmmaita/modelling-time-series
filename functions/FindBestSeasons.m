function [train_trendAndSeas, test_trendAndSeas, train_Seas, ... 
                       test_Seas, Params] = FindBestSeasons(T_sequence, ... 
                                                     n_components_sequence, all_data, trend_comp)
% =========================================================================
train_data = all_data{1};
train_time = all_data{2};
test_data = all_data{3};
test_time = all_data{4};
% ======== initialization ({:,4} position is the best test_nmse) =========
best_models = cell(6,9);
best_models(1:6,4) = num2cell(repmat(-1000, 6,1));
for T = T_sequence
    for n_components = n_components_sequence
        try
            % ======== fit model ==========================================
            [train_pred, test_pred, train_seas_comp, test_seas_comp, ... 
                            params, train_nmse, test_nmse] = FitAndForecastSeasons(T, n_components, train_data, ...
                                                                            test_data,trend_comp);
            % === if better, add to best 6 ranking in respective position =
            if test_nmse>best_models{1,4}
                best_models = [ {train_pred, test_pred, train_nmse, test_nmse, ... 
                                 T, n_components, train_seas_comp, test_seas_comp,params}; ...
                                 best_models(1:5, 1:9) ];
            elseif test_nmse>best_models{2,4}
                best_models = [ best_models(1, 1:9); {train_pred, test_pred, train_nmse, ... 
                                test_nmse, T, n_components, train_seas_comp, test_seas_comp, params}; ...
                                best_models(2:5, 1:9) ];
            elseif test_nmse>best_models{3,4}
                best_models = [ best_models(1:2, 1:9); {train_pred, test_pred, train_nmse, ... 
                                test_nmse, T, n_components, train_seas_comp, test_seas_comp, params}; ...
                                best_models(3:5, 1:9) ];
            elseif test_nmse>best_models{4,4}
               best_models = [ best_models(1:3, 1:9); {train_pred, test_pred, train_nmse, test_nmse, ... 
                               T, n_components, train_seas_comp, test_seas_comp, params}; ...
                               best_models(4:5, 1:9) ];
            elseif test_nmse>best_models{5,4}
               best_models = [ best_models(1:4, 1:9); {train_pred, test_pred, train_nmse, test_nmse, ...
                               T, n_components, train_seas_comp, test_seas_comp, params}; ...
                               best_models(5, 1:9) ];
            elseif test_nmse>best_models{6,4}
               best_models = [ best_models(1:5, 1:9); {train_pred, test_pred, train_nmse, test_nmse, ... 
                               T, n_components, train_seas_comp, test_seas_comp, params} ];
            end
        catch
            warning('Failed Seasonality estimate with period %d and number of components %d',T,n_components);
        end
    end 
end
% ======== plot best models (2x (3x1) plots)===============================
for model_index=1:6
    train_pred = best_models{model_index,1};
    test_pred = best_models{model_index, 2};
    train_nmse = best_models{model_index, 3};
    test_nmse = best_models{model_index, 4};
    T = best_models{model_index, 5};
    n_components = best_models{model_index, 6};
    train_seas_comp = best_models{model_index, 7};
    test_seas_comp = best_models{model_index, 8};
    params = best_models{model_index, 9};
    if model_index < 4
        if model_index==1
            % ========== save for output the first model only =============
            train_trendAndSeas = train_pred;
            test_trendAndSeas = test_pred;
            train_Seas = train_seas_comp;
            test_Seas = test_seas_comp;
            Params = params;
            
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
    sprintf('seasonality period %d, %d comp (NMSE: %.2f)', T, n_components, train_nmse), ... 
    sprintf("forecast (NMSE: %.2f)", test_nmse), ... 
    'Location', "southeast")
    title(sprintf('Seasonality period %d, %d comp', T, n_components));
    xlabel("Years");
    ylabel("Millions of dollars");
end
            