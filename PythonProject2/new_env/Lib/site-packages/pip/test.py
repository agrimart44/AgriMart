import PyPDF2
import pandas as pd
import re


def extract_vegetable_wholesale_prices(pdf_path):
    """
    Extract vegetable wholesale prices from a PDF file

    Args:
        pdf_path (str): Path to the PDF file

    Returns:
        pandas.DataFrame: DataFrame with vegetable names and wholesale prices
    """
    # Open the PDF file
    with open(pdf_path, 'rb') as file:
        # Create a PDF reader object
        pdf_reader = PyPDF2.PdfReader(file)

        # Extract text from the second page
        page = pdf_reader.pages[1]
        text = page.extract_text()

        # Define a regex pattern to match vegetables and their prices
        pattern = r'([A-Za-z\s]+)\s+Rs\./kg\s+(\d+\.?\d*)\s+(\d+\.?\d*)'

        # Find all matches
        matches = re.findall(pattern, text)

        # Create a DataFrame
        df = pd.DataFrame(matches, columns=['Vegetable', 'Wholesale Price 1', 'Wholesale Price 2'])

        # Filter only vegetable rows (remove non-vegetable entries)
        df = df[df['Vegetable'].str.strip().isin([
            'Beans', 'Carrot', 'Cabbage', 'Tomato', 'Brinjal',
            'Pumpkin', 'Snake gourd', 'Green Chilli', 'Lime'
        ])]

        return df


# Example usage
pdf_path_1 = 'price_report_20250131_e (1).pdf'
pdf_path_2 = 'price_report_20250130_e (1).pdf'

# Extract prices from both PDFs
vegetable_prices_1 = extract_vegetable_wholesale_prices(pdf_path_1)
vegetable_prices_2 = extract_vegetable_wholesale_prices(pdf_path_2)

# Combine the two DataFrames
combined_df = pd.concat([vegetable_prices_1, vegetable_prices_2], ignore_index=True)

# Convert the prices to numeric values
combined_df['Wholesale Price 1'] = pd.to_numeric(combined_df['Wholesale Price 1'], errors='coerce')
combined_df['Wholesale Price 2'] = pd.to_numeric(combined_df['Wholesale Price 2'], errors='coerce')



# Display the combined DataFrame
print(combined_df)
