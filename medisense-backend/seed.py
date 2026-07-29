import pymongo

client = pymongo.MongoClient("mongodb://localhost:27018")
db = client["medisense_db"]

# Patients data
patients_data = [
    {
        "name": "Kamal Perera",
        "phone": "0771234567",
        "age": 35,
        "gender": "Male"
    }
]

# Insert into patients collection
db.patients.insert_many(patients_data)
print("Patients seeded successfully!")