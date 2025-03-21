import numpy as np
import pandas as pd
import json
import matplotlib.pyplot as plt
import logging
import os
import shutil
import PyPDF2
import re
import tensorflow as tf
from sklearn.preprocessing import RobustScaler
from tensorflow.keras.models import Model
from tensorflow.keras.layers import LSTM, Dense, Dropout, Bidirectional, Input, Flatten, MultiHeadAttention
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import keras_tuner as kt
from datetime import datetime
import pandas as pd

def extract_vegetable_wholesale_prices(pdf_path):
    """
    Extract vegetable wholesale prices from a PDF file
    """
    # Extract date from the file name
    date_pattern = r'(\d{8})'  # Matches 8 consecutive digits
    match = re.search(date_pattern, pdf_path)

    if match:
        date_str = match.group(1)
        date_obj = datetime.strptime(date_str, '%Y%m%d')
        formatted_date = date_obj.strftime('%Y-%m-%d')  # Format as YYYY-MM-DD
        print(f"Extracted Date: {formatted_date}")
    else:
        print("No date found in the file name.")
        formatted_date = None  # Set as None if date not found

    # Extract vegetable prices from PDF
    with open(pdf_path, 'rb') as file:
        pdf_reader = PyPDF2.PdfReader(file)
        page = pdf_reader.pages[1]
        text = page.extract_text()

        # Updated pattern to match only vegetable name and today's price
        pattern = r'([A-Za-z\s]+?)\s+Rs\./kg\s+(\d{2,5}\.?\d*)'

        matches = re.findall(pattern, text)

        # Create DataFrame
        df = pd.DataFrame(matches, columns=['Vegetable', 'today'])
        df['Vegetable'] = df['Vegetable'].str.strip().replace('\n', '', regex=True)

        # Filter specific vegetables
        df = df[df['Vegetable'].str.strip().isin([
            'Beans', 'Carrot', 'Cabbage', 'Tomato', 'Brinjal',
            'Pumpkin', 'Snake gourd', 'Lime'
        ])]

        # Add the extracted date to the DataFrame
        df['Date'] = formatted_date

        return df





