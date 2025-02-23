import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from statsmodels.tsa.statespace.sarimax import SARIMAX
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
from sklearn.model_selection import TimeSeriesSplit
import matplotlib.pyplot as plt
from scipy import stats
from statsmodels.tsa.seasonal import STL
import itertools
import warnings
from joblib import Parallel, delayed

warnings.filterwarnings('ignore')

def load_and_prepare_data(csv_path, commodity_name, market_region=None):
    """
    Enhanced data preparation with outlier removal, trend analysis, and Fourier terms
    """
    # Read CSV file
    df = pd.read_csv(csv_path)
    # Convert date column to datetime
    df['Date'] = pd.to_datetime(df['Date'])
    # Filter for specific commodity
    df = df[df['Commodity'] == commodity_name]
    # Filter for specific region if provided
    if market_region:
        df = df[df['Market Region'] == market_region]
    # Sort by date
    df = df.sort_values('Date')
    if market_region:
        price_series = df.set_index('Date')['Price per Unit (LKR/kg)']
    else:
        # Use median instead of mean to reduce outlier impact
        price_series = df.groupby('Date')['Price per Unit (LKR/kg)'].median()
    # Remove outliers using IQR
    Q1 = price_series.quantile(0.25)
    Q3 = price_series.quantile(0.75)
    IQR = Q3 - Q1
    lower_bound = Q1 - 1.5 * IQR
    upper_bound = Q3 + 1.5 * IQR
    price_series = price_series[(price_series >= lower_bound) & (price_series <= upper_bound)]
    # Resample to daily frequency with forward fill first, then interpolate
    price_series = price_series.resample('D').ffill().interpolate(method='cubic')
    # Add rolling statistics
    price_series = pd.DataFrame(price_series)
    price_series.columns = ['price']
    price_series['rolling_mean'] = price_series['price'].rolling(window=7, min_periods=1).mean()
    price_series['rolling_std'] = price_series['price'].rolling(window=7, min_periods=1).std().fillna(0)
    # Add Fourier terms for seasonality
    def add_fourier_terms(data, period, num_terms):
        for i in range(1, num_terms + 1):
            data[f'sin_term_{i}'] = np.sin(2 * np.pi * i * data.index.dayofyear / period)
            data[f'cos_term_{i}'] = np.cos(2 * np.pi * i * data.index.dayofyear / period)
        return data
    price_series = add_fourier_terms(price_series, period=365, num_terms=3)
    # Add lag features
    for lag in range(1, 8):  # Add lags for the past 7 days
        price_series[f'lag_{lag}'] = price_series['price'].shift(lag)
    price_series.dropna(inplace=True)  # Drop rows with NaNs introduced by lagging
    return price_series

def find_optimal_parameters(train_data):
    """
    Find optimal SARIMA parameters using grid search with time-series cross-validation
    """
    # Define parameter ranges
    p = range(0, 2)  # Reduced range for AR order
    d = range(0, 2)  # Differencing order
    q = range(0, 2)  # Reduced range for MA order
    pdq = list(itertools.product(p, d, q))
    seasonal_pdq = [(x[0], x[1], x[2], 7) for x in pdq]
    best_aic = float('inf')
    best_params = None
    best_seasonal_params = None
    tscv = TimeSeriesSplit(n_splits=5)

    # Try each combination
    for param in pdq:
        for seasonal_param in seasonal_pdq:
            try:
                aic_scores = []
                for train_idx, test_idx in tscv.split(train_data):
                    train_split = train_data.iloc[train_idx]
                    test_split = train_data.iloc[test_idx]
                    model = SARIMAX(train_split['price'],
                                    exog=train_split[['rolling_mean', 'rolling_std']],
                                    order=param,
                                    seasonal_order=seasonal_param,
                                    enforce_stationarity=False,
                                    enforce_invertibility=False)
                    results = model.fit(disp=0, maxiter=200, method='nm')  # Increased maxiter and alternative method
                    aic_scores.append(results.aic)
                avg_aic = np.mean(aic_scores)
                if avg_aic < best_aic:
                    best_aic = avg_aic
                    best_params = param
                    best_seasonal_params = seasonal_param
            except Exception as e:
                print(f"Failed for params {param}x{seasonal_param}: {e}")
                continue

    # If no parameters worked, use default
    if best_params is None:
        best_params = (1, 1, 1)
        best_seasonal_params = (1, 1, 1, 7)
    return best_params, best_seasonal_params

def train_sarima_model(data, order, seasonal_order):
    """
    Train SARIMA model with optimized parameters
    """
    try:
        model = SARIMAX(data['price'],
                        exog=data[['rolling_mean', 'rolling_std']],
                        order=order,
                        seasonal_order=seasonal_order,
                        enforce_stationarity=False,
                        enforce_invertibility=False)
        results = model.fit(disp=0, maxiter=200, method='nm')  # Increased maxiter and alternative method
        return results
    except Exception as e:
        # Fallback to simpler model if complex one fails
        print(f"Falling back to simpler model due to error: {e}")
        model = SARIMAX(data['price'],
                        order=(1, 1, 1),
                        seasonal_order=(1, 1, 1, 7),
                        enforce_stationarity=False,
                        enforce_invertibility=False)
        results = model.fit(disp=0)
        return results
