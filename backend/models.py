from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, Boolean
from sqlalchemy.orm import relationship
from datetime import datetime
from db import Base

class Symptom(Base):
    __tablename__ = "symptoms"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)

class Disease(Base):
    __tablename__ = "diseases"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)
    description = Column(Text, nullable=True)

class Patient(Base):
    __tablename__ = "patients"
    id = Column(Integer, primary_key=True, index=True)
    flutter_patient_id = Column(String, unique=True, index=True)
    age = Column(Integer)
    gender = Column(String)
    synced_at = Column(DateTime, default=datetime.utcnow)

class DiagnosisRecord(Base):
    __tablename__ = "diagnosis_records"
    id = Column(Integer, primary_key=True, index=True)
    patient_id = Column(Integer, ForeignKey("patients.id"))
    predicted_disease = Column(String)
    confidence_score = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)