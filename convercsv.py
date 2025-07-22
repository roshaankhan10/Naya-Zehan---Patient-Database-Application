# Save this as convert_dbf_to_csv.py
from dbfread import DBF
import csv

dbf_file = DBF("INDOOR1.DBF")
with open("INDOOR1.csv", "w", newline='', encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=dbf_file.field_names)
    writer.writeheader()
    for record in dbf_file:
        writer.writerow(record)
