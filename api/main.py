from fastapi import FastAPI
from pydantic import BaseModel
import numpy as np
import joblib

app = FastAPI(
    title="NHS GP Practice DNA Risk Prediction API",
    description="Predicts whether a GP practice is at risk of high DNA rates based on operational features"
)

model = joblib.load("model/xgboost_dna.pkl")

class PracticeFeatures(BaseModel):
    pct_face_to_face: float
    pct_telephone: float
    pct_online: float
    pct_home_visit: float
    pct_gp_appointments: float
    avg_lead_time_days: float
    total_appointments: int
    icb_avg_dna_rate: float

class PredictionResponse(BaseModel):
    high_dna_probability: float
    risk_level: str
    recommendation: str

@app.post("/predict", response_model=PredictionResponse)
def predict_dna_risk(practice: PracticeFeatures):
    features = np.array([[
        practice.pct_face_to_face,
        practice.pct_telephone,
        practice.pct_online,
        practice.pct_home_visit,
        practice.pct_gp_appointments,
        practice.avg_lead_time_days,
        practice.total_appointments,
        practice.icb_avg_dna_rate
    ]])
    
    probability = model.predict_proba(features)[0][1]
    
    if probability > 0.7:
        risk = "High Risk"
        recommendation = ("Consider shifting more appointments to telephone "
                         "or online mode. Review booking lead times — practices "
                         "with high face-to-face proportion and long lead times "
                         "show the highest DNA rates.")
    elif probability > 0.4:
        risk = "Medium Risk"
        recommendation = ("Monitor DNA trends monthly. Consider proactive "
                         "reminder systems for appointments booked more than "
                         "14 days in advance.")
    else:
        risk = "Low Risk"
        recommendation = "Practice DNA performance is within acceptable range."
    
    return PredictionResponse(
        high_dna_probability=round(float(probability), 3),
        risk_level=risk,
        recommendation=recommendation
    )

@app.get("/health")
def health():
    return {"status": "healthy", "model": "xgboost_dna_v2", "auc": 0.8031}

@app.get("/")
def root():
    return {
        "message": "NHS GP DNA Risk Prediction API",
        "docs": "/docs",
        "health": "/health"
    }