def make_predictions(model, data, steps=7):
    """
    Make predictions with confidence intervals and trend analysis
    """
    # Prepare exogenous variables for forecasting
    last_rolling_mean = data['rolling_mean'].iloc[-1]
    last_rolling_std = data['rolling_std'].iloc[-1]
    # Create future exog data
    future_exog = pd.DataFrame({
        'rolling_mean': [last_rolling_mean] * steps,
        'rolling_std': [last_rolling_std] * steps
    })
    # Make predictions
    forecast = model.forecast(steps=steps, exog=future_exog)
    confidence_intervals = model.get_forecast(steps=steps, exog=future_exog).conf_int()
    # Generate future dates
    last_date = data.index[-1]
    prediction_dates = [(last_date + timedelta(days=i + 1)).date() for i in range(steps)]
    # Ensure predictions don't go below zero
    forecast = np.maximum(forecast, 0)
    return list(zip(prediction_dates, forecast.values)), confidence_intervals

def calculate_metrics(y_true, y_pred):
    """
    Calculate comprehensive performance metrics
    """
    mse = mean_squared_error(y_true, y_pred)
    mae = mean_absolute_error(y_true, y_pred)
    r2 = r2_score(y_true, y_pred)
    mape = np.mean(np.abs((y_true - y_pred) / y_true)) * 100
    accuracy = 100 - mape
    return {
        'Mean Squared Error': mse,
        'Mean Absolute Error': mae,
        'R-squared': r2,
        'MAPE (%)': mape,
        'Accuracy (%)': accuracy
    }

def plot_predictions(historical_data, predictions, confidence_intervals, title):
    """
    Enhanced plotting with trend lines and confidence intervals
    """
    plt.figure(figsize=(15, 8))
    # Plot historical data
    plt.plot(historical_data.index, historical_data['price'], label='Historical Data', color='blue')
    # Plot rolling mean
    plt.plot(historical_data.index, historical_data['rolling_mean'],
             label='7-day Moving Average', color='green', alpha=0.5)
    # Extract prediction dates and values
    pred_dates = [pd.Timestamp(date) for date, _ in predictions]
    pred_values = [value for _, value in predictions]
    # Plot predictions
    plt.plot(pred_dates, pred_values, 'r', label='Predictions', linewidth=2)
    # Plot confidence intervals
    plt.fill_between(pred_dates,
                     confidence_intervals.iloc[:, 0],
                     confidence_intervals.iloc[:, 1],
                     color='r', alpha=0.1,
                     label='95% Confidence Interval')
    plt.title(title, fontsize=14, pad=20)
    plt.xlabel('Date', fontsize=12)
    plt.ylabel('Price per Unit (LKR/kg)', fontsize=12)
    plt.legend(loc='best')
    plt.grid(True, alpha=0.3)
    # Rotate x-axis labels for better readability
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

def analyze_commodity(csv_path, commodity_name, market_region=None):
    """
    Enhanced analysis with optimized parameters and additional metrics
    """
    print(f"\nAnalyzing {commodity_name}" + (f" in {market_region}" if market_region else " (all regions)"))
    # Load and prepare data
    price_series = load_and_prepare_data(csv_path, commodity_name, market_region)
    if len(price_series) < 14:
        print("Insufficient data for analysis")
        return
    # Split data into training and testing sets
    train_size = int(len(price_series) * 0.8)
    train_data = price_series[:train_size]
    test_data = price_series[train_size:]
    # Find optimal parameters
    print("Finding optimal model parameters...")
    order, seasonal_order = find_optimal_parameters(train_data)
    print(f"Optimal parameters - SARIMA{order}x{seasonal_order}")
    # Train model
    print("Training model with optimized parameters...")
    model = train_sarima_model(train_data, order, seasonal_order)
    # Make predictions on test set
    test_exog = test_data[['rolling_mean', 'rolling_std']]
    test_predictions = model.predict(start=test_data.index[0],
                                     end=test_data.index[-1],
                                     exog=test_exog)
    # Calculate metrics
    metrics = calculate_metrics(test_data['price'], test_predictions)
    print("\nPerformance Metrics:")
    for metric, value in metrics.items():
        print(f"{metric}: {value:.4f}")
    # Make future predictions
    predictions, confidence_intervals = make_predictions(model, price_series)
    print(f"\n{commodity_name} price predictions for next 7 days:")
    for date, price in predictions:
        print(f"{date}: {price:.2f} LKR/kg")
    # Plot results
    title = f"{commodity_name} Price Predictions" + (f" - {market_region}" if market_region else "")
    plot_predictions(price_series, predictions, confidence_intervals, title)
    return predictions, metrics

def main():
    csv_path = 'vegetable_fruit_prices_new2.csv'  # Update with your CSV path
    # Get unique commodities and regions
    df = pd.read_csv(csv_path)
    commodities = df['Commodity'].unique()
    regions = df['Market Region'].unique()
    print("Available commodities:", commodities)
    print("Available regions:", regions)
    # Choose a single commodity or iterate over multiple ones
    commodity_names = [
        'Winged Bean', 'Bitter Melon', 'Brinjal', 'Long Purple Eggplant',
        'Asiatic Pennywort', 'Red Spinach', 'Pennywort', 'Leeks', 'Carrot',
        'Beetroot', 'Cabbage', 'Knol-Khol', 'Pumpkin', 'Onion', 'Potato',
        'Drumsticks', 'Jackfruit', 'Breadfruit', 'Taro', 'Manioc'
    ]
    for commodity_name in commodity_names:
        analyze_commodity(csv_path, commodity_name)  # Call function for each commodity

if __name__ == "__main__":
    main()