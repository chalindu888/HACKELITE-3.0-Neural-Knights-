import csv

dataset_path = r'C:\Users\Iresha\Downloads\IEEE\Final_Augmented_dataset_Diseases_and_Symptoms.csv\Final_Augmented_dataset_Diseases_and_Symptoms.csv'

with open(dataset_path, 'r', encoding='utf-8') as f:
    reader = csv.reader(f)
    headers = next(reader)
    print(f"SUCCESS! Dataset Loaded Successfully!")
    print(f"Total Features / Columns: {len(headers)}")
    print("\nFirst 15 Columns (Target & Symptoms):")
    for i, col in enumerate(headers[:15]):
        print(f"  {i+1}. {col}")
    print("...")
    print(f"Last Column: {headers[-1]}")

    diseases = set()
    row_count = 0
    for row in reader:
        row_count += 1
        if len(row) > 0:
            diseases.add(row[0])

    print(f"\nTotal Dataset Records: {row_count}")
    print(f"Total Unique Diseases / Conditions ({len(diseases)}):")
    for d in sorted(list(diseases)):
        print(f"  - {d}")
