import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from statsmodels.tsa.statespace.sarimax import SARIMAX
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
from sklearn.preprocessing import RobustScaler
from sklearn.model_selection import TimeSeriesSplit
import matplotlib.pyplot as plt
from scipy import stats
import itertools
import warnings

warnings.filterwarnings('ignore')


def load_and_prepare_data(csv_path, commodity_name, market_region=None):
    """
    Enhanced data preparation with additional features and robust preprocessing
    """
    df = pd.read_csv(csv_path)
    df['Date'] = pd.to_datetime(df['Date'])

    # Filter data
    df = df[df['Commodity'] == commodity_name]
    if market_region:
        df = df[df['Market Region'] == market_region]  # Fixed column name

    # Handle outliers with IQR method
    Q1 = df['Price per Unit (LKR/kg)'].quantile(0.25)
    Q3 = df['Price per Unit (LKR/kg)'].quantile(0.75)
    IQR = Q3 - Q1
    df = df[~((df['Price per Unit (LKR/kg)'] < (Q1 - 1.5 * IQR)) |
              (df['Price per Unit (LKR/kg)'] > (Q3 + 1.5 * IQR)))]

    # Create time series
    if market_region:
        price_series = df.set_index('Date')['Price per Unit (LKR/kg)']
    else:
        price_series = df.groupby('Date')['Price per Unit (LKR/kg)'].median()

    # Resample to daily frequency and interpolate
    price_series = price_series.resample('D').ffill().interpolate(method='cubic')

    # Convert to DataFrame with additional features
    price_series = pd.DataFrame(price_series)
    price_series.columns = ['price']
    price_series['rolling_mean'] = price_series['price'].rolling(window=7, min_periods=1).mean()
    price_series['rolling_std'] = price_series['price'].rolling(window=7, min_periods=1).std().fillna(0)

    return price_series


def find_optimal_parameters(train_data):
    """
    Find optimal SARIMA parameters using grid search
    """
    p = range(0, 2)
    d = range(0, 2)
    q = range(0, 2)

    pdq = list(itertools.product(p, d, q))
    seasonal_pdq = [(x[0], x[1], x[2], 7) for x in pdq]

    best_aic = float('inf')
    best_params = None
    best_seasonal_params = None

    for param in pdq:
        for seasonal_param in seasonal_pdq:
            try:
                model = SARIMAX(train_data['price'],
                                order=param,
                                seasonal_order=seasonal_param,
                                enforce_stationarity=False,
                                enforce_invertibility=False)
                results = model.fit(disp=0)

                if results.aic < best_aic:
                    best_aic = results.aic
                    best_params = param
                    best_seasonal_params = seasonal_param
            except:
                continue

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

        results = model.fit(disp=0)
        return results
    except:
        print("Falling back to simpler model...")
        model = SARIMAX(data['price'],
                        order=(1, 1, 1),
                        seasonal_order=(1, 1, 1, 7),
                        enforce_stationarity=False,
                        enforce_invertibility=False)

        results = model.fit(disp=0)
        return results


def make_predictions(model, data, steps=7):
    """
    Make predictions with confidence intervals
    """
    last_rolling_mean = data['rolling_mean'].iloc[-1]
    last_rolling_std = data['rolling_std'].iloc[-1]

    future_exog = pd.DataFrame({
        'rolling_mean': [last_rolling_mean] * steps,
        'rolling_std': [last_rolling_std] * steps
    })

    forecast = model.forecast(steps=steps, exog=future_exog)
    confidence_intervals = model.get_forecast(steps=steps, exog=future_exog).conf_int()

    last_date = data.index[-1]
    prediction_dates = [(last_date + timedelta(days=i + 1)).date() for i in range(steps)]

    forecast = np.maximum(forecast, 0)

    return list(zip(prediction_dates, forecast.values)), confidence_intervals


def analyze_commodity(csv_path, commodity_name, market_region=None):
    """
    Analyze commodity prices and make predictions
    """
    print(f"\nAnalyzing {commodity_name}" + (f" in {market_region}" if market_region else " (all regions)"))

    # Load and prepare data
    price_series = load_and_prepare_data(csv_path, commodity_name, market_region)

    if len(price_series) < 14:
        print("Insufficient data for analysis")
        return None, None

    # Split data
    train_size = int(len(price_series) * 0.8)
    train_data = price_series[:train_size]
    test_data = price_series[train_size:]

    # Find optimal parameters
    order, seasonal_order = find_optimal_parameters(train_data)
    print(f"Optimal parameters - SARIMA{order}x{seasonal_order}")

    # Train model
    model = train_sarima_model(train_data, order, seasonal_order)

    # Make predictions
    predictions, confidence_intervals = make_predictions(model, price_series)

    # Calculate metrics
    test_exog = test_data[['rolling_mean', 'rolling_std']]
    test_predictions = model.predict(start=test_data.index[0],
                                     end=test_data.index[-1],
                                     exog=test_exog)

    metrics = {
        'MSE': mean_squared_error(test_data['price'], test_predictions),
        'MAE': mean_absolute_error(test_data['price'], test_predictions),
        'R2': r2_score(test_data['price'], test_predictions),
        'MAPE': np.mean(np.abs((test_data['price'] - test_predictions) / test_data['price'])) * 100,
        'Accuracy (%)': 100 - np.mean(np.abs((test_data['price'] - test_predictions) / test_data['price'])) * 100
    }

    print("\nPerformance Metrics:")
    for metric, value in metrics.items():
        print(f"{metric}: {value:.4f}")

    print(f"\n{commodity_name} price predictions for next 7 days:")
    for date, price in predictions:
        print(f"{date}: {price:.2f} LKR/kg")

    return predictions, metrics


def main():
    """
    Main function with comprehensive analysis pipeline
    """
    # Configuration
    csv_path = 'vegetable_fruit_prices_new2.csv'

    try:
        # Load dataset
        df = pd.read_csv(csv_path)
        print("Dataset loaded successfully.")

        # Get unique commodities and regions
        commodities = df['Commodity'].unique()
        regions = df['Market Region'].unique()

        print(f"\nTotal commodities: {len(commodities)}")
        print(f"Total regions: {len(regions)}")

        # Analysis results storage
        analysis_results = {
            'predictions': {},
            'metrics': {}
        }

        # Analyze each commodity
        for commodity in commodities:
            try:
                predictions, metrics = analyze_commodity(csv_path, commodity)
                if predictions and metrics:
                    analysis_results['predictions'][commodity] = predictions
                    analysis_results['metrics'][commodity] = metrics
            except Exception as e:
                print(f"Error analyzing {commodity}: {str(e)}")
                continue

        # Save results
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        results_file = f"analysis_results_{timestamp}.csv"

        results_df = pd.DataFrame()
        for commodity, preds in analysis_results['predictions'].items():
            dates, prices = zip(*preds)
            results_df[f"{commodity}_date"] = dates
            results_df[f"{commodity}_price"] = prices

        results_df.to_csv(results_file, index=False)
        print(f"\nResults saved to {results_file}")

    except Exception as e:
        print(f"Error in main execution: {str(e)}")

    print("\nAnalysis complete!")


if __name__ == "__main__":
    main()