class MultiVegetablePricePredictor:
    def __init__(self, vegetables, window_size=30):
        self.vegetables = vegetables
        self.window_size = window_size
        self.z_score_threshold = 3.0  # or whatever threshold you desire

        self.scalers = {veg: RobustScaler() for veg in vegetables}
        self.models = {veg: None for veg in vegetables}
        self._prediction_fns = {}  # Initialize prediction functions dictionary
        logging.basicConfig(level=logging.INFO)

    # def _prepare_data(self, df):
    #     """
    #     Prepare data for each vegetable
    #     """
    #     data = {}
    #     for veg in self.vegetables:
    #         # Extract prices for specific vegetable
    #         veg_df = df[df['Vegetable'] == veg]
    #
    #         # Apply Z-Score function to the vegetable data
    #         veg_df = add_z_score(veg_df)
    #
    #         # Ensure there's data available for processing
    #         if len(veg_df) > 0:
    #             # Store the price and Z-Score in the dictionary
    #             data[veg] = pd.DataFrame({'Price': veg_df['today'], 'Z-Score': veg_df['Z-Score']})
    #
    #     return data
    def _prepare_data(self, df):
        """
        Prepare data for each vegetable and handle outliers
        """
        data = {}
        outlier_stats = {}
        removed_outliers = {}

        for veg in self.vegetables:
            try:
                veg_df = df[df['Vegetable'] == veg].copy()

                if len(veg_df) > 0:
                    veg_df['today'] = pd.to_numeric(veg_df['today'], errors='coerce')
                    veg_df.dropna(subset=['today'], inplace=True)

                    if len(veg_df) > 0:
                        # Handle potential zero standard deviation
                        std = veg_df['today'].std()
                        if std == 0:
                            logging.warning(f"Zero standard deviation for {veg}, skipping Z-score calculation")
                            data[veg] = pd.DataFrame({'Price': veg_df['today'], 'Z-Score': 0})
                            continue

                        veg_df['Z-Score'] = (veg_df['today'] - veg_df['today'].mean()) / std

                        # Identify outliers
                        outliers = veg_df[abs(veg_df['Z-Score']) > self.z_score_threshold]
                        non_outliers = veg_df[abs(veg_df['Z-Score']) <= self.z_score_threshold]

                        outlier_stats[veg] = {
                            'count': len(outliers),
                            'dates': outliers['Date'].tolist() if 'Date' in outliers.columns else [],
                            'prices': outliers['today'].tolist(),
                            'z_scores': outliers['Z-Score'].tolist()
                        }

                        removed_outliers[veg] = outliers

                        if len(outliers) > 0:
                            logging.info(f"\nRemoving outliers for {veg}:")
                            logging.info(f"Number of outliers removed: {len(outliers)}")
                            logging.info(f"Original data points: {len(veg_df)}")
                            logging.info(f"Remaining data points: {len(non_outliers)}")

                        data[veg] = pd.DataFrame({
                            'Price': non_outliers['today'],
                            'Z-Score': non_outliers['Z-Score']
                        })
                    else:
                        logging.warning(f"No valid data points for {veg} after removing NaN values")
            except Exception as e:
                logging.error(f"Error processing data for {veg}: {e}")
                continue

        return data, outlier_stats, removed_outliers

    def predict_next_7_days(self, df):
        """
        Predicts the vegetable prices for the next 7 days
        """
        predictions = {}
        data, _, _ = self._prepare_data(df)  # Get cleaned data

        for veg, prices in data.items():
            if len(prices) < self.window_size:
                logging.warning(f"Not enough data to predict {veg}. Skipping...")
                continue

            # Get the last `window_size` days of prices
            last_data = prices['Price'].values[-self.window_size:].reshape(-1, 1)

            # Scale the input data using the trained scaler
            scaled_data = self.scalers[veg].transform(last_data)

            predictions_list = []

            for _ in range(7):  # Predict next 7 days
                input_seq = scaled_data[-self.window_size:].reshape(1, self.window_size, 1)
                predicted_price = self.models[veg].predict(input_seq, verbose=0)[0, 0]

                # Inverse transform to get original scale price
                actual_price = self.scalers[veg].inverse_transform([[predicted_price]])[0, 0]
                predictions_list.append(actual_price)

                # Append the new prediction to scaled_data for next iteration
                scaled_data = np.append(scaled_data, [[predicted_price]], axis=0)

            predictions[veg] = predictions_list

        return predictions

    def build_model(self, hp, input_shape):
        inputs = Input(shape=input_shape)

        # Tune number of LSTM layers
        x = inputs
        for _ in range(hp.Int('num_lstm_layers', 1, 3)):
            x = Bidirectional(LSTM(
                units=hp.Int('units', min_value=32, max_value=256, step=32),
                return_sequences=True,
                recurrent_dropout=hp.Float('recurrent_dropout', 0.0, 0.5, step=0.1)
            ))(x)

        # Attention Mechanism
        attention_out = MultiHeadAttention(
            num_heads=hp.Int('num_heads', min_value=2, max_value=8, step=2),
            key_dim=hp.Int('key_dim', min_value=16, max_value=64, step=16)
        )(x, x)

        x = Flatten()(attention_out)
        x = Dropout(hp.Float('dropout', min_value=0.1, max_value=0.5, step=0.1))(x)
        x = Dense(hp.Int('dense_units', min_value=32, max_value=128, step=32), activation='relu')(x)
        outputs = Dense(1, activation='linear')(x)

        model = Model(inputs, outputs)

        # Tune learning rate and optimizer
        lr = hp.Float('learning_rate', min_value=1e-4, max_value=1e-2, sampling='log')
        batch_size = hp.Choice('batch_size', values=[16, 32, 64])
        optimizer = hp.Choice('optimizer', values=['adam', 'rmsprop', 'sgd'])

        if optimizer == 'adam':
            optimizer = tf.keras.optimizers.Adam(learning_rate=lr)
        elif optimizer == 'rmsprop':
            optimizer = tf.keras.optimizers.RMSprop(learning_rate=lr)
        elif optimizer == 'sgd':
            optimizer = tf.keras.optimizers.SGD(learning_rate=lr)

        model.compile(optimizer=optimizer, loss='mse', metrics=['mae'])
        return model

    def _create_sequences(self, data):
        """
        Create sequences for LSTM input
        """
        X, y = [], []
        for i in range(len(data) - self.window_size):
            X.append(data[i:i + self.window_size])
            y.append(data[i + self.window_size])
        return np.array(X), np.array(y)

    def train(self, df, epochs=100, batch_size=32, base_dir='tuner_logs'):
        """
        Train LSTM models for each vegetable with outlier handling and model saving
        """
        # Create base directory if it doesn't exist
        os.makedirs(base_dir, exist_ok=True)

        # Get cleaned data and outlier statistics
        data, outlier_stats, removed_outliers = self._prepare_data(df)
        histories = {}

        for veg, prices in data.items():
            # Clean the vegetable name
            clean_veg = veg.strip().replace(' ', '_').replace('\n', '')

            logging.info(f"\nTraining model for {clean_veg}...")
            logging.info(
                f"Training with {len(prices)} data points after removing {outlier_stats[veg]['count']} outliers")

            # Create project directory
            project_dir = os.path.join(base_dir, f"{clean_veg}_tuning")
            os.makedirs(project_dir, exist_ok=True)

            # Create a models directory for saving the best models
            models_dir = os.path.join(project_dir, 'best_model')
            os.makedirs(models_dir, exist_ok=True)

            # Proceed with model training only if we have enough data
            if len(prices) > self.window_size:
                try:
                    scaled_data = self.scalers[veg].fit_transform(prices['Price'].values.reshape(-1, 1))
                    X, y = self._create_sequences(scaled_data)

                    # Tuning batch_size inside build_model
                    def model_builder(hp):
                        return self.build_model(hp, (self.window_size, 1))

                    tuner = kt.RandomSearch(
                        lambda hp: self.build_model(hp, (self.window_size, 1)),
                        objective='val_loss',
                        max_trials=20,
                        executions_per_trial=3,
                        directory=project_dir,
                        project_name=f'{clean_veg}_tuning'
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

                    best_trials = tuner.oracle.get_best_trials(num_trials=1)

                    if best_trials:
                        best_trial = best_trials[0]
                        best_hp = best_trial.hyperparameters

                        best_lr = best_hp.get('learning_rate')
                        best_batch_size = best_hp.get('batch_size')

                        best_model = tuner.get_best_models(num_models=1)[0]

                        # Save the best model with .keras extension
                        model_path = os.path.join(models_dir, f'{clean_veg}_best_model.keras')
                        best_model.save(model_path)

                        # Save hyperparameters
                        hp_path = os.path.join(models_dir, f'{clean_veg}_hyperparameters.json')
                        with open(hp_path, 'w') as f:
                            json.dump({
                                'learning_rate': best_lr,
                                'batch_size': best_batch_size,
                                'val_loss': best_trial.metrics.get_last_value('val_loss')
                            }, f, indent=4)

                        logging.info(f"Best model for {clean_veg} saved to {model_path}")
                        logging.info(f"Best LR for {clean_veg}: {best_lr:.6f}")
                        logging.info(f"Best Batch Size for {clean_veg}: {best_batch_size}")

                        self.models[veg] = best_model
                        histories[veg] = best_trial.metrics.get_last_value('val_loss')

                    else:
                        logging.warning(f"No valid trials found for {clean_veg}. Model tuning skipped.")

                except Exception as e:
                    logging.error(f"Error training model for {clean_veg}: {e}")
            else:
                logging.warning(f"Insufficient data to train model for {clean_veg} after removing outliers")

        self._initialize_prediction_fns()
        return histories, removed_outliers
    def _create_prediction_fn(self, model):
        """
        Create a compiled prediction function for a model
        """

        @tf.function(reduce_retracing=True)
        def predict_fn(x):
            return model(x, training=False)

        return predict_fn

    def _initialize_prediction_fns(self):
        """
        Initialize prediction functions for all models
        """
        if not hasattr(self, '_prediction_fns'):
            self._prediction_fns = {}

        for veg, model in self.models.items():
            if model is not None and veg not in self._prediction_fns:
                try:
                    self._prediction_fns[veg] = self._create_prediction_fn(model)
                except Exception as e:
                    logging.error(f"Error creating prediction function for {veg}: {e}")

    def predict(self, vegetable, input_sequence):
        """
        Predict future prices for a specific vegetable
        """
        if vegetable not in self.models or self.models[vegetable] is None:
            raise ValueError(f"No model trained for {vegetable}")

        try:
            # Initialize prediction function if not already done
            if not hasattr(self, '_prediction_fns') or vegetable not in self._prediction_fns:
                self._prediction_fns = getattr(self, '_prediction_fns', {})
                self._prediction_fns[vegetable] = self._create_prediction_fn(self.models[vegetable])

            # Ensure input shape is correct and consistent
            input_sequence = tf.convert_to_tensor(
                input_sequence.reshape(1, self.window_size, 1),
                dtype=tf.float32
            )

            # Use the compiled prediction function
            predicted_price = self._prediction_fns[vegetable](input_sequence)

            # Inverse transform to get actual price
            return self.scalers[vegetable].inverse_transform(predicted_price.numpy())[0][0]
        except Exception as e:
            raise RuntimeError(f"Error predicting price for {vegetable}: {e}")


    def evaluate_model(self, vegetable, X_test, y_test):
        """
        Evaluate model performance for a specific vegetable and compute accuracy.
        """
        if vegetable not in self.models or self.models[vegetable] is None:
            raise ValueError(f"No model trained for {vegetable}")

        # Convert test data to tensors with consistent shapes
        X_test = tf.convert_to_tensor(X_test, dtype=tf.float32)

        # Initialize prediction function if needed
        if vegetable not in self._prediction_fns:
            self._prediction_fns[vegetable] = self._create_prediction_fn(self.models[vegetable])

        # Make predictions using the compiled function
        y_pred = []
        batch_size = 32

        # Process in batches to maintain consistent tensor shapes
        for i in range(0, len(X_test), batch_size):
            batch = X_test[i:i + batch_size]
            pred = self._prediction_fns[vegetable](batch)
            y_pred.append(pred)

        y_pred = tf.concat(y_pred, axis=0)

        y_pred = y_pred.numpy()

        y_test_actual = self.scalers[vegetable].inverse_transform(y_test)
        y_pred_actual = self.scalers[vegetable].inverse_transform(y_pred)

        # Calculate metrics
        mse = mean_squared_error(y_test_actual, y_pred_actual)
        mae = mean_absolute_error(y_test_actual, y_pred_actual)
        r2 = r2_score(y_test_actual, y_pred_actual)

        # Calculate Mean Absolute Percentage Error (MAPE)
        mape = np.mean(np.abs((y_test_actual - y_pred_actual) / y_test_actual)) * 100

        # Accuracy percentage
        accuracy = 100 - mape

        return {
            'Mean Squared Error': mse,
            'Mean Absolute Error': mae,
            'R-squared': r2,
            'Accuracy (%)': accuracy
        }

def main():
    # PDF paths
    pdf_path_1 = 'price_report_20250131_e (1).pdf'
    pdf_path_2 = 'price_report_20250130_e (1).pdf'
    pdf_path_3 = 'price_report_20250129_e_0.pdf'
    pdf_path_4 = 'price_report_20250128_e.pdf'
    pdf_path_5 = 'price_report_20250127_e.pdf'
    pdf_path_6 = 'price_report_20250124_e.pdf'
    pdf_path_7 = 'price_report_20250123_e.pdf'
    pdf_path_8 = 'price_report_20250122_e.pdf'
    pdf_path_9 = 'price_report_20250121_e.pdf'
    pdf_path_10 = 'price_report_20250120_e.pdf'
    pdf_path_11 = 'price_report_20250117_e.pdf'
    pdf_path_12 = 'price_report_20250116_e.pdf'
    pdf_path_13 = 'price_report_20250115_e.pdf'
    pdf_path_16 = 'price_report_20250110_e.pdf'
    pdf_path_17 = 'price_report_20250109_e.pdf'
    pdf_path_18 = 'price_report_20250108_e.pdf'
    pdf_path_19 = 'price_report_20250107_e.pdf'
    pdf_path_20 = 'price_report_20250106_e.pdf'
    pdf_path_21 = 'price_report_20250103_e.pdf'
    pdf_path_22 = 'price_report_20250102_e.pdf'
    pdf_path_23 = 'price_report_20250101_e.pdf'
    pdf_path_24 = 'price_report_20241231_e.pdf'
    pdf_path_25 = 'price_report_20241230_e.pdf'
    pdf_path_26 = 'price_report_20241227_e.pdf'
    pdf_path_27 = 'price_report_20241226.pdf'
    pdf_path_29 = 'price_report_20241224_e.pdf'
    pdf_path_30 = 'price_report_20241223_e.pdf'
    pdf_path_31 = 'price_report_20241220_e.pdf'
    pdf_path_32 = 'price_report_20241219_e.pdf'
    pdf_path_33 = 'price_report_20241218_e.pdf'
    pdf_path_34 = 'price_report_20241217_e.pdf'
    pdf_path_35 = 'price_report_20241216_e.pdf'
    pdf_path_36 = 'price_report_20241213_e.pdf'
    pdf_path_37 = 'price_report_20241212_e.pdf'
    pdf_path_38 = 'price_report_20241211_e.pdf'
    pdf_path_39 = 'price_report_20241210_e.pdf'
    pdf_path_40 = 'price_report_20241209_e.pdf'
    pdf_path_41 = 'price_report_20241206_e.pdf'
    pdf_path_42 = 'price_report_20241205_e.pdf'
    pdf_path_43 = 'price_report_20241204_e.pdf'
    pdf_path_44 = 'price_report_20241203_e.pdf'
    pdf_path_45 = 'price_report_20241202.pdf'
    pdf_path_46 = 'price_report_20241129_e.pdf'
    pdf_path_47 = 'price_report_20241128.pdf'
    pdf_path_48 = 'price_report_20241127_e.pdf'
    pdf_path_49 = 'price_report_20241126.pdf'
    pdf_path_50 = 'price_report_20241125_e.pdf'
    pdf_path_51 = 'price_report_20241122_e.pdf'
    pdf_path_52 = 'price_report_20241121_e.pdf'
    pdf_path_53 = 'price_report_20241120.pdf'
    pdf_path_54 = 'price_report_20241119_e.pdf'
    pdf_path_55 = 'price_report_20241118.pdf'
    pdf_path_56 = 'price_report_20241114.pdf'
    pdf_path_57 = 'price_report_20241113_e.pdf'
    pdf_path_58 = 'price_report_20241112_e.pdf'
    pdf_path_59 = 'price_report_20241111_e.pdf'
    pdf_path_60 = 'price_report_20241108_e.pdf'
    pdf_path_61 = 'price_report_20241107_e.pdf'
    pdf_path_62 = 'price_report_20241106_e.pdf'
    pdf_path_63 = 'price_report_20241105_e.pdf'
    pdf_path_64 = 'price_report_20241104_e.pdf'
    pdf_path_65 = 'price_report_20241101.pdf'
    pdf_path_66 = 'price_report_20241030_e.pdf'
    pdf_path_67 = 'price_report_20241029_e.pdf'
    pdf_path_68 = 'price_report_20241028_e.pdf'
    pdf_path_69 = 'price_report_20241025_e.pdf'
    pdf_path_70 = 'price_report_20241024.pdf'
    pdf_path_71 = 'price_report_20241023.pdf'
    pdf_path_72 = 'price_report_20241022_e.pdf'
    pdf_path_73 = 'price_report_20241021_e.pdf'
    pdf_path_74 = 'price_report_20241018_e.pdf'
    pdf_path_75 = 'price_report_20241016_e.pdf'
    pdf_path_76 = 'price_report_20241015_e.pdf'
    pdf_path_77 = 'price_report_20241014_e.pdf'
    pdf_path_78 = 'price_report_20241011.pdf'
    pdf_path_79 = 'price_report_20241010_e.pdf'
    pdf_path_80 = 'price_report_20241009_e.pdf'
    pdf_path_81 = 'price_report_20241008_e.pdf'
    pdf_path_82 = 'price_report_20241007_e.pdf'
    pdf_path_83 = 'price_report_20241004_e.pdf'
    pdf_path_84 = 'price_report_20241003_e.pdf'
    pdf_path_85 = 'price_report_20241002_e.pdf'
    pdf_path_86 = 'price_report_20241001_e.pdf'
    pdf_path_87 = 'price_report_20240930_e.pdf'
    pdf_path_88 = 'price_report_20240927.pdf'
    pdf_path_89 = 'price_report_20240926_e.pdf'
    pdf_path_90 = 'price_report_20240925_e.pdf'
    pdf_path_91 = 'price_report_20240924_e.pdf'
    pdf_path_92 = 'price_report_20240923_e.pdf'
    pdf_path_93 = 'price_report_20240920_e.pdf'
    pdf_path_94 = 'price_report_20240919_e.pdf'
    pdf_path_95 = 'price_report_20240918_e.pdf'
    pdf_path_98 = 'price_report_20240913_e.pdf'
    pdf_path_99 = 'price_report_20240912.pdf'
    pdf_path_100 = 'price_report_20240911.pdf'
    pdf_path_101 = 'price_report_20240910.pdf'
    pdf_path_102 = 'price_report_20240909_e.pdf'
    pdf_path_105 = 'price_report_20240906_e.pdf'
    pdf_path_106 = 'price_report_20240905_e.pdf'
    pdf_path_107 = 'price_report_20240904_e.pdf'
    pdf_path_108 = 'price_report_20240903_e.pdf'
    pdf_path_109 = 'price_report_20240902_e.pdf'
    pdf_path_112 = 'price_report_20240830_e.pdf'
    pdf_path_113 = 'price_report_20240829_e.pdf'
    pdf_path_114 = 'price_report_20240828.pdf'
    pdf_path_115 = 'price_report_20240827.pdf'
    pdf_path_116 = 'price_report_20240826_e.pdf'
    pdf_path_119 = 'price_report_20240823_e.pdf'
    pdf_path_120 = 'price_report_20240822_e.pdf'
    pdf_path_121 = 'price_report_20240821_e.pdf'
    pdf_path_122 = 'price_report_20240820_e.pdf'
    pdf_path_126 = 'price_report_20240816_e.pdf'
    pdf_path_127 = 'price_report_20240815_e.pdf'
    pdf_path_128 = 'price_report_20240814_e.pdf'
    pdf_path_129 = 'price_report_20240813_e.pdf'
    pdf_path_130 = 'price_report_20240812_e.pdf'
    pdf_path_133 = 'price_report_20240809_e.pdf'
    pdf_path_134 = 'price_report_20240808_e.pdf'
    pdf_path_135 = 'price_report_20240807.pdf'
    pdf_path_136 = 'price_report_20240806_e.pdf'
    pdf_path_137 = 'price_report_20240805_e.pdf'
    pdf_path_140 = 'price_report_20240802_e.pdf'
    pdf_path_141 = 'price_report_20240801_e.pdf'
    pdf_path_142 = 'price_report_20240731_e.pdf'
    pdf_path_143 = 'price_report_20240730_e.pdf'
    pdf_path_144 = 'price_report_20240729_e.pdf'
    pdf_path_147 = 'price_report_20240726.pdf'
    pdf_path_149 = 'price_report_20240724_e.pdf'
    pdf_path_150 = 'price_report_20240723.pdf'
    pdf_path_151 = 'price_report_20240722_e.pdf'
    pdf_path_154 = 'price_report_20240719_e.pdf'
    pdf_path_155 = 'price_report_20240718_e.pdf'
    pdf_path_156 = 'price_report_20240717_e.pdf'
    pdf_path_157 = 'price_report_20240716_e.pdf'
    pdf_path_158 = 'price_report_20240715_e.pdf'
    pdf_path_161 = 'price_report_20240712_e.pdf'
    pdf_path_162 = 'price_report_20240711_e.pdf'
    pdf_path_163 = 'price_report_20240710_e.pdf'
    pdf_path_164 = 'price_report_20240709_e.pdf'
    pdf_path_165 = 'price_report_20240708_e.pdf'
    pdf_path_166 = 'price_report_20240705_e.pdf'
    pdf_path_167 = 'price_report_20240704_e.pdf'
    pdf_path_168 = 'price_report_20240703_e.pdf'
    pdf_path_169 = 'price_report_20240702_e.pdf'
    pdf_path_170 = 'price_report_20240701_e.pdf'
    pdf_path_171 = 'price_report_20240628_e.pdf'
    pdf_path_172 = 'price_report_20240627_e.pdf'
    pdf_path_173 = 'price_report_20240626.pdf'
    pdf_path_174 = 'price_report_20240625_e.pdf'
    pdf_path_175 = 'price_report_20240624_e.pdf'
    pdf_path_176 = 'price_report_20240620_e.pdf'
    pdf_path_177 = 'price_report_20240619_e.pdf'
    pdf_path_178 = 'price_report_20240618_e.pdf'
    pdf_path_179 = 'price_report_20240614_e.pdf'
    pdf_path_180 = 'price_report_20240613_e.pdf'
    pdf_path_181 = 'price_report_20240612_e.pdf'
    pdf_path_186 = 'price_report_20240605_e.pdf'
    pdf_path_187 = 'price_report_20240604_e.pdf'
    pdf_path_188 = 'price_report_20240603_e_0.pdf'
    pdf_path_189 = 'price_report_20240531_e.pdf'
    pdf_path_191 = 'price_report_20240529_e.pdf'
    pdf_path_192 = 'price_report_20240528_e.pdf'
    pdf_path_193 = 'price_report_20240527_e.pdf'
    pdf_path_196 = 'price_report_20240522_e.pdf'
    pdf_path_197 = 'price_report_20240521.pdf'
    pdf_path_198 = 'price_report_20240520_e.pdf'
    pdf_path_199 = 'price_report_20240517_e.pdf'
    pdf_path_200 = 'price_report_20240516.pdf'
    pdf_path_201 = 'price_report_20240515.pdf'
    pdf_path_202 = 'price_report_20240514_e.pdf'
    pdf_path_203 = 'price_report_20240513.pdf'
    pdf_path_205 = 'price_report_20240509_e.pdf'
    pdf_path_206 = 'price_report_20240508_e.pdf'
    pdf_path_207 = 'price_report_20240507_e.pdf'
    pdf_path_208 = 'price_report_20240506_e.pdf'  # Already in your initial list
    pdf_path_209 = 'price_report_20240503_e.pdf'  # Already in your initial list
    pdf_path_210 = 'price_report_20240502_e.pdf'  # Already in your initial list
    pdf_path_211 = 'price_report_20240430_e.pdf'  # Already in your initial list
    pdf_path_212 = 'price_report_20240429_e.pdf'  # Already in your initial list
    pdf_path_213 = 'price_report_20240426.pdf'  # Already in your initial list
    pdf_path_214 = 'price_report_20240425_e.pdf'  # Already in your initial list
    pdf_path_215 = 'price_report_20240424_e.pdf'  # Already in your initial list
    pdf_path_216 = 'price_report_20240422_e.pdf'  # Already in your initial list
    pdf_path_217 = 'price_report_20240419_e.pdf'  # Already in your initial list
    pdf_path_218 = 'price_report_20240418_e.pdf'  # Already in your initial list
    pdf_path_219 = 'price_report_20240417_e.pdf'  # Already in your initial list
    pdf_path_220 = 'price_report_20240416.pdf'  # Already in your initial list
    pdf_path_221 = 'price_report_20240415.pdf'  # Already in your initial list
    pdf_path_222 = 'price_report_20240410.pdf'  # Already in your initial list
    pdf_path_223 = 'price_report_20240409_e.pdf'  # Already in your initial list
    pdf_path_224 = 'price_report_20240408_e.pdf'  # Already in your initial list
    pdf_path_225 = 'price_report_20240405.pdf'  # Already in your initial list
    pdf_path_226 = 'price_report_20240404.pdf'  # Already in your initial list
    pdf_path_227 = 'price_report_20240403_e.pdf'  # Already in your initial list
    pdf_path_228 = 'price_report_20240402_e.pdf'  # Following the reverse chronological order
    pdf_path_229 = 'price_report_20240401.pdf'
    pdf_path_230 = 'price_report_20240328_e.pdf'
    pdf_path_231 = 'price_report_20240327.pdf'
    pdf_path_232 = 'price_report_20240326_e.pdf'
    pdf_path_233 = 'price_report_20240325.pdf'
    pdf_path_234 = 'price_report_20240322_e.pdf'
    pdf_path_235 = 'price_report_20240321_e.pdf'
    pdf_path_236 = 'price_report_20240320_e.pdf'
    pdf_path_237 = 'price_report_20240319_e.pdf'
    pdf_path_238 = 'price_report_20240318.pdf'
    pdf_path_239 = 'price_report_20240315_e.pdf'
    pdf_path_240 = 'price_report_20240314_e.pdf'
    pdf_path_241 = 'price_report_20240313.pdf'
    pdf_path_242 = 'price_report_20240312_e.pdf'
    pdf_path_243 = 'price_report_20240311_e.pdf'
    pdf_path_244 = 'price_report_20240307_e.pdf'
    pdf_path_245 = 'price_report_20240306_e.pdf'
    pdf_path_246 = 'price_report_20240305.pdf'
    pdf_path_247 = 'price_report_20240304_e.pdf'
    pdf_path_248 = 'price_report_20240301_e.pdf'  # Follow reverse chronological order
    pdf_path_249 = 'price_report_20240229_e.pdf'
    pdf_path_250 = 'price_report_20240228_e.pdf'
    pdf_path_251 = 'price_report_20240227_e.pdf'
    pdf_path_252 = 'price_report_20240226_e.pdf'
    pdf_path_253 = 'price_report_20240222_e.pdf'
    pdf_path_254 = 'price_report_20240221.pdf'
    pdf_path_255 = 'price_report_20240220_e.pdf'
    pdf_path_256 = 'price_report_20240219_e.pdf'
    pdf_path_257 = 'price_report_20240216.pdf'
    pdf_path_258 = 'price_report_20240215_e.pdf'
    pdf_path_259 = 'price_report_20240214_e.pdf'
    pdf_path_260 = 'price_report_20240213_e.pdf'
    pdf_path_261 = 'price_report_20240212_e.pdf'
    pdf_path_262 = 'price_report_20240209_e.pdf'
    pdf_path_263 = 'price_report_20240208.pdf'
    pdf_path_264 = 'price_report_20240207.pdf'
    pdf_path_265 = 'price_report_20240206.pdf'
    pdf_path_266 = 'price_report_20240205_e.pdf'
    pdf_path_267 = 'price_report_20240202_e.pdf'

    # Extract prices from PDFs
    vegetable_prices_1 = extract_vegetable_wholesale_prices(pdf_path_1)
    vegetable_prices_2 = extract_vegetable_wholesale_prices(pdf_path_2)
    vegetable_prices_3 = extract_vegetable_wholesale_prices(pdf_path_3)
    vegetable_prices_4 = extract_vegetable_wholesale_prices(pdf_path_4)
    vegetable_prices_5 = extract_vegetable_wholesale_prices(pdf_path_5)
    vegetable_prices_6 = extract_vegetable_wholesale_prices(pdf_path_6)
    vegetable_prices_7 = extract_vegetable_wholesale_prices(pdf_path_7)
    vegetable_prices_8 = extract_vegetable_wholesale_prices(pdf_path_8)
    vegetable_prices_9 = extract_vegetable_wholesale_prices(pdf_path_9)
    vegetable_prices_10 = extract_vegetable_wholesale_prices(pdf_path_10)
    vegetable_prices_11 = extract_vegetable_wholesale_prices(pdf_path_11)
    vegetable_prices_12 = extract_vegetable_wholesale_prices(pdf_path_12)
    vegetable_prices_13 = extract_vegetable_wholesale_prices(pdf_path_13)
    # vegetable_prices_14 = extract_vegetable_wholesale_prices(pdf_path_14)
    # vegetable_prices_15 = extract_vegetable_wholesale_prices(pdf_path_15)
    vegetable_prices_16 = extract_vegetable_wholesale_prices(pdf_path_16)
    vegetable_prices_17 = extract_vegetable_wholesale_prices(pdf_path_17)
    vegetable_prices_18 = extract_vegetable_wholesale_prices(pdf_path_18)
    vegetable_prices_19 = extract_vegetable_wholesale_prices(pdf_path_19)
    vegetable_prices_20 = extract_vegetable_wholesale_prices(pdf_path_20)
    vegetable_prices_21 = extract_vegetable_wholesale_prices(pdf_path_21)
    vegetable_prices_22 = extract_vegetable_wholesale_prices(pdf_path_22)
    vegetable_prices_23 = extract_vegetable_wholesale_prices(pdf_path_23)
    vegetable_prices_24 = extract_vegetable_wholesale_prices(pdf_path_24)
    vegetable_prices_25 = extract_vegetable_wholesale_prices(pdf_path_25)
    vegetable_prices_26 = extract_vegetable_wholesale_prices(pdf_path_26)
    vegetable_prices_27 = extract_vegetable_wholesale_prices(pdf_path_27)
    vegetable_prices_29 = extract_vegetable_wholesale_prices(pdf_path_29)
    vegetable_prices_30 = extract_vegetable_wholesale_prices(pdf_path_30)
    vegetable_prices_31 = extract_vegetable_wholesale_prices(pdf_path_31)
    vegetable_prices_32 = extract_vegetable_wholesale_prices(pdf_path_32)
    vegetable_prices_33 = extract_vegetable_wholesale_prices(pdf_path_33)
    vegetable_prices_34 = extract_vegetable_wholesale_prices(pdf_path_34)
    vegetable_prices_35 = extract_vegetable_wholesale_prices(pdf_path_35)
    vegetable_prices_36 = extract_vegetable_wholesale_prices(pdf_path_36)
    vegetable_prices_37 = extract_vegetable_wholesale_prices(pdf_path_37)
    vegetable_prices_38 = extract_vegetable_wholesale_prices(pdf_path_38)
    vegetable_prices_39 = extract_vegetable_wholesale_prices(pdf_path_39)
    vegetable_prices_40 = extract_vegetable_wholesale_prices(pdf_path_40)
    vegetable_prices_41 = extract_vegetable_wholesale_prices(pdf_path_41)
    vegetable_prices_42 = extract_vegetable_wholesale_prices(pdf_path_42)
    vegetable_prices_43 = extract_vegetable_wholesale_prices(pdf_path_43)
    vegetable_prices_44 = extract_vegetable_wholesale_prices(pdf_path_44)
    vegetable_prices_45 = extract_vegetable_wholesale_prices(pdf_path_45)
    vegetable_prices_46 = extract_vegetable_wholesale_prices(pdf_path_46)
    vegetable_prices_47 = extract_vegetable_wholesale_prices(pdf_path_47)
    vegetable_prices_48 = extract_vegetable_wholesale_prices(pdf_path_48)
    vegetable_prices_49 = extract_vegetable_wholesale_prices(pdf_path_49)
    vegetable_prices_50 = extract_vegetable_wholesale_prices(pdf_path_50)
    vegetable_prices_51 = extract_vegetable_wholesale_prices(pdf_path_51)
    vegetable_prices_52 = extract_vegetable_wholesale_prices(pdf_path_52)
    vegetable_prices_53 = extract_vegetable_wholesale_prices(pdf_path_53)
    vegetable_prices_54 = extract_vegetable_wholesale_prices(pdf_path_54)
    vegetable_prices_55 = extract_vegetable_wholesale_prices(pdf_path_55)
    vegetable_prices_56 = extract_vegetable_wholesale_prices(pdf_path_56)
    vegetable_prices_57 = extract_vegetable_wholesale_prices(pdf_path_57)
    vegetable_prices_58 = extract_vegetable_wholesale_prices(pdf_path_58)
    vegetable_prices_59 = extract_vegetable_wholesale_prices(pdf_path_59)
    vegetable_prices_60 = extract_vegetable_wholesale_prices(pdf_path_60)
    vegetable_prices_61 = extract_vegetable_wholesale_prices(pdf_path_61)
    vegetable_prices_62 = extract_vegetable_wholesale_prices(pdf_path_62)
    vegetable_prices_63 = extract_vegetable_wholesale_prices(pdf_path_63)
    vegetable_prices_64 = extract_vegetable_wholesale_prices(pdf_path_64)
    vegetable_prices_65 = extract_vegetable_wholesale_prices(pdf_path_65)
    vegetable_prices_66 = extract_vegetable_wholesale_prices(pdf_path_66)
    vegetable_prices_67 = extract_vegetable_wholesale_prices(pdf_path_67)
    vegetable_prices_68 = extract_vegetable_wholesale_prices(pdf_path_68)
    vegetable_prices_69 = extract_vegetable_wholesale_prices(pdf_path_69)
    vegetable_prices_70 = extract_vegetable_wholesale_prices(pdf_path_70)
    vegetable_prices_71 = extract_vegetable_wholesale_prices(pdf_path_71)
    vegetable_prices_72 = extract_vegetable_wholesale_prices(pdf_path_72)
    vegetable_prices_73 = extract_vegetable_wholesale_prices(pdf_path_73)
    vegetable_prices_74 = extract_vegetable_wholesale_prices(pdf_path_74)
    vegetable_prices_75 = extract_vegetable_wholesale_prices(pdf_path_75)
    vegetable_prices_76 = extract_vegetable_wholesale_prices(pdf_path_76)
    vegetable_prices_77 = extract_vegetable_wholesale_prices(pdf_path_77)
    vegetable_prices_78 = extract_vegetable_wholesale_prices(pdf_path_78)
    vegetable_prices_79 = extract_vegetable_wholesale_prices(pdf_path_79)
    vegetable_prices_80 = extract_vegetable_wholesale_prices(pdf_path_80)
    vegetable_prices_81 = extract_vegetable_wholesale_prices(pdf_path_81)
    vegetable_prices_82 = extract_vegetable_wholesale_prices(pdf_path_82)
    vegetable_prices_83 = extract_vegetable_wholesale_prices(pdf_path_83)
    vegetable_prices_84 = extract_vegetable_wholesale_prices(pdf_path_84)
    vegetable_prices_85 = extract_vegetable_wholesale_prices(pdf_path_85)
    vegetable_prices_86 = extract_vegetable_wholesale_prices(pdf_path_86)
    vegetable_prices_87 = extract_vegetable_wholesale_prices(pdf_path_87)
    vegetable_prices_88 = extract_vegetable_wholesale_prices(pdf_path_88)
    vegetable_prices_89 = extract_vegetable_wholesale_prices(pdf_path_89)
    vegetable_prices_90 = extract_vegetable_wholesale_prices(pdf_path_90)
    vegetable_prices_91 = extract_vegetable_wholesale_prices(pdf_path_91)
    vegetable_prices_92 = extract_vegetable_wholesale_prices(pdf_path_92)
    vegetable_prices_93 = extract_vegetable_wholesale_prices(pdf_path_93)
    vegetable_prices_94 = extract_vegetable_wholesale_prices(pdf_path_94)
    vegetable_prices_95 = extract_vegetable_wholesale_prices(pdf_path_95)
    vegetable_prices_98 = extract_vegetable_wholesale_prices(pdf_path_98)
    vegetable_prices_99 = extract_vegetable_wholesale_prices(pdf_path_99)
    vegetable_prices_100 = extract_vegetable_wholesale_prices(pdf_path_100)
    vegetable_prices_101 = extract_vegetable_wholesale_prices(pdf_path_101)
    vegetable_prices_102 = extract_vegetable_wholesale_prices(pdf_path_102)
    vegetable_prices_105 = extract_vegetable_wholesale_prices(pdf_path_105)
    vegetable_prices_106 = extract_vegetable_wholesale_prices(pdf_path_106)
    vegetable_prices_107 = extract_vegetable_wholesale_prices(pdf_path_107)
    vegetable_prices_108 = extract_vegetable_wholesale_prices(pdf_path_108)
    vegetable_prices_109 = extract_vegetable_wholesale_prices(pdf_path_109)
    vegetable_prices_112 = extract_vegetable_wholesale_prices(pdf_path_112)
    vegetable_prices_113 = extract_vegetable_wholesale_prices(pdf_path_113)
    vegetable_prices_114 = extract_vegetable_wholesale_prices(pdf_path_114)
    vegetable_prices_115 = extract_vegetable_wholesale_prices(pdf_path_115)
    vegetable_prices_116 = extract_vegetable_wholesale_prices(pdf_path_116)
    vegetable_prices_119 = extract_vegetable_wholesale_prices(pdf_path_119)
    vegetable_prices_120 = extract_vegetable_wholesale_prices(pdf_path_120)
    vegetable_prices_121 = extract_vegetable_wholesale_prices(pdf_path_121)
    vegetable_prices_122 = extract_vegetable_wholesale_prices(pdf_path_122)
    vegetable_prices_126 = extract_vegetable_wholesale_prices(pdf_path_126)
    vegetable_prices_127 = extract_vegetable_wholesale_prices(pdf_path_127)
    vegetable_prices_128 = extract_vegetable_wholesale_prices(pdf_path_128)
    vegetable_prices_129 = extract_vegetable_wholesale_prices(pdf_path_129)
    vegetable_prices_130 = extract_vegetable_wholesale_prices(pdf_path_130)
    # vegetable_prices_131 = extract_vegetable_wholesale_prices(pdf_path_131)
    # vegetable_prices_132 = extract_vegetable_wholesale_prices(pdf_path_132)
    vegetable_prices_133 = extract_vegetable_wholesale_prices(pdf_path_133)
    vegetable_prices_134 = extract_vegetable_wholesale_prices(pdf_path_134)
    vegetable_prices_135 = extract_vegetable_wholesale_prices(pdf_path_135)
    vegetable_prices_136 = extract_vegetable_wholesale_prices(pdf_path_136)
    vegetable_prices_137 = extract_vegetable_wholesale_prices(pdf_path_137)
    vegetable_prices_140 = extract_vegetable_wholesale_prices(pdf_path_140)
    vegetable_prices_141 = extract_vegetable_wholesale_prices(pdf_path_141)
    vegetable_prices_142 = extract_vegetable_wholesale_prices(pdf_path_142)
    vegetable_prices_143 = extract_vegetable_wholesale_prices(pdf_path_143)
    vegetable_prices_144 = extract_vegetable_wholesale_prices(pdf_path_144)
    vegetable_prices_147 = extract_vegetable_wholesale_prices(pdf_path_147)
    vegetable_prices_149 = extract_vegetable_wholesale_prices(pdf_path_149)
    vegetable_prices_150 = extract_vegetable_wholesale_prices(pdf_path_150)
    vegetable_prices_151 = extract_vegetable_wholesale_prices(pdf_path_151)
    vegetable_prices_154 = extract_vegetable_wholesale_prices(pdf_path_154)
    vegetable_prices_155 = extract_vegetable_wholesale_prices(pdf_path_155)
    vegetable_prices_156 = extract_vegetable_wholesale_prices(pdf_path_156)
    vegetable_prices_157 = extract_vegetable_wholesale_prices(pdf_path_157)
    vegetable_prices_158 = extract_vegetable_wholesale_prices(pdf_path_158)
    vegetable_prices_161 = extract_vegetable_wholesale_prices(pdf_path_161)
    vegetable_prices_162 = extract_vegetable_wholesale_prices(pdf_path_162)
    vegetable_prices_163 = extract_vegetable_wholesale_prices(pdf_path_163)
    vegetable_prices_164 = extract_vegetable_wholesale_prices(pdf_path_164)
    vegetable_prices_165 = extract_vegetable_wholesale_prices(pdf_path_165)
    vegetable_prices_166 = extract_vegetable_wholesale_prices(pdf_path_166)
    vegetable_prices_167 = extract_vegetable_wholesale_prices(pdf_path_167)
    vegetable_prices_168 = extract_vegetable_wholesale_prices(pdf_path_168)
    vegetable_prices_169 = extract_vegetable_wholesale_prices(pdf_path_169)
    vegetable_prices_170 = extract_vegetable_wholesale_prices(pdf_path_170)
    vegetable_prices_171 = extract_vegetable_wholesale_prices(pdf_path_171)
    vegetable_prices_172 = extract_vegetable_wholesale_prices(pdf_path_172)
    vegetable_prices_173 = extract_vegetable_wholesale_prices(pdf_path_173)
    vegetable_prices_174 = extract_vegetable_wholesale_prices(pdf_path_174)
    vegetable_prices_175 = extract_vegetable_wholesale_prices(pdf_path_175)
    vegetable_prices_176 = extract_vegetable_wholesale_prices(pdf_path_176)
    vegetable_prices_177 = extract_vegetable_wholesale_prices(pdf_path_177)
    vegetable_prices_178 = extract_vegetable_wholesale_prices(pdf_path_178)
    vegetable_prices_179 = extract_vegetable_wholesale_prices(pdf_path_179)
    vegetable_prices_180 = extract_vegetable_wholesale_prices(pdf_path_180)
    vegetable_prices_181 = extract_vegetable_wholesale_prices(pdf_path_181)
    vegetable_prices_186 = extract_vegetable_wholesale_prices(pdf_path_186)
    vegetable_prices_187 = extract_vegetable_wholesale_prices(pdf_path_187)
    vegetable_prices_188 = extract_vegetable_wholesale_prices(pdf_path_188)
    vegetable_prices_189 = extract_vegetable_wholesale_prices(pdf_path_189)
    vegetable_prices_191 = extract_vegetable_wholesale_prices(pdf_path_191)
    vegetable_prices_192 = extract_vegetable_wholesale_prices(pdf_path_192)
    vegetable_prices_193 = extract_vegetable_wholesale_prices(pdf_path_193)
    vegetable_prices_196 = extract_vegetable_wholesale_prices(pdf_path_196)
    vegetable_prices_197 = extract_vegetable_wholesale_prices(pdf_path_197)
    vegetable_prices_198 = extract_vegetable_wholesale_prices(pdf_path_198)
    vegetable_prices_199 = extract_vegetable_wholesale_prices(pdf_path_199)
    vegetable_prices_200 = extract_vegetable_wholesale_prices(pdf_path_200)
    vegetable_prices_201 = extract_vegetable_wholesale_prices(pdf_path_201)
    vegetable_prices_202 = extract_vegetable_wholesale_prices(pdf_path_202)
    vegetable_prices_203 = extract_vegetable_wholesale_prices(pdf_path_203)
    vegetable_prices_205 = extract_vegetable_wholesale_prices(pdf_path_205)
    vegetable_prices_206 = extract_vegetable_wholesale_prices(pdf_path_206)
    vegetable_prices_207 = extract_vegetable_wholesale_prices(pdf_path_207)
    vegetable_prices_208 = extract_vegetable_wholesale_prices(pdf_path_208)
    vegetable_prices_209 = extract_vegetable_wholesale_prices(pdf_path_209)
    vegetable_prices_210 = extract_vegetable_wholesale_prices(pdf_path_210)
    vegetable_prices_211 = extract_vegetable_wholesale_prices(pdf_path_211)
    vegetable_prices_212 = extract_vegetable_wholesale_prices(pdf_path_212)
    vegetable_prices_213 = extract_vegetable_wholesale_prices(pdf_path_213)
    vegetable_prices_214 = extract_vegetable_wholesale_prices(pdf_path_214)
    vegetable_prices_215 = extract_vegetable_wholesale_prices(pdf_path_215)
    vegetable_prices_216 = extract_vegetable_wholesale_prices(pdf_path_216)
    vegetable_prices_217 = extract_vegetable_wholesale_prices(pdf_path_217)
    vegetable_prices_218 = extract_vegetable_wholesale_prices(pdf_path_218)
    vegetable_prices_219 = extract_vegetable_wholesale_prices(pdf_path_219)
    vegetable_prices_220 = extract_vegetable_wholesale_prices(pdf_path_220)
    vegetable_prices_221 = extract_vegetable_wholesale_prices(pdf_path_221)
    vegetable_prices_222 = extract_vegetable_wholesale_prices(pdf_path_222)
    vegetable_prices_223 = extract_vegetable_wholesale_prices(pdf_path_223)
    vegetable_prices_224 = extract_vegetable_wholesale_prices(pdf_path_224)
    vegetable_prices_225 = extract_vegetable_wholesale_prices(pdf_path_225)
    vegetable_prices_226 = extract_vegetable_wholesale_prices(pdf_path_226)
    vegetable_prices_227 = extract_vegetable_wholesale_prices(pdf_path_227)
    vegetable_prices_228 = extract_vegetable_wholesale_prices(pdf_path_228)
    vegetable_prices_229 = extract_vegetable_wholesale_prices(pdf_path_229)
    vegetable_prices_230 = extract_vegetable_wholesale_prices(pdf_path_230)
    vegetable_prices_231 = extract_vegetable_wholesale_prices(pdf_path_231)
    vegetable_prices_232 = extract_vegetable_wholesale_prices(pdf_path_232)
    vegetable_prices_233 = extract_vegetable_wholesale_prices(pdf_path_233)
    vegetable_prices_234 = extract_vegetable_wholesale_prices(pdf_path_234)
    vegetable_prices_235 = extract_vegetable_wholesale_prices(pdf_path_235)
    vegetable_prices_236 = extract_vegetable_wholesale_prices(pdf_path_236)
    vegetable_prices_237 = extract_vegetable_wholesale_prices(pdf_path_237)
    vegetable_prices_238 = extract_vegetable_wholesale_prices(pdf_path_238)
    vegetable_prices_239 = extract_vegetable_wholesale_prices(pdf_path_239)
    vegetable_prices_240 = extract_vegetable_wholesale_prices(pdf_path_240)
    vegetable_prices_241 = extract_vegetable_wholesale_prices(pdf_path_241)
    vegetable_prices_242 = extract_vegetable_wholesale_prices(pdf_path_242)
    vegetable_prices_243 = extract_vegetable_wholesale_prices(pdf_path_243)
    vegetable_prices_244 = extract_vegetable_wholesale_prices(pdf_path_244)
    vegetable_prices_245 = extract_vegetable_wholesale_prices(pdf_path_245)
    vegetable_prices_246 = extract_vegetable_wholesale_prices(pdf_path_246)
    vegetable_prices_247 = extract_vegetable_wholesale_prices(pdf_path_247)
    vegetable_prices_248 = extract_vegetable_wholesale_prices(pdf_path_248)
    vegetable_prices_249 = extract_vegetable_wholesale_prices(pdf_path_249)
    vegetable_prices_250 = extract_vegetable_wholesale_prices(pdf_path_250)
    vegetable_prices_251 = extract_vegetable_wholesale_prices(pdf_path_251)
    vegetable_prices_252 = extract_vegetable_wholesale_prices(pdf_path_252)
    vegetable_prices_253 = extract_vegetable_wholesale_prices(pdf_path_253)
    vegetable_prices_254 = extract_vegetable_wholesale_prices(pdf_path_254)
    vegetable_prices_255 = extract_vegetable_wholesale_prices(pdf_path_255)
    vegetable_prices_256 = extract_vegetable_wholesale_prices(pdf_path_256)
    vegetable_prices_257 = extract_vegetable_wholesale_prices(pdf_path_257)
    vegetable_prices_258 = extract_vegetable_wholesale_prices(pdf_path_258)
    vegetable_prices_259 = extract_vegetable_wholesale_prices(pdf_path_259)
    vegetable_prices_260 = extract_vegetable_wholesale_prices(pdf_path_260)
    vegetable_prices_261 = extract_vegetable_wholesale_prices(pdf_path_261)
    vegetable_prices_262 = extract_vegetable_wholesale_prices(pdf_path_262)
    vegetable_prices_263 = extract_vegetable_wholesale_prices(pdf_path_263)
    vegetable_prices_264 = extract_vegetable_wholesale_prices(pdf_path_264)
    vegetable_prices_265 = extract_vegetable_wholesale_prices(pdf_path_265)
    vegetable_prices_266 = extract_vegetable_wholesale_prices(pdf_path_266)
    vegetable_prices_267 = extract_vegetable_wholesale_prices(pdf_path_267)

    combined_df = pd.concat([
        vegetable_prices_1, vegetable_prices_2, vegetable_prices_3, vegetable_prices_4,
        vegetable_prices_5, vegetable_prices_6, vegetable_prices_7, vegetable_prices_8,
        vegetable_prices_9, vegetable_prices_10, vegetable_prices_11, vegetable_prices_12,
        vegetable_prices_13, vegetable_prices_16,
        vegetable_prices_17, vegetable_prices_18, vegetable_prices_19, vegetable_prices_20,
        vegetable_prices_21, vegetable_prices_22, vegetable_prices_23, vegetable_prices_24,
        vegetable_prices_25, vegetable_prices_26, vegetable_prices_27,
        vegetable_prices_29, vegetable_prices_30, vegetable_prices_31, vegetable_prices_32,
        vegetable_prices_33, vegetable_prices_34, vegetable_prices_35, vegetable_prices_36,
        vegetable_prices_37, vegetable_prices_38, vegetable_prices_39,
        vegetable_prices_40, vegetable_prices_41, vegetable_prices_42, vegetable_prices_43,
        vegetable_prices_44, vegetable_prices_45, vegetable_prices_46, vegetable_prices_47,
        vegetable_prices_48, vegetable_prices_49, vegetable_prices_50, vegetable_prices_51,
        vegetable_prices_52, vegetable_prices_53, vegetable_prices_54, vegetable_prices_55,
        vegetable_prices_56, vegetable_prices_57, vegetable_prices_58, vegetable_prices_59,
        vegetable_prices_60, vegetable_prices_61, vegetable_prices_62, vegetable_prices_63,
        vegetable_prices_64, vegetable_prices_65, vegetable_prices_66, vegetable_prices_67,
        vegetable_prices_68, vegetable_prices_69, vegetable_prices_70, vegetable_prices_71,
        vegetable_prices_72, vegetable_prices_73, vegetable_prices_74, vegetable_prices_75,
        vegetable_prices_76, vegetable_prices_77, vegetable_prices_78, vegetable_prices_79,
        vegetable_prices_80, vegetable_prices_81, vegetable_prices_82, vegetable_prices_83,
        vegetable_prices_84, vegetable_prices_85, vegetable_prices_86, vegetable_prices_87,
        vegetable_prices_88, vegetable_prices_89, vegetable_prices_90, vegetable_prices_91,
        vegetable_prices_92, vegetable_prices_93, vegetable_prices_94, vegetable_prices_95,
        vegetable_prices_98, vegetable_prices_99,
        vegetable_prices_100, vegetable_prices_101, vegetable_prices_102, vegetable_prices_105, vegetable_prices_106,
        vegetable_prices_107,
        vegetable_prices_108, vegetable_prices_109, vegetable_prices_112, vegetable_prices_113, vegetable_prices_114,
        vegetable_prices_115,
        vegetable_prices_116, vegetable_prices_119,
        vegetable_prices_120, vegetable_prices_121, vegetable_prices_122, vegetable_prices_126, vegetable_prices_127,
        vegetable_prices_128, vegetable_prices_129, vegetable_prices_130, vegetable_prices_133, vegetable_prices_134,
        vegetable_prices_135, vegetable_prices_136, vegetable_prices_137, vegetable_prices_140, vegetable_prices_141,
        vegetable_prices_142, vegetable_prices_143, vegetable_prices_144, vegetable_prices_147, vegetable_prices_149,
        vegetable_prices_150, vegetable_prices_151, vegetable_prices_154, vegetable_prices_155, vegetable_prices_156,
        vegetable_prices_157, vegetable_prices_158, vegetable_prices_161, vegetable_prices_162, vegetable_prices_163,
        vegetable_prices_164,
        vegetable_prices_165, vegetable_prices_166, vegetable_prices_167,
        vegetable_prices_168, vegetable_prices_169, vegetable_prices_170,
        vegetable_prices_171, vegetable_prices_172, vegetable_prices_173,
        vegetable_prices_174, vegetable_prices_175, vegetable_prices_176,
        vegetable_prices_177, vegetable_prices_178, vegetable_prices_179,
        vegetable_prices_180, vegetable_prices_181,
        vegetable_prices_186,
        vegetable_prices_187,
        vegetable_prices_188,
        vegetable_prices_189,
        vegetable_prices_191,
        vegetable_prices_192,
        vegetable_prices_193,
        vegetable_prices_196,
        vegetable_prices_197,
        vegetable_prices_198,
        vegetable_prices_199,
        vegetable_prices_200,
        vegetable_prices_201,
        vegetable_prices_202,
        vegetable_prices_203,
        vegetable_prices_205,
        vegetable_prices_206,
        vegetable_prices_207,
        vegetable_prices_208,
        vegetable_prices_209,
        vegetable_prices_210,
        vegetable_prices_211,
        vegetable_prices_212,
        vegetable_prices_213,
        vegetable_prices_214,
        vegetable_prices_215,
        vegetable_prices_216,
        vegetable_prices_217,
        vegetable_prices_218,
        vegetable_prices_219,
        vegetable_prices_220,
        vegetable_prices_221,
        vegetable_prices_222,
        vegetable_prices_223,
        vegetable_prices_224,
        vegetable_prices_225,
        vegetable_prices_226,
        vegetable_prices_227,
        vegetable_prices_228,
        vegetable_prices_229,
        vegetable_prices_230,
        vegetable_prices_231,
        vegetable_prices_232,
        vegetable_prices_233,
        vegetable_prices_234,
        vegetable_prices_235,
        vegetable_prices_236,
        vegetable_prices_237,
        vegetable_prices_238,
        vegetable_prices_239,
        vegetable_prices_240,
        vegetable_prices_241,
        vegetable_prices_242,
        vegetable_prices_243,
        vegetable_prices_244,
        vegetable_prices_245,
        vegetable_prices_246,
        vegetable_prices_247,
        vegetable_prices_248,
        vegetable_prices_249,
        vegetable_prices_250,
        vegetable_prices_251,
        vegetable_prices_252,
        vegetable_prices_253,
        vegetable_prices_254,
        vegetable_prices_255,
        vegetable_prices_256,
        vegetable_prices_257,
        vegetable_prices_258,
        vegetable_prices_259,
        vegetable_prices_260,
        vegetable_prices_261,
        vegetable_prices_262,
        vegetable_prices_263,
        vegetable_prices_264,
        vegetable_prices_265,
        vegetable_prices_266,
        vegetable_prices_267

    ], ignore_index=True)

    # Combine DataFrames
    # combined_df = pd.concat([vegetable_prices_1, vegetable_prices_2,vegetable_prices_3,vegetable_prices_4], ignore_index=True)
    print(combined_df)
    # Get unique vegetables
    vegetables = combined_df['Vegetable'].unique().tolist()
    print(vegetables)


    print("\nInitializing LSTM model...")
    model = MultiVegetablePricePredictor(vegetables, window_size=30)

    print("\nTraining model with hyperparameter tuning...")
    histories, removed_outliers = model.train(combined_df, epochs=100, batch_size=32)

    print("\nEvaluating model performance...")
    data, outlier_stats, removed_outliers = model._prepare_data(combined_df)

    predicted_prices = model.predict_next_7_days(combined_df)
    for veg, prices in predicted_prices.items():
        print(f"{veg} price predictions for next 7 days: {prices}")



    for veg, prices in data.items():
        scaled_data = model.scalers[veg].transform(prices['Price'].values.reshape(-1, 1))
        X, y = model._create_sequences(scaled_data)

        if len(X) > 0:
            # Splitting data into train and test sets
            split_index = int(0.8 * len(X))
            X_train, X_test = X[:split_index], X[split_index:]
            y_train, y_test = y[:split_index], y[split_index:]

            # Evaluate model
            performance = model.evaluate_model(veg, X_test, y_test)

            # Print performance metrics
            print(f"\nPerformance Metrics for {veg}:")
            for metric, value in performance.items():
                print(f"{metric}: {value:.4f}")


        else:
            print(f"\nNot enough data to evaluate the model for {veg}")



        # Print predictions


if __name__ == "__main__":
    main()
