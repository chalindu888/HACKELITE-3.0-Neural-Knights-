from pymongo import MongoClient


MONGO_DETAILS = "mongodb://localhost:27018"

client = MongoClient(MONGO_DETAILS)

db = client.medisense_db

# Collections (Tables)
symptoms_collection = db.get_collection("symptoms")
diseases_collection = db.get_collection("diseases")
patients_collection = db.get_collection("patients")
diagnosis_collection = db.get_collection("diagnosis_records")