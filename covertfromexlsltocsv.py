# Save this as convert_excel_to_csv.py
import pandas as pd

# Load Excel file
excel_file = "PATREC2.xlsx"  # ← Update this as needed
sheet_name = 0  # Use sheet name or index (0 = first sheet)

# Read sheet into DataFrame
df = pd.read_excel(excel_file, sheet_name=sheet_name)

# Save as CSV
df.to_csv("PATREC2.csv", index=False, encoding="utf-8")
