@app.get("/dashboard", response_class=HTMLResponse, tags=["Dashboard"])
def web_dashboard():
    try:
        symptom_count = symptoms_collection.count_documents({})
        disease_count = diseases_collection.count_documents({})
        patient_count = patients_collection.count_documents({})
        diagnosis_count = diagnosis_records_collection.count_documents({})

        records = list(
            diagnosis_records_collection.find({}, {"_id": 0}).limit(10)
        )

        rows_html = ""
        for r in records:
            # symptoms array/list එකක් නෙවේ නම් safe එකේ string එකක් බවට හරවා ගැනීම
            raw_symptoms = r.get("symptoms", [])
            if isinstance(raw_symptoms, list):
                symptoms_str = ", ".join(map(str, raw_symptoms))
            else:
                symptoms_str = str(raw_symptoms)

            rows_html += f"""
            <tr>
                <td>{r.get('patient_id', 'N/A')}</td>
                <td>{symptoms_str if symptoms_str else 'N/A'}</td>
                <td><strong>{r.get('predicted_disease', 'N/A')}</strong></td>
                <td>{r.get('confidence', 'N/A')}</td>
                <td>{r.get('synced_at', 'N/A')}</td>
            </tr>
            """

        if not rows_html:
            rows_html = "<tr><td colspan='5' style='text-align:center;'>No synced diagnosis records yet.</td></tr>"

        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>MediSense AI Dashboard</title>
            <style>
                body {{ font-family: 'Segoe UI', sans-serif; margin: 30px; background-color: #f4f6f9; }}
                h1 {{ color: #1a365d; }}
                .metrics {{ display: flex; gap: 20px; margin-bottom: 30px; }}
                .card {{ background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); flex: 1; text-align: center; }}
                .card h3 {{ margin: 0; color: #4a5568; font-size: 14px; }}
                .card p {{ margin: 10px 0 0; font-size: 28px; font-weight: bold; color: #2b6cb0; }}
                table {{ width: 100%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; }}
                th, td {{ padding: 12px 15px; text-align: left; border-bottom: 1px solid #e2e8f0; }}
                th {{ background-color: #2b6cb0; color: white; }}
            </style>
        </head>
        <body>
            <h1>MediSense AI Cloud Dashboard</h1>
            <div class="metrics">
                <div class="card"><h3>Total Symptoms</h3><p>{symptom_count}</p></div>
                <div class="card"><h3>Total Diseases</h3><p>{disease_count}</p></div>
                <div class="card"><h3>Registered Patients</h3><p>{patient_count}</p></div>
                <div class="card"><h3>Diagnosis Records</h3><p>{diagnosis_count}</p></div>
            </div>
            <h2>Latest Synced Diagnoses</h2>
            <table>
                <thead>
                    <tr><th>Patient ID</th><th>Symptoms</th><th>Predicted Disease</th><th>Confidence</th><th>Sync Time</th></tr>
                </thead>
                <tbody>{rows_html}</tbody>
            </table>
        </body>
        </html>
        """
        return HTMLResponse(content=html_content)
    except Exception as e:
        # Error එකක් ආවොත් Browser එකේ කෙලින්ම error message එක පෙන්වයි
        return HTMLResponse(content=f"<h2>Error loading dashboard: {str(e)}</h2>", status_code=500)