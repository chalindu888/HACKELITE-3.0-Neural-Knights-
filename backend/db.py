import os
from dotenv import load_dotenv
from motor.motor_asyncio import AsyncIOMotorClient

load_dotenv()

MONGO_URL = os.getenv("MONGODB_URL", "mongodb://localhost:27018")
DATABASE_NAME = os.getenv("DATABASE_NAME", "medisense_db")

client = AsyncIOMotorClient(MONGO_URL)
db = client[DATABASE_NAME]

# Collections
symptoms_collection = db.get_collection("symptoms")
diseases_collection = db.get_collection("diseases")
patients_collection = db.get_collection("patients")
diagnosis_records_collection = db.get_collection("diagnosis_records")


def get_db():
    return db

async def test_connection():
    try:
        await client.admin.command('ping')
        print("Connected to MongoDB successfully!")
    except Exception as e:
        print(f"MongoDB Connection failed: {e}")