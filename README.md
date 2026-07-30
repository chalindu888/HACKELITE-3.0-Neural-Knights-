# MediSense AI 
**HACKELITE 3.0 - Team Neural Knights**

A trilingual Flutter mobile application and Python FastAPI backend for AI-driven clinical symptom assessment and decision support.

##  About The Project
MediSense AI is a comprehensive platform designed to assist with clinical symptom assessment. By providing a trilingual interface, the application ensures accessibility while leveraging artificial intelligence to aid in decision support for patients and medical professionals.

## Project Structure
This repository uses a clean monorepo structure to separate the frontend application from the backend API:

```text
MediSense-AI/
├── frontend/                 # Flutter mobile application
└── backend/                  # Python FastAPI & Machine Learning models
```

##  Tech Stack
- **Frontend:** Flutter & Dart
- **Backend:** Python, FastAPI, Uvicorn
- **Database:** MongoDB (Motor Async Driver)
- **AI/ML:** Custom Machine Learning Models

## Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Python 3.9+](https://www.python.org/downloads/)
- [MongoDB](https://www.mongodb.com/try/download/community) (Running locally on port `27018`)


### 1. Backend Setup (FastAPI)
The backend is built with FastAPI and connects to a MongoDB database.

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Create and activate a virtual environment:
   ```bash
   # Windows
   python -m venv venv
   .\venv\Scripts\activate
   
   # Mac/Linux
   python3 -m venv venv
   source venv/bin/activate
   ```
3. Install the required dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Start the backend server:
   ```bash
   uvicorn main:app --reload --port 8000
   ```
   *The API will be available at `http://127.0.0.1:8000`. You can view the dashboard at `http://127.0.0.1:8000/dashboard`.*



### 2. Frontend Setup (Flutter)
The frontend is a trilingual mobile application built with Flutter.

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Fetch the Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application on an emulator or connected device:
   ```bash
   flutter run
   ```

##  Hackathon Details
Built by **Team Neural Knights** for **HACKELITE 3.0**.
