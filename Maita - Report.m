%% Data =========================

load("TT")
Food = timetable(TT.Time, TT.food, 'VariableNames', {'Data'});

disp(head(Food));
plot(Food.Time, Food.Data);
title("Original time series")
xlabel("Years")
ylabel("Millions of dollars")
disp(numel(Food.Data));

mean_1 = mean(Food.Data(1:100));
mean_2 = mean(Food.Data(101:200));
mean_3 = mean(Food.Data(201:300));
mean_three_intervals = [repmat(mean_1,100), repmat(mean_2,100), repmat(mean_3,100)];
plot(Food.Time, Food.Data,Food.Time, mean_three_intervals, "r")
xline(Food.Time(100));xline(Food.Time(101)); xline(Food.Time(200));xline(Food.Time(201));
legend("data", "three-intervals mean value")
title("Three-intervals mean value")
xlabel("Years")
ylabel("Millions of dollars")
format bank; disp(mean(Food.Data)); 

autocorr(Food.Data);

train_data = Food.Data(1:270);
train_time = Food.Time(1:270);
test_data =  Food.Data(271:end);
test_time = Food.Time(271:end);
all_data = {train_data,train_time, test_data, test_time};


%% Trend =========================

figure()
for degree = 1:3
    subplot(3,1,degree)
    FitAndForecastTrend(all_data, degree);
end

[train_trend, test_trend, params] = FitAndForecastTrend( ...
     all_data,2);
format bank; disp(params)
dt_train_data = train_data - train_trend;
dt_test_data = test_data - test_trend;
plot(train_time, dt_train_data);
title("Detrended training time series");
xlabel("Years");
ylabel("Millions of dollars");


%% Seasonality =========================

pspectrum(dt_train_data)


trend_comp = {train_trend, test_trend};

figure()
[train_trendAndSeas, test_trendAndSeas, ... 
    train_seas, test_seas, params] = FindBestSeasons(...
          12:12:120, 1:12, all_data, trend_comp ...
);

format bank; disp(params)
dtds_train_data = train_data - train_trendAndSeas;

figure()
plot([train_time; test_time], [dt_train_data; dt_test_data])
hold on
plot(train_time, train_seas, "r")
plot(test_time, test_seas, "r:", 'LineWidth',1.8)
hold off
legend("detrended data", ... 
    sprintf('seasonality component'), ... 
    sprintf("forecast"), ... 
    'Location', "southeast")
title('Seasonality component');
xlabel("Years");
ylabel("Millions of dollars");
figure()
plot(train_time, dtds_train_data);
title("Detrended deseasonalized training time series");
xlabel("Years");
ylabel("Millions of dollars");


%% AR, MA, ARMA

autocorr(dtds_train_data)

components = {train_trendAndSeas, test_trendAndSeas};
FindBestARMA(0, 1:12, all_data, components);

figure()
parcorr(dtds_train_data)

FindBestARMA(1:12, 0, all_data, components);

FindBestARMA(1:12, 1:12, all_data, components);


%% SARIMA ====================

subplot(2,1,1)
plot(train_time(2:end), diff(train_data));
title('Differentiated time series')
subplot(2,1,2)
plot(train_time(3:end),  diff(train_data, 2));
title('2nd-degree differentiated time series')


FindBestSARIMA(0:12, 1:3, 0:12, 0:2, [4 6 12], 0:2, all_data);


%% ARMAX ====================

Beer = timetable(TT.Time, TT.beer, 'VariableNames', {'Data'});
disp(head(Beer));
plot(Beer.Time, Beer.Data, 'g');
title("Input time series")
xlabel("Years")
ylabel("Millions of dollars")
disp(numel(Beer.Data))

train_input = Beer.Data(1:270);
test_input = Beer.Data(271:end);
input = {train_input, test_input};

crosscorr(dtds_train_data,train_input)

FindBestARMAX(0:12,1:12,0:12, all_data, input, components)

%% Conclusion ==================

train = iddata(dtds_train_data, train_input, 'TimeUnit','months');
model = armax(train, [7 [2] 3 1]);
model

train_pred = dtds_train_data + resid(train,model).y + train_trendAndSeas;
test_pred = forecast(model,train, numel(test_data),test_input).y + test_trendAndSeas;
model_residuals = Food.Data - [train_pred; test_pred];
figure()
plot(Food.Time, model_residuals, 'o-')
title("Model Residuals")
xlabel("Years")
ylabel("Millions of dollars")
figure()
histogram(model_residuals, 30)
title("Histogram Model Residuals")
xlabel("Millions of dollars")
ylabel("Frequency")

