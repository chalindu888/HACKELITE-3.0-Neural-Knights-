# MediSense AI 
**HACKELITE 3.0 - Team Neural Knights**

A production-grade, trilingual Flutter application and Python FastAPI backend for AI-driven clinical symptom assessment, patient risk triage, and healthcare decision support.

---

##  Key Features

###  Trilingual Localization Support
- **Multi-language Interface**: Full native support for **English**, **Sinhala (සිංහල)**, and **Tamil (தமிழ்)** with instant language switching.
- **Localized Recommendations**: Actionable clinical triage advice and patient SMS summaries generated in the user's selected language.

###  Offline-First Architecture (Hive Storage)
- **Local Database**: Built with Hive NoSQL local storage for fast, reliable offline access.
- **Zero Dependency on Internet**: Patient registration, symptom assessments, diagnosis history, and preferences persist locally without requiring live server connections.

### 👤 Patient Management & Quick Lookup
- **Fast Registration**: Form-validated registration capture for name, phone number, age, gender, and clinical notes.
- **Smart Patient Search**: Real-time filtering of patient records by name or phone number.
- **Patient History Tracking**: Quick selection of active patient profiles for consecutive health evaluations.

### 🩺 Comprehensive Symptom & Vitals Assessment
- **370+ Feature Dataset**: Supports a rich set of boolean symptoms and numerical vital parameters (Pulse Rate, Systolic/Diastolic BP, Temperature).
- **Interactive Form Controls**: Micro-animated switches, numeric inputs with range helpers, and dynamic summary screens.

### 🤖 AI-Powered Risk Triage & Prediction Engine
- **Disease Inference**: Intelligent symptom matching against clinical dataset dictionaries (`symptoms_list.json`, `diseases_labels.json`).
- **4-Tier Risk Triage**: Color-coded risk classification:
  - 🟢 **Low Risk**
  - 🟡 **Medium Risk**
  - 🟠 **High Risk**
  - 🔴 **Critical Risk**
- **Ranked Differential Diagnosis**: Visual probability breakdown for primary and secondary conditions.
- **Confidence Scoring**: Confidence metrics computed per assessment.

### 💬 Integrated Patient SMS Notification
- **One-Touch SMS Generation**: Formats assessment summaries into localized SMS messages.
- **Native Messaging Integration**: Directly launches native SMS client (`url_launcher`) with pre-filled patient text or copies to clipboard.

### 📊 Assessment History & Dashboard
- **Offline History Log**: View, filter by risk triage level, inspect detailed records, or delete past assessments.
- **Web Admin Dashboard**: FastAPI HTML dashboard (`/dashboard`) displaying patient records synced to MongoDB.

---

## 🛠️ Tech Stack

### **Frontend (Mobile & Web)**
- **Framework**: [Flutter 3.x](https://flutter.dev/) / Dart 3.x
- **State Management**: Provider (`provider ^6.1.2`)
- **Offline Storage**: Hive NoSQL (`hive ^2.2.3`, `hive_flutter ^1.1.0`)
- **Networking & Services**: `http ^1.2.0`, `uuid ^4.4.0`, `url_launcher ^6.3.0`
- **UI & Design**: Material 3 Design Tokens, Google Fonts (`google_fonts ^6.2.1`), Custom Trilingual Localization System (`AppTranslations`)

### **Backend (REST API & Sync Server)**
- **Framework**: [FastAPI](https://fastapi.tiangolo.com/) (Python 3.9+)
- **Server**: Uvicorn ASGI Server (`uvicorn ^0.52.0`)
- **Database**: MongoDB (connected asynchronously via `motor ^3.7.1` & `pymongo ^4.17.0`)
- **Validation**: Pydantic v2 (`pydantic ^2.13.4`)
- **Environment**: `python-dotenv`

### **AI / ML Ingestion Subsystem**
- **Model Engine**: Teammate TFLite / Dataset ML Prediction Engine
- **Artifacts**: Clinical symptom dataset mapping (`symptoms_list.json`) & disease label dictionary (`diseases_labels.json`)

---

## 📂 Project Structure

```text
MediSense-AI/
├── frontend/                         # Flutter Application
│   ├── lib/
│   │   ├── config/                   # Web/Platform API Configurations
│   │   ├── core/                     # Localization, Themes, Constants
│   │   ├── data/                     # Hive Storage Services & Data Models
│   │   ├── features/                 # Modular Feature Architecture
│   │   │   ├── assessment/           # Symptom Selection, Review, & Provider Logic
│   │   │   ├── history/              # Saved Assessments & Triage Filters
│   │   │   ├── home/                 # Main Dashboard & Quick Stats
│   │   │   ├── patient/              # Patient Login & Registration
│   │   │   └── results/              # Prediction & Differential Diagnosis Screens
│   │   └── services/                 # API, Prediction Engines, & SMS Services
│   └── pubspec.yaml                  # Flutter Dependencies
│
└── backend/                          # Python FastAPI Server
    ├── db.py                         # Async MongoDB Connection Client
    ├── main.py                       # FastAPI Endpoints & HTML Dashboard
    ├── models.py                     # Pydantic Schemas
    ├── seed.py                       # Database Seeding Script
    ├── ml_model/                     # ML Dataset & Model Weights
    └── requirements.txt              # Python Dependencies
```

---

## ⚡ Quick Start Guide

### Prerequisites
- [Flutter SDK 3.x+](https://docs.flutter.dev/get-started/install)
- [Python 3.9+](https://www.python.org/downloads/)
- [MongoDB](https://www.mongodb.com/try/download/community) *(Optional, for backend sync)*

---

### 1. Running the Frontend (Flutter)

1. Navigate to the `frontend` directory:
   ```bash
   cd frontend
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Launch the app on Chrome Web or Windows Desktop:
   ```bash
   # Run on Chrome
   flutter run -d chrome

   # Run on Windows Desktop
   flutter run -d windows
   ```

---

### 2. Running the Backend (FastAPI Server)

1. Navigate to the `backend` directory:
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
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Start the backend server:
   ```bash
   python main.py
   ```
   *The API runs at `http://127.0.0.1:8000`. Access OpenAPI Swagger documentation at [`http://127.0.0.1:8000/docs`](http://127.0.0.1:8000/docs) and the web dashboard at [`http://127.0.0.1:8000/dashboard`](http://127.0.0.1:8000/dashboard).*

---

## 🏆 Hackathon Details
Built by **Team Neural Knights** for **HACKELITE 3.0**.
