import random
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from datetime import datetime, timedelta
from sklearn.preprocessing import RobustScaler
from tensorflow.keras.models import Sequential, Model
from tensorflow.keras.layers import LSTM, Dense, Dropout, BatchNormalization, Bidirectional, Input, Attention, Flatten
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import tensorflow as tf
from typing import List, Dict, Tuple, Union
import logging
from sklearn.model_selection import TimeSeriesSplit
import kerastuner as kt

def generate_six_month_data():
    np.random.seed(42)
    vegetables = {
        'Tomato': {'base': 140, 'volatility': 0.05},
        'Cucumber': {'base': 100, 'volatility': 0.04},
        'Carrot': {'base': 90, 'volatility': 0.03},
        # 'Onion': {'base': 120, 'volatility': 0.06}
    }
    start_date = datetime(2023, 7, 2)
    dates = [start_date + timedelta(days=x) for x in range(182)]
    data_dict = {}
    for veg, params in vegetables.items():
        prices = []
        base_price = params['base']
        volatility = params['volatility']
        current_price = base_price
        for _ in dates:
            price_change = np.random.normal(0, volatility * base_price)
            current_price = current_price + price_change
            current_price = current_price * 0.95 + base_price * 0.05
            current_price = np.clip(current_price, base_price * 0.8, base_price * 1.2)
            prices.append(round(current_price, 2))
        data_dict[veg] = pd.DataFrame({'Price': prices}, index=dates)
    return data_dict

class MultiVegetableLSTMPricePredictor:
    def __init__(self, vegetables: List[str], window_size: int = 30):
        self.vegetables = vegetables
        self.window_size = window_size
        self.scalers = {veg: RobustScaler() for veg in vegetables}
        self.models = {veg: None for veg in vegetables}
        logging.basicConfig(level=logging.INFO)

    def build_model(self, hp, input_shape):
        inputs = Input(shape=input_shape)

        # LSTM Layer
        lstm_out = LSTM(units=hp.Int('units', min_value=64, max_value=256, step=64), return_sequences=True)(inputs)

        # Attention Layer
        attention_out = Attention()([lstm_out, lstm_out])

        # Flatten before Dense layers
        x = Flatten()(attention_out)
        dropout_rate = hp.Choice('dropout', values=[0.3, 0.5])
        x = Dropout(dropout_rate)(x)
        x = Dense(64, activation='relu')(x)
        outputs = Dense(1, activation='linear')(x)  # Linear for regression

        model = Model(inputs, outputs)
        model.compile(optimizer='adam', loss='mse', metrics=['mae'])  # MSE for regression
        return model

    def _create_sequences(self, data: np.ndarray) -> Tuple[np.ndarray, np.ndarray]:
        X, y = [], []
        for i in range(len(data) - self.window_size):
            X.append(data[i:i + self.window_size])
            y.append(data[i + self.window_size])
        return np.array(X), np.array(y)

    def train(self, data: Dict[str, pd.DataFrame], epochs: int = 200, batch_size: int = 32):
        histories = {}
        for veg, df in data.items():
            logging.info(f"\nTraining model for {veg}...")
            scaled_data = self.scalers[veg].fit_transform(df['Price'].values.reshape(-1, 1))
            X, y = self._create_sequences(scaled_data)

            tuner = kt.RandomSearch(
                lambda hp: self.build_model(hp, (self.window_size, 1)),
                objective='val_loss',
                max_trials=10,
                executions_per_trial=3,
                directory='tuner_logs',
                project_name=f'{veg}_tuning'
            )

            tuner.search(
                X, y,
                epochs=epochs,
                batch_size=batch_size,
                validation_split=0.2,
                callbacks=[
                    EarlyStopping(monitor='val_loss', patience=15, restore_best_weights=True),
                    ReduceLROnPlateau(monitor='val_loss', factor=0.5, patience=7)
                ]
            )

            self.models[veg] = tuner.get_best_models(num_models=1)[0]
            histories[veg] = tuner.oracle.get_best_trials(num_trials=1)[0].metrics.get_last_value('val_loss')

        return histories

    def predict(self, veg: str, recent_data: np.ndarray) -> Union[float, None]:
        try:
            recent_scaled = self.scalers[veg].transform(recent_data.reshape(-1, 1))
            X = recent_scaled[-self.window_size:].reshape(1, self.window_size, 1)
            prediction = self.models[veg].predict(X, verbose=0)
            return float(self.scalers[veg].inverse_transform(prediction)[0][0])
        except Exception as e:
            logging.error(f"Error predicting for {veg}: {str(e)}")
            return None

    def evaluate_and_plot(self, veg: str, test_data: pd.DataFrame, save_plot: bool = False):
        true_prices = test_data['Price'].values
        predicted_prices = [
            self.predict(veg, true_prices[i - self.window_size:i])
            for i in range(self.window_size, len(true_prices))
        ]

        true_prices_cut = true_prices[self.window_size:]
        metrics = {
            "MSE": mean_squared_error(true_prices_cut, predicted_prices),
            "RMSE": np.sqrt(mean_squared_error(true_prices_cut, predicted_prices)),
            "MAE": mean_absolute_error(true_prices_cut, predicted_prices),
            "R2": r2_score(true_prices_cut, predicted_prices)
        }

        plt.figure(figsize=(12, 6))
        plt.plot(test_data.index[self.window_size:], true_prices_cut, label='Actual Prices', linewidth=2)
        plt.plot(test_data.index[self.window_size:], predicted_prices, label='Predicted Prices', linestyle='--')
        plt.title(f'{veg} Price Prediction')
        plt.xlabel('Date')
        plt.ylabel('Price (Rs/kg)')
        plt.legend()
        plt.grid(True)
        plt.xticks(rotation=45)
        plt.tight_layout()

        if save_plot:
            plt.savefig(f'{veg}_prediction.png')
        else:
            plt.show()
        plt.close()

        return metrics

def main():
    data = generate_six_month_data()
    vegetables = list(data.keys())
    print("\nInitializing LSTM model...")
    model = MultiVegetableLSTMPricePredictor(vegetables)
    print("\nTraining model with hyperparameter tuning...")
    histories = model.train(data, epochs=200, batch_size=32)

    print("\nEvaluating model performance...")
    for veg in vegetables:
        print(f"\nEvaluating {veg}...")
        metrics = model.evaluate_and_plot(veg, data[veg], save_plot=True)
        print(f"Performance metrics for {veg}:")
        for metric, value in metrics.items():
            print(f"{metric}: {value:.4f}")

if __name__ == "__main__":
    main()
