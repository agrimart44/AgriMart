import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import logging
import os
import shutil

import PyPDF2
import re

import tensorflow as tf
from sklearn.preprocessing import RobustScaler, MinMaxScaler
from tensorflow.keras.models import Model
from tensorflow.keras.layers import LSTM, Dense, Dropout, Bidirectional, Input, Flatten, MultiHeadAttention
from tensorflow.keras.callbacks import EarlyStopping, ReduceLROnPlateau
from sklearn.metrics import mean_squared_error, mean_absolute_error, r2_score
import keras_tuner as kt
from tensorflow.keras.layers import LayerNormalization
from tensorflow.keras.optimizers.schedules import ExponentialDecay
from tensorflow.keras.optimizers import Adam
from scipy.stats.mstats import winsorize
from tensorflow.keras.layers import Add










import re
from datetime import datetime
import PyPDF2
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


def add_z_score(df):
    """
    Add a Z-Score column for the 'today' prices.
    """
    # Use .loc to ensure modification of the original DataFrame
    df.loc[:, 'today'] = pd.to_numeric(df['today'], errors='coerce')

    # Remove rows with NaN values in the 'today' column
    df = df.dropna(subset=['today'])

    # Calculate the Z-Score and add the 'Z-Score' column
    df['Z-Score'] = (df['today'] - df['today'].mean()) / df['today'].std()

    return df

@tf.function(reduce_retracing=True)
def _predict_step(model, input_sequence):
    return model(input_sequence, training=False)

@tf.function(reduce_retracing=True)
def _evaluate_step(model, x_batch):
   return model(x_batch, training=False)





