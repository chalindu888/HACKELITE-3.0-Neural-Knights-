import csv
import json

dataset_path = r'C:\Users\Iresha\Downloads\IEEE\Final_Augmented_dataset_Diseases_and_Symptoms.csv\Final_Augmented_dataset_Diseases_and_Symptoms.csv'

with open(dataset_path, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    headers = next(reader)
    target_col = headers[0]
    symptom_cols = headers[1:]
    
    rows = list(reader)

print(f"Target Column: {target_col}")
print(f"Total Symptom Columns: {len(symptom_cols)}")
print(f"Total Rows / Records: {len(rows)}")

# Print all symptom names
print("\n--- SYMPTOMS IN DATASET ---")
print(json.dumps(symptom_cols, indent=2))
