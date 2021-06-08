function [best_train_pred, best_test_pred, best_train_nmse, ... 
    best_test_nmse, best_p, best_d, best_q, best_P, ... 
                     best_Seasonality, best_Q] = FindBestSARIMA(p_sequence, d_sequence, q_sequence, ... 
                                                             P_sequence, Seasonality_sequence, Q_sequence, all_data)
% =========================================================================
train_data = all_data{1};
train_time = all_data{2};
test_data = all_data{3};
test_time = all_data{4};
% ======== initialization ({:,4} position is the best test_nmse) =========
best_models = cell(6,10);
best_models(1:6,4) = num2cell(repmat(-1000, 6,1));
% ======== fit ============================================================
for d = d_sequence
    for p = p_sequence
        for q = q_sequence
          if ~(p==0 && q==0)
           % ======== ARIMA ==============================================
           % ======== adjusting ar,ma order for arima function ===========
           if p==0
               p_real=[];
           else
               p_real = 1:p;
           end
           if q==0
               q_real=[];
           else
               q_real = 1:q;
           end
           % ======== fit ================================================
           try
                [train_pred, test_pred, ...
                    train_nmse, test_nmse] = FitAndForecastSARIMA( ... 
                                                 p_real, d, q_real, [], 0, [], train_data, test_data);
                if test_nmse>best_models{1,4}
                    best_models = [ {train_pred, test_pred, train_nmse, test_nmse, p, d, q, 0, 0, 0}; ...
                        best_models(1:5, 1:10) ];
                elseif test_nmse>best_models{2,4}
                    best_models = [ best_models(1, 1:10); {train_pred, test_pred, train_nmse, test_nmse, p, d, q, 0, 0, 0}; ...
                        best_models(2:5, 1:10) ];
                elseif test_nmse>best_models{3,4}
                    best_models = [ best_models(1:2, 1:10); {train_pred, test_pred, train_nmse, test_nmse, p, d, q, 0, 0, 0}; ...
                        best_models(3:5, 1:10) ];
                elseif test_nmse>best_models{4,4}
                   best_models = [ best_models(1:3, 1:10); {train_pred, test_pred, train_nmse, test_nmse, p, d, q, 0, 0, 0}; ...
                        best_models(4:5, 1:10) ];
                elseif test_nmse>best_models{5,4}
                   best_models = [ best_models(1:4, 1:10); {train_pred, test_pred, train_nmse, test_nmse, p, d, q, 0, 0, 0}; ...
                        best_models(5, 1:10) ];
                elseif test_nmse>best_models{6,4}
                   best_models = [ best_models(1:5, 1:10); ...
                        {train_pred, test_pred, train_nmse, test_nmse, p, d, q, 'no', 'no', 'no'} ];
                end
            catch
                warning('ARIMA(%d,%d,%d) unstable, discharged',p, d, q);
            end
            % ======== SARIMA ============================================
            for Seasonality = Seasonality_sequence
                for P = P_sequence
                    % ======== adjusting ma order for arima function =====
                    P_real = [];
                    if P>0
                        for number=1:P
                            P_real = [P_real,  number*Seasonality];
                        end
                    end
                    for Q = Q_sequence
                        % ======== adjusting ar order for arima function =
                        Q_real = [];
                        if Q>0
                          for number=1:P
                            Q_real = [Q_real,  number*Seasonality];
                          end
                        end
                        % ======== fit ===================================
                        try
                            [train_pred, test_pred, ...
                                train_nmse, test_nmse] = FitAndForecastSARIMA( ... 
                                                     p_real, d, q_real, P_real, Seasonality, Q_real, train_data, test_data);
                            if test_nmse>best_models{1,4}
                                best_models = [ {train_pred, test_pred, train_nmse, test_nmse, p, d, q, P, Seasonality, Q}; ...
                                    best_models(1:5, 1:10) ];
                            elseif test_nmse>best_models{2,4}
                                best_models = [ best_models(1, 1:10); {train_pred, test_pred, train_nmse, test_nmse, p, d, q, P, Seasonality, Q}; ...
                                    best_models(2:5, 1:10) ];
                            elseif test_nmse>best_models{3,4}
                                best_models = [ best_models(1:2, 1:10); {train_pred, test_pred, train_nmse, test_nmse, p, d, q, P, Seasonality, Q}; ...
                                    best_models(3:5, 1:10) ];
                            elseif test_nmse>best_models{4,4}
                               best_models = [ best_models(1:3, 1:10); {train_pred, test_pred, train_nmse, test_nmse, p, d, q, P, Seasonality, Q}; ...
                                    best_models(4:5, 1:10) ];
                            elseif test_nmse>best_models{5,4}
                               best_models = [ best_models(1:4, 1:10); {train_pred, test_pred, train_nmse, test_nmse, p, d, q, P, Seasonality, Q}; ...
                                    best_models(5, 1:10) ];
                            elseif test_nmse>best_models{6,4}
                               best_models = [ best_models(1:5, 1:10); ...
                                    {train_pred, test_pred, train_nmse, test_nmse, p, d, q, P, Seasonality, Q} ];
                            end
                        catch
                            warning('SARIMA(%d,%d,%d)x(%d,1,%d)_{%d} unstable, discharged',p,d,q,P,Q,Seasonality);
                        end
                    end
                end
            end
            fprintf('... (%d,%d,%d) done.\n',p,d,q)
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
    p = best_models{model_index, 5};
    d = best_models{model_index, 6};
    q = best_models{model_index, 7};
    P = best_models{model_index, 8};
    Seasonality = best_models{model_index, 9};
    Q = best_models{model_index, 10};
    if model_index < 4
        if model_index==1
            % ========== save for output the first model only =============
            best_train_pred = train_pred;
            best_test_pred = test_pred;
            best_train_nmse = train_nmse;
            best_test_nmse = test_nmse;
            best_p = p;
            best_d = d;
            best_q = q;
            best_P = p;
            best_Seasonality = Seasonality;
            best_Q = Q;
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
    if Seasonality==0
        legend("data", ... 
        sprintf('ARIMA(%d,%d,%d) (NMSE: %.2f)', p, d, q, train_nmse), ... 
        sprintf("forecast (NMSE: %.2f)", test_nmse), ... 
        'Location', "southeast")
        title(sprintf('ARIMA(%d,%d,%d)', p, d, q));
    else
        legend("data", ... 
        sprintf('SARIMA(%d,%d,%d)x(%d,1,%d)_{%d} (NMSE: %.2f)', p, d, q, P, Q, Seasonality, train_nmse), ... 
        sprintf("forecast (NMSE: %.2f)", test_nmse), ... 
        'Location', "southeast")
        title(sprintf('SARIMA(%d,%d,%d)x(%d,1,%d)_{%d}', p, d, q, P, Q, Seasonality));
        
    end
    xlabel("Years");
    ylabel("Millions of dollars");
end
            