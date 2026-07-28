from db import symptoms_collection, diseases_collection

def seed_data():
    
    symptoms_collection.delete_many({})
    diseases_collection.delete_many({})

    # Sample Symptoms
    sample_symptoms = [
        {"name": "Fever", "severity": "Mild"},
        {"name": "Cough", "severity": "Moderate"}
    ]
    symptoms_collection.insert_many(sample_symptoms)

    print("Data seeded successfully into MongoDB!")

if __name__ == "__main__":
    seed_data()