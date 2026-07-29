import os
from dotenv import load_dotenv
from pymongo import MongoClient


load_dotenv()


MONGO_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27018")
DATABASE_NAME = os.getenv("DATABASE_NAME", "medisense_db")

client = MongoClient(MONGO_URL)
db = client[DATABASE_NAME]

# Collections (Tables)
symptoms_collection = db.get_collection("symptoms")
diseases_collection = db.get_collection("diseases")
patients_collection = db.get_collection("patients")
diagnosis_records_collection = db.get_collection("diagnosis_records")