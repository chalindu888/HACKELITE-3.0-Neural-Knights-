import os
import json
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import accuracy_score
import joblib

dataset_path = r'C:\Users\Iresha\Downloads\IEEE\Final_Augmented_dataset_Diseases_and_Symptoms.csv\Final_Augmented_dataset_Diseases_and_Symptoms.csv'

print("Loading IEEE Diseases and Symptoms dataset...")
df = pd.read_csv(dataset_path)

# Target and Feature separation
target_col = df.columns[0]
feature_cols = list(df.columns[1:])

X = df[feature_cols]
y = df[target_col]

print(f"Total Records: {len(df)}")
print(f"Total Features: {len(feature_cols)}")
print(f"Total Unique Target Conditions: {y.nunique()}")

# Train/Test Split
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

print("\nTraining Fast Random Forest Disease Classifier...")
clf = RandomForestClassifier(n_estimators=30, max_depth=16, random_state=42, n_jobs=-1)
clf.fit(X_train, y_train)

# Accuracy Evaluation
y_pred = clf.predict(X_test)
acc = accuracy_score(y_test, y_pred)
print(f"\n==========================================")
print(f"MODEL TEST ACCURACY: {acc * 100:.2f}%")
print(f"==========================================")

# Top-3 Differential Diagnosis Evaluation on sample of test set for speed
sample_size = min(5000, len(y_test))
X_test_sample = X_test.iloc[:sample_size]
y_test_sample = y_test.iloc[:sample_size]

y_proba = clf.predict_proba(X_test_sample)
classes = clf.classes_

top3_correct = 0
for i in range(sample_size):
    true_label = y_test_sample.iloc[i]
    top3_indices = np.argsort(y_proba[i])[-3:][::-1]
    top3_classes = classes[top3_indices]
    if true_label in top3_classes:
        top3_correct += 1

top3_acc = top3_correct / sample_size
print(f"TOP-3 DIFFERENTIAL DIAGNOSIS ACCURACY: {top3_acc * 100:.2f}%\n")

# Save trained model
os.makedirs('scratch', exist_ok=True)
model_path = os.path.join('scratch', 'medisense_model.pkl')
joblib.dump(clf, model_path)
print(f"Saved trained ML model to {model_path}")

# Export Feature Schema & Disease List
schema = {
    "total_features": len(feature_cols),
    "features": feature_cols,
    "diseases": list(classes),
    "accuracy": round(float(acc), 4),
    "top3_accuracy": round(float(top3_acc), 4)
}

os.makedirs('assets', exist_ok=True)
schema_path = os.path.join('assets', 'model_schema.json')
with open(schema_path, 'w', encoding='utf-8') as f:
    json.dump(schema, f, indent=2)

print(f"Saved model schema to {schema_path}")
