from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import HTMLResponse
from fastapi.templating import Jinja2Templates
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
import uvicorn

# db.py එකෙන් database connections import කරගැනීම
from db import get_db, test_connection

# 1. FastAPI App එක මුලින්ම Define කිරීම
app = FastAPI(
    title="MediSense AI Backend",
    description="Backend API and Dashboard for MediSense AI Platform",
    version="1.0.0"
)

# Template and Static files configuration (අවශ්‍ය නම් පමණක්)
# app.mount("/static", StaticFiles(directory="static"), name="static")
# templates = Jinja2Templates(directory="templates")


# --- Models ---
class PatientRecord(BaseModel):
    patient_id: str
    name: str
    age: int
    symptoms: List[str] = []
    diagnosis: Optional[str] = None


# --- Startup Event ---
@app.on_event("startup")
async def startup_db_client():
    """Server එක start වෙද්දී MongoDB Connection එක test කිරීම"""
    if test_connection():
        print(" Successfully connected to MongoDB on port 27018!")
    else:
        print(" Failed to connect to MongoDB. Check if mongod process is running.")


# --- Routes ---

@app.get("/", tags=["General"])
async def root():
    return {"message": "Welcome to MediSense AI API", "status": "Online"}


@app.get("/health", tags=["General"])
async def health_check():
    """Database connection status එක පරික්ෂා කිරීම"""
    is_connected = test_connection()
    return {
        "status": "healthy" if is_connected else "unhealthy",
        "database": "connected" if is_connected else "disconnected"
    }


@app.get("/dashboard", response_class=HTMLResponse, tags=["Dashboard"])
async def render_dashboard(request: Request):
    """
    Dashboard එක render කිරීම සහ MongoDB වලින් Data ලබා ගැනීම.
    """
    try:
        db = get_db()
        # MongoDB collection එකෙන් රෝගී සටහන් ලබා ගැනීම
        records_cursor = db.patients.find().limit(50)
        patient_records = list(records_cursor)
        
        # Defensive processing for symptoms list rendering
        processed_records = []
        for record in patient_records:
            # MongoDB _id එක string බවට හැරවීම
            record["_id"] = str(record["_id"])
            
            # symptoms field එක නැතිනම් හෝ list එකක් නොවේ නම් empty list එකක් සෙට් කිරීම
            raw_symptoms = record.get("symptoms", [])
            if isinstance(raw_symptoms, list):
                record["symptoms"] = [str(s) for s in raw_symptoms]
            elif isinstance(raw_symptoms, str):
                record["symptoms"] = [s.strip() for s in raw_symptoms.split(",") if s.strip()]
            else:
                record["symptoms"] = []
                
            processed_records.append(record)

        # Simple Inline HTML Dashboard Rendering
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>MediSense AI - Dashboard</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 30px; background-color: #f4f7f6; }}
                h1 {{ color: #2c3e50; }}
                .status {{ padding: 10px; background: #e8f8f5; color: #117a65; border-radius: 5px; margin-bottom: 20px; }}
                table {{ width: 100%; border-collapse: collapse; background: white; box-shadow: 0 1px 3px rgba(0,0,0,0.2); }}
                th, td {{ padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }}
                th {{ background-color: #3498db; color: white; }}
                tr:hover {{ background-color: #f5f5f5; }}
                .badge {{ background: #e74c3c; color: white; padding: 3px 8px; border-radius: 12px; font-size: 12px; margin-right: 4px; }}
            </style>
        </head>
        <body>
            <h1>MediSense AI Clinical Dashboard</h1>
            <div class="status">MongoDB Connected: Port 27018 | Total Patients: {len(processed_records)}</div>
            
            <table>
                <tr>
                    <th>Patient ID</th>
                    <th>Name</th>
                    <th>Age</th>
                    <th>Symptoms</th>
                    <th>Diagnosis</th>
                </tr>
        """
        
        if not processed_records:
            html_content += """
                <tr>
                    <td colspan="5" style="text-align:center;">No patient records found in MongoDB.</td>
                </tr>
            """
        else:
            for patient in processed_records:
                symptoms_html = "".join([f'<span class="badge">{s}</span>' for s in patient.get("symptoms", [])])
                html_content += f"""
                <tr>
                    <td>{patient.get('patient_id', 'N/A')}</td>
                    <td>{patient.get('name', 'Unknown')}</td>
                    <td>{patient.get('age', '-')}</td>
                    <td>{symptoms_html if symptoms_html else 'None'}</td>
                    <td>{patient.get('diagnosis', 'Pending')}</td>
                </tr>
                """
                
        html_content += """
            </table>
        </body>
        </html>
        """
        return HTMLResponse(content=html_content, status_code=200)

    except Exception as e:
        # DB Error හෝ වෙනත් Runtime error එකක් ආවොත් 500 Error response එකක් යැවීම
        raise HTTPException(status_code=500, detail=f"Dashboard Error: {str(e)}")


@app.post("/patients", tags=["Patients"])
async def create_patient(patient: PatientRecord):
    """අලුත් රෝගී සටහනක් MongoDB එකට එකතු කිරීම"""
    try:
        db = get_db()
        patient_dict = patient.dict()
        result = db.patients.insert_one(patient_dict)
        return {"status": "success", "inserted_id": str(result.inserted_id)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to add patient: {str(e)}")


if __name__ == "__main__":
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)