class MultiVegetablePricePredictor:
    def __init__(self, vegetables, window_size=30):
        self.vegetables = vegetables
        self.window_size = window_size
        self.scalers = {veg:  RobustScaler() for veg in vegetables}
        self.models = {veg: None for veg in vegetables}
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
        Prepare data for each vegetable and identify outliers
        """
        data = {}
        outlier_stats = {}
        Z_SCORE_THRESHOLD = 3  # Standard threshold for outliers

        for veg in self.vegetables:
            # Extract prices for specific vegetable
            veg_df = df[df['Vegetable'] == veg]

            # Apply Z-Score function to the vegetable data
            veg_df = add_z_score(veg_df)

            # Ensure there's data available for processing
            if len(veg_df) > 0:
                # Identify outliers
                outliers = veg_df[abs(veg_df['Z-Score']) > Z_SCORE_THRESHOLD]
                outlier_stats[veg] = {
                    'count': len(outliers),
                    'dates': outliers['Date'].tolist() if 'Date' in outliers.columns else [],
                    'prices': outliers['today'].tolist(),
                    'z_scores': outliers['Z-Score'].tolist()
                }

                # Store the price and Z-Score in the dictionary
                data[veg] = pd.DataFrame({
                    'Price': veg_df['today'],
                    'Z-Score': veg_df['Z-Score']
                })

                # Log outlier information
                if len(outliers) > 0:
                    logging.info(f"\nOutliers detected for {veg}:")
                    logging.info(f"Number of outliers: {len(outliers)}")
                    logging.info(f"Outlier prices: {outliers['today'].tolist()}")
                    logging.info(f"Outlier Z-Scores: {outliers['Z-Score'].tolist()}")

        return data, outlier_stats

    def build_model(self, hp, input_shape):
        """Enhanced model architecture with residual connections and advanced regularization"""
        inputs = Input(shape=input_shape)

        # First LSTM block with residual connection
        lstm1 = Bidirectional(LSTM(
            units=hp.Int('units_1', min_value=64, max_value=256, step=64),
            return_sequences=True,
            kernel_regularizer=tf.keras.regularizers.l1_l2(l1=0.01, l2=0.01),
            recurrent_regularizer=tf.keras.regularizers.l2(0.01),
            dropout=0.2,
            recurrent_dropout=0.2
        ))(inputs)
        lstm1 = LayerNormalization()(lstm1)

        # Second LSTM block
        lstm2 = Bidirectional(LSTM(
            units=hp.Int('units_2', min_value=32, max_value=128, step=32),
            return_sequences=True,
            kernel_regularizer=tf.keras.regularizers.l1_l2(l1=0.01, l2=0.01)
        ))(lstm1)
        lstm2 = LayerNormalization()(lstm2)

        # Residual connection
        lstm_combined = Add()([lstm1, lstm2])

        # Multi-Head Attention with improved parameters
        attention = MultiHeadAttention(
            num_heads=hp.Int('num_heads', min_value=2, max_value=8, step=2),
            key_dim=hp.Int('key_dim', min_value=32, max_value=128, step=32),
            dropout=hp.Float('attention_dropout', min_value=0.1, max_value=0.5, step=0.1)
        )(lstm_combined, lstm_combined)

        # Additional processing
        x = Flatten()(attention)
        x = Dropout(hp.Float('dropout_1', min_value=0.2, max_value=0.5, step=0.1))(x)

        # Dense layers with PReLU activation
        x = Dense(128)(x)
        x = PReLU()(x)
        x = BatchNormalization()(x)
        x = Dropout(hp.Float('dropout_2', min_value=0.1, max_value=0.4, step=0.1))(x)

        x = Dense(64)(x)
        x = PReLU()(x)
        x = BatchNormalization()(x)

        outputs = Dense(1)(x)

        model = Model(inputs, outputs)

        # Custom learning rate schedule
        initial_learning_rate = hp.Float('learning_rate', min_value=1e-4, max_value=1e-2, sampling='LOG')
        lr_schedule = CosineDecayRestarts(
            initial_learning_rate,
            first_decay_steps=1000,
            t_mul=2.0,
            m_mul=0.9,
            alpha=0.1
        )

        # Use AdamW optimizer with weight decay
        optimizer = AdamW(
            learning_rate=lr_schedule,
            weight_decay=hp.Float('weight_decay', min_value=1e-4, max_value=1e-2, sampling='LOG')
        )

        # Compile with Huber loss and multiple metrics
        model.compile(
            optimizer=optimizer,
            loss=tf.keras.losses.Huber(delta=hp.Float('huber_delta', min_value=0.5, max_value=2.0, step=0.5)),
            metrics=['mae', 'mse', tf.keras.metrics.RootMeanSquaredError()]
        )

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

    def train(self, df, epochs=150, batch_size=32, base_dir='tuner_logs'):
        """Enhanced training process with cross-validation and advanced tuning"""
        os.makedirs(base_dir, exist_ok=True)
        data, outlier_stats = self._prepare_data(df)
        histories = {}

        for veg, prices in data.items():
            clean_veg = veg.strip().replace(' ', '_').replace('\n', '')
            project_dir = os.path.join(base_dir, f"{clean_veg}_tuning")
            os.makedirs(project_dir, exist_ok=True)

            # Scale all features
            scaled_data = self.scalers[veg].fit_transform(prices)
            X, y = self._create_sequences(scaled_data)

            if len(X) > 0:
                try:
                    # Use Bayesian optimization with improved parameters
                    tuner = kt.BayesianOptimization(
                        lambda hp: self.build_model(hp, (self.window_size, X.shape[-1])),
                        objective=kt.Objective('val_loss', direction='min'),
                        max_trials=30,
                        directory=project_dir,
                        project_name=f'{clean_veg}_tuning',
                        overwrite=True
                    )

                    # Enhanced callbacks
                    callbacks = [
                        EarlyStopping(
                            monitor='val_loss',
                            patience=20,
                            restore_best_weights=True,
                            min_delta=1e-4
                        ),
                        ReduceLROnPlateau(
                            monitor='val_loss',
                            factor=0.5,
                            patience=10,
                            min_delta=1e-4,
                            min_lr=1e-6
                        ),
                        ModelCheckpoint(
                            filepath=os.path.join(project_dir, f'{clean_veg}_best_model.h5'),
                            monitor='val_loss',
                            save_best_only=True
                        )
                    ]

                    # Perform k-fold cross-validation
                    kfold = TimeSeriesSplit(n_splits=5)
                    fold_histories = []

                    for fold, (train_idx, val_idx) in enumerate(kfold.split(X)):
                        X_train, X_val = X[train_idx], X[val_idx]
                        y_train, y_val = y[train_idx], y[val_idx]

                        tuner.search(
                            X_train, y_train,
                            epochs=epochs,
                            batch_size=batch_size,
                            validation_data=(X_val, y_val),
                            callbacks=callbacks,
                            verbose=1
                        )

                        best_model = tuner.get_best_models(1)[0]
                        fold_history = best_model.evaluate(X_val, y_val)
                        fold_histories.append(fold_history)

                    # Store the best model and validation metrics
                    self.models[veg] = tuner.get_best_models(1)[0]
                    self.validation_metrics[veg] = np.mean(fold_histories, axis=0)

                except Exception as e:
                    logging.error(f"Error training model for {clean_veg}: {e}")
                    continue

        return histories

    # Then update your predict method
    def predict(self, vegetable, input_sequence):
        """
        Predict future prices for a specific vegetable

        :param vegetable: Name of the vegetable
        :param input_sequence: Scaled input sequence for prediction
        :return: Predicted price
        """
        if vegetable not in self.models or self.models[vegetable] is None:
            raise ValueError(f"No model trained for {vegetable}")

        # Convert input to tensor if it isn't already
        if not isinstance(input_sequence, tf.Tensor):
            input_sequence = tf.convert_to_tensor(input_sequence, dtype=tf.float32)

        # Reshape input sequence for prediction
        input_sequence = tf.reshape(input_sequence, (1, self.window_size, 1))

        # Make prediction using the traced function
        predicted_price = _predict_step(self.models[vegetable], input_sequence)

        # Convert to numpy and inverse transform to get actual price
        predicted_price_np = predicted_price.numpy()
        return self.scalers[vegetable].inverse_transform(predicted_price_np)[0][0]



    def evaluate_model(self, vegetable, X_test, y_test):
        """
        Evaluate model performance for a specific vegetable

        :param vegetable: Name of the vegetable
        :param X_test: Test input sequences
        :param y_test: Test target values
        :return: Dictionary of performance metrics
        """
        if vegetable not in self.models or self.models[vegetable] is None:
            raise ValueError(f"No model trained for {vegetable}")

        # Convert inputs to tensors if they aren't already
        if not isinstance(X_test, tf.Tensor):
            X_test = tf.convert_to_tensor(X_test, dtype=tf.float32)
        if not isinstance(y_test, tf.Tensor):
            y_test = tf.convert_to_tensor(y_test, dtype=tf.float32)

        # Make predictions in batches to avoid memory issues
        batch_size = 32
        predictions = []

        for i in range(0, len(X_test), batch_size):
            batch = X_test[i:i + batch_size]
            pred = _evaluate_step(self.models[vegetable], batch)
            predictions.append(pred)

        # Concatenate all predictions
        y_pred = tf.concat(predictions, axis=0)

        # Convert to numpy and inverse transform to get actual prices
        y_test_np = y_test.numpy()
        y_pred_np = y_pred.numpy()

        y_test_actual = self.scalers[vegetable].inverse_transform(y_test_np)
        y_pred_actual = self.scalers[vegetable].inverse_transform(y_pred_np)

        # Calculate metrics
        mse = mean_squared_error(y_test_actual, y_pred_actual)
        mae = mean_absolute_error(y_test_actual, y_pred_actual)
        r2 = r2_score(y_test_actual, y_pred_actual)

        return {
            'Mean Squared Error': mse,
            'Mean Absolute Error': mae,
            'R-squared': r2
        }

def main():
    # PDF paths
    pdf_path_1 = 'price_report_20250131_e (1).pdf'
    pdf_path_2 = 'price_report_20250130_e (1).pdf'
    pdf_path_3 = 'price_report_20250129_e_0.pdf'
    pdf_path_4 ='price_report_20250128_e.pdf'
    pdf_path_5 ='price_report_20250127_e.pdf'
    pdf_path_6='price_report_20250124_e.pdf'
    pdf_path_7='price_report_20250123_e.pdf'
    pdf_path_8='price_report_20250122_e.pdf'
    pdf_path_9='price_report_20250121_e.pdf'
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
    pdf_path_39='price_report_20241210_e.pdf'
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



    # Extract prices from PDFs
    vegetable_prices_1 = extract_vegetable_wholesale_prices(pdf_path_1)
    vegetable_prices_2 = extract_vegetable_wholesale_prices(pdf_path_2)
    vegetable_prices_3 = extract_vegetable_wholesale_prices(pdf_path_3)
    vegetable_prices_4 = extract_vegetable_wholesale_prices(pdf_path_4)
    vegetable_prices_5=extract_vegetable_wholesale_prices(pdf_path_5)
    vegetable_prices_6=extract_vegetable_wholesale_prices(pdf_path_6)
    vegetable_prices_7=extract_vegetable_wholesale_prices(pdf_path_7)
    vegetable_prices_8=extract_vegetable_wholesale_prices(pdf_path_8)
    vegetable_prices_9=extract_vegetable_wholesale_prices(pdf_path_9)
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
        vegetable_prices_37, vegetable_prices_38,vegetable_prices_39,
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
        vegetable_prices_100, vegetable_prices_101,vegetable_prices_102, vegetable_prices_105, vegetable_prices_106, vegetable_prices_107,
vegetable_prices_108, vegetable_prices_109, vegetable_prices_112, vegetable_prices_113, vegetable_prices_114, vegetable_prices_115,
vegetable_prices_116, vegetable_prices_119,
vegetable_prices_120, vegetable_prices_121, vegetable_prices_122,  vegetable_prices_126, vegetable_prices_127,
vegetable_prices_128, vegetable_prices_129, vegetable_prices_130,vegetable_prices_133, vegetable_prices_134, vegetable_prices_135, vegetable_prices_136, vegetable_prices_137, vegetable_prices_140, vegetable_prices_141, vegetable_prices_142, vegetable_prices_143, vegetable_prices_144, vegetable_prices_147, vegetable_prices_149, vegetable_prices_150, vegetable_prices_151, vegetable_prices_154, vegetable_prices_155, vegetable_prices_156,
        vegetable_prices_157, vegetable_prices_158, vegetable_prices_161,vegetable_prices_162, vegetable_prices_163, vegetable_prices_164,
vegetable_prices_165, vegetable_prices_166, vegetable_prices_167,
vegetable_prices_168, vegetable_prices_169, vegetable_prices_170,
vegetable_prices_171, vegetable_prices_172, vegetable_prices_173,
vegetable_prices_174, vegetable_prices_175, vegetable_prices_176,
vegetable_prices_177, vegetable_prices_178, vegetable_prices_179,
vegetable_prices_180, vegetable_prices_181 ,






    ],ignore_index=True)



    # Combine DataFrames
    # combined_df = pd.concat([vegetable_prices_1, vegetable_prices_2,vegetable_prices_3,vegetable_prices_4], ignore_index=True)
    print(combined_df)
    # Get unique vegetables
    vegetables = combined_df['Vegetable'].unique().tolist()
    print(vegetables)


    # Initialize and train model
    print("\nInitializing LSTM model...")
    model = MultiVegetablePricePredictor(vegetables, window_size=30)

    print("\nTraining model with hyperparameter tuning...")
    histories = model.train(combined_df, epochs=100, batch_size=32)

    # Print training histories
    print("\nTraining Histories:")
    for veg, history in histories.items():
        print(f"{veg}: {history}")

    # Model Evaluation


    print("\nEvaluating model performance...")
    data, outlier_stats = model._prepare_data(combined_df)

    for veg, prices in data.items():
        scaled_data = model.scalers[veg].transform(
            prices[['Price', 'Rolling_Mean', 'Rolling_Std', 'Z_Score', 'Rolling_ZScore']].values)
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

if __name__ == "__main__":
    main()
