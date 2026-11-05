import os
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from google import genai

app = FastAPI(title="TIGER X API")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Production mein isse apne domain tak restrict karein.
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatRequest(BaseModel):
    message: str
    language: str = "Hindi"

@app.get("/")
def health():
    return {"status": "TIGER X backend is running"}

@app.post("/api/chat")
def chat(body: ChatRequest):
    api_key = os.getenv("GEMINI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=500, detail="GEMINI_API_KEY is not configured")
    try:
        client = genai.Client(api_key=api_key)
        prompt = f"""
You are TIGER X, a friendly, patient AI assistant and beginner English tutor.
The learner is in India and prefers simple explanations.
Reply primarily in {body.language}. If teaching English, explain in simple Hindi
when language is Hindi. Give short, practical examples and correct mistakes kindly.
For office English, provide professional phrases. Do not claim to perform phone,
device, payment, or other actions you cannot actually perform.
User message: {body.message}
"""
        result = client.models.generate_content(model="gemini-2.5-flash", contents=prompt)
        return {"reply": result.text or "Maaf kijiye, abhi jawab generate nahi hua."}
    except Exception as exc:
        raise HTTPException(status_code=502, detail=f"AI request failed: {str(exc)}")
