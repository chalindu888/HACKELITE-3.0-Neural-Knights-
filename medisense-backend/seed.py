import json
import os
from db import engine, Base, SessionLocal
from models import Symptom, Disease

# Tables create කිරීම
Base.metadata.create_all(bind=engine)

def seed_database():
    db = SessionLocal()
    
    # Path to JSON files inside ml_model folder
    base_path = os.path.join(os.path.dirname(__file__), 'ml_model')
    symptoms_path = os.path.join(base_path, 'symptoms_list.json')
    diseases_path = os.path.join(base_path, 'diseases_labels.json')

    # Seed Symptoms
    if os.path.exists(symptoms_path):
        with open(symptoms_path, 'r') as f:
            symptoms = json.load(f)
            for item in symptoms:
                name = item if isinstance(item, str) else item.get('name')
                if name and not db.query(Symptom).filter(Symptom.name == name).first():
                    db.add(Symptom(name=name))
    
    # Seed Diseases
    if os.path.exists(diseases_path):
        with open(diseases_path, 'r') as f:
            diseases = json.load(f)
            for item in diseases:
                name = item if isinstance(item, str) else item.get('name')
                if name and not db.query(Disease).filter(Disease.name == name).first():
                    db.add(Disease(name=name))

    db.commit()
    db.close()
    print("Database successfully seeded with Master Clinical Data!")

if __name__ == "__main__":
    seed_database()