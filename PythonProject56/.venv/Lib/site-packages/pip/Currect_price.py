import os
import re
import logging
import pandas as pd
import PyPDF2
from datetime import datetime

import re
from datetime import datetime
import PyPDF2
import firebase_admin
from firebase_admin import credentials, firestore

cred = credentials.Certificate(r'C:\Users\rukshan\PycharmProjects\PythonProject\.venv\Lib\site-packages\pip\connect-model-firebase-adminsdk-fbsvc-06db006c16.json')
firebase_admin.initialize_app(cred)
db = firestore.client()


def extract_vegetable_wholesale_prices(pdf_path):
    """
    Extract vegetable wholesale prices from a PDF file and return as pairs (vegetable, price).
    """
    # Extract date from the file name
    date_pattern = r'(\d{8})'  # Matches 8 consecutive digits
    match = re.search(date_pattern, pdf_path)
    if match:
        date_str = match.group(1)
        try:
            date_obj = datetime.strptime(date_str, '%Y%m%d')  # Fixed date format
            formatted_date = date_obj.strftime('%Y-%m-%d')  # Format as YYYY-MM-DD
        except ValueError:
            print(f"Invalid date format in filename: {pdf_path}")
            formatted_date = None
    else:
        print(f"No date found in filename: {pdf_path}")
        formatted_date = None

    # Extract vegetable prices from PDF
    with open(pdf_path, 'rb') as file:
        pdf_reader = PyPDF2.PdfReader(file)
        page = pdf_reader.pages[1]  # Assuming the data is on the second page
        text = page.extract_text()

        # Pattern to match vegetable names and their prices
        pattern = r'([A-Za-z\s]+?)\s+Rs\./kg\s+(\d{2,5}\.?\d*)'
        matches = re.findall(pattern, text)

        # Create a list of tuples (vegetable, price)
        vegetable_price_pairs = [(veg.strip(), float(price)) for veg, price in matches]

        # List of specific vegetables to filter
        vegetables_to_filter = ['Carrot', 'Cabbage', 'Tomato', 'Brinjal', 'Pumpkin', 'Snake gourd', 'Green Chilli', 'Lime']

        # Filter specific vegetables
        filtered_pairs = [(veg, price) for veg, price in vegetable_price_pairs if veg.strip() in vegetables_to_filter]

        # Add Date column after filtering
        if formatted_date:
            filtered_pairs_with_date = [(veg, price, formatted_date) for veg, price in filtered_pairs]
            return filtered_pairs_with_date
        return filtered_pairs
def main():
    # PDF paths
    pdf_path_1 = 'price_report_20250131_e (1).pdf'

    # Extract prices from PDFs
    vegetable_prices_1 = extract_vegetable_wholesale_prices(pdf_path_1)

    # Print the extracted vegetable-price pairs

    # Prepare data for Firestore
    firestore_data = {
        'predictions_updated_for_current': [
            {'date': str(date), 'Price': float(price)}
            for veg, price, date in vegetable_prices_1
        ],
        'timestamp': firestore.SERVER_TIMESTAMP
    }

    # Save predictions to Firestore
    for veg, price, date in vegetable_prices_1:
        # Use the vegetable name as the document ID
        doc_ref = db.collection('predictions_updated_for_current').document(veg)
        doc_ref.set({
            'predictions_updated_for_current': [
                {'date': str(date), 'Price': float(price)}
            ],
            'timestamp': firestore.SERVER_TIMESTAMP
        })
        print(f"Vegetable: {veg}, Price: Rs. {price}/kg, Date: {date}")

if __name__ == "__main__":
    main()