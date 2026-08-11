# MediSense AI 
**HACKELITE 3.0 - Team Neural Knights**

**Short Description:**  
MediSense AI is a production-grade, trilingual Flutter mobile application and Next.js Web Dashboard, backed by a Python FastAPI server. It is designed to empower Community Health Workers (CHWs) with offline AI-driven clinical symptom assessment, patient risk triage, Bluetooth vitals integration, and seamless cloud syncing for real-time healthcare decision support by health officials.

---

##  All Project Features

###  Trilingual Localization Support
- **Multi-language Interface**: Full native support for **English**, **Sinhala (සිංහල)**, and **Tamil (தமிழ்)** with instant language switching.
- **Localized Recommendations**: Actionable clinical triage advice and patient SMS summaries generated in the user's selected language.

###  AI-Powered Risk Triage & Prediction Engine (Offline)
- **Local ML Inference**: Intelligent symptom matching using TensorFlow Lite (`tflite_flutter`) running entirely on the edge.
- **Zero Dependency on Internet**: AI diagnosis works fully offline in remote areas.
- **4-Tier Risk Triage**: Color-coded risk classification: 🟢 Low Risk, 🟡 Medium Risk, 🟠 High Risk, 🔴 Critical Risk.
- **Ranked Differential Diagnosis**: Visual probability breakdown for primary and secondary conditions with confidence scores.

###  Comprehensive Symptom & Vitals Assessment
- **370+ Feature Dataset**: Supports a rich set of boolean symptoms and numerical vital parameters.
- **Bluetooth Vitals Integration**: Direct Bluetooth (BLE) connection to smart devices to read real-time heart rate and vitals (`flutter_blue_plus`).
- **Voice Input**: Multilingual speech-to-text recognition to easily capture patient symptoms (`speech_to_text`).

###  Patient Management & SMS Notifications
- **Smart Patient Lookup**: Fast, offline filtering of patient records by name or phone number.
- **One-Touch SMS Generation**: Automatically formats assessment summaries into localized SMS messages and launches the native messaging app (`url_launcher`).

###  Seamless Cloud Syncing (Offline-First)
- **Hive NoSQL Storage**: Built with Hive local storage for fast, reliable offline access.
- **Background SyncEngine**: When an internet connection is available, the mobile app automatically syncs all offline assessments to the FastAPI backend without manual intervention.

###  Real-Time Web Admin Dashboard (Next.js)
- **Live Monitoring**: Health officials can monitor new patient assessments in real-time as they are synced from the field.
- **Geographic Hotspots**: Interactive Leaflet map integration for visualizing disease outbreaks (e.g., Dengue hotspots).
- **Premium UI/UX**: Built with Next.js 15, Tailwind CSS v4, Glassmorphism, and Chart.js.

---

##  Tech Stack

- **Mobile App (CHW Interface)**: Flutter 3.x, Dart, Provider, Hive NoSQL, `tflite_flutter`, `flutter_blue_plus`, `speech_to_text`
- **Backend (REST API)**: Python 3.9+, FastAPI, Motor (Async MongoDB), Pydantic
- **Web Dashboard (Admin)**: Next.js 15 (App Router), React, Tailwind CSS v4, Chart.js, React-Leaflet
- **Database**: MongoDB (Local or Atlas)

---

##  How to Test & Run (For Judges)

To test the full End-to-End flow of this project, you will need to run three separate components. Please follow the steps below in order.

###  Prerequisites
- **Node.js (v18+)** - For the Web Dashboard
- **Python (3.9+)** - For the FastAPI Backend
- **MongoDB** - Ensure MongoDB is installed and running locally on port `27017`.
- **Android Studio / SDK** - Required to run the Flutter app on an Android Emulator or physical device (Web/Windows builds will fail due to the native `tflite` engine).

---

### Step 1: Start the Backend (FastAPI)
The backend acts as the bridge connecting the Mobile App's synced data to the Web Dashboard.

1. Open a terminal and navigate to the `backend` folder:
   ```bash
   cd backend
   ```
2. Activate the virtual environment (or create one):
   ```bash
   # Windows
   .\venv\Scripts\Activate
   
   # Mac/Linux
   source venv/bin/activate
   ```
3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
4. Run the server:
   ```bash
   python main.py
   ```
   *(You should see "Connected to MongoDB successfully!" and the server running on `http://127.0.0.1:8000`)*

---

### Step 2: Start the Web Dashboard (Next.js)
This is the real-time admin panel used by health officials to monitor synced data.

1. Open a **new** terminal and navigate to the `web-dashboard` folder:
   ```bash
   cd web-dashboard
   ```
2. Install Node dependencies:
   ```bash
   npm install
   ```
3. Start the development server:
   ```bash
   npm run dev
   ```
4. Open your browser and go to **[http://localhost:3000/dashboard](http://localhost:3000/dashboard)** to view the live dashboard.

---

### Step 3: Run the Mobile App (Flutter)
The mobile app is used by Community Health Workers (CHWs) to assess patients.

>  **CRITICAL NOTE**: Do not run this on Chrome or Windows Desktop. The app relies on `tflite_flutter` (TensorFlow Lite) which requires a native Android environment (`dart:ffi`).

1. Ensure you have an **Android Emulator** running, or a physical Android device connected via USB.
2. Open a **new** terminal and navigate to the `frontend` folder:
   ```bash
   cd frontend
   ```
3. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```
5. Select your Android device/emulator from the list when prompted.

---

###  Testing the E2E Integration
1. Open the Flutter Mobile App on your emulator/device.
2. Create a new patient and run a symptom assessment to get an AI diagnosis.
3. Tap **Complete/Save**. The `SyncEngine` will automatically send the data to the FastAPI backend.
4. Watch the **Next.js Web Dashboard** (http://localhost:3000/dashboard) — the "Total Assessments" KPI and the "Recent Patient Assessments" table will automatically update with the new patient data in real-time!

---

Built by **Team Neural Knights** for **HACKELITE 3.0**.
