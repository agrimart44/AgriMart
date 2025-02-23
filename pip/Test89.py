import pandas as pd
import numpy as np
from datetime import datetime, timedelta
from statsmodels.tsa.statespace.sarimax import SARIMAX
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import matplotlib.pyplot as plt
from scipy import stats
import itertools
import warnings

warnings.filterwarnings('ignore')

import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate(r'C:\Users\rukshan\PycharmProjects\PythonProject\.venv\Lib\site-packages\pip\connect-model-firebase-adminsdk-fbsvc-06db006c16.json')
firebase_admin.initialize_app(cred)
db = firestore.client()


def load_and_prepare_data(csv_path, commodity_name, market_region=None):
    """
    Enhanced data preparation with outlier removal and trend analysis
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

    # Remove outliers using Z-score
    z_scores = stats.zscore(price_series)
    price_series = price_series[abs(z_scores) < 3]

    # Resample to daily frequency with forward fill first, then interpolate
    price_series = price_series.resample('D').ffill().interpolate(method='cubic')

    # Add rolling statistics
    price_series = pd.DataFrame(price_series)
    price_series.columns = ['price']
    price_series['rolling_mean'] = price_series['price'].rolling(window=7, min_periods=1).mean()
    price_series['rolling_std'] = price_series['price'].rolling(window=7, min_periods=1).std().fillna(0)

    return price_series

def find_optimal_parameters(train_data):
    """
    Find optimal SARIMA parameters using grid search
    """
    # Define parameter ranges
    p = range(0, 2)
    d = range(0, 2)
    q = range(0, 2)

    # Create list of all parameter combinations
    pdq = list(itertools.product(p, d, q))
    seasonal_pdq = [(x[0], x[1], x[2], 7) for x in pdq]

    best_aic = float('inf')
    best_params = None
    best_seasonal_params = None

    # Try each combination
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

        results = model.fit(disp=0)
        return results
    except:
        # Fallback to simpler model if complex one fails
        print("Falling back to simpler model...")
        model = SARIMAX(data['price'],
                        order=(1, 1, 1),
                        seasonal_order=(1, 1, 1, 7),
                        enforce_stationarity=False,
                        enforce_invertibility=False)

        results = model.fit(disp=0)
        return results





def main():
    csv_path = 'vegetable_fruit_prices_new2.csv'  # Update with your CSV path

    # Get unique commodities and regions
    df = pd.read_csv(csv_path)
    commodities = df['Commodity'].unique()
    regions = df['Market Region'].unique()

    print("Available commodities:", commodities)
    print("Available regions:", regions)


    # Choose a single commodity or iterate over multiple ones
    commodity_names = ['Winged Bean', 'Bitter Melon', 'Brinjal', 'Long Purple Eggplant',
     'Asiatic Pennywort', 'Red Spinach', 'Pennywort', 'Leeks', 'Carrot' ,'Beetroot',
     'Cabbage', 'Knol-Khol', 'Pumpkin', 'Onion', 'Potato', 'Drumsticks', 'Jackfruit',
     'Breadfruit', 'Taro', 'Manioc']  # List instead of tuple

    for commodity_name in commodity_names:
        analyze_commodity(csv_path, commodity_name)  # Call function for each commodity


if __name__ == "__main__":
    main()