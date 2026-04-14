import google.generativeai as genai
import os
import json
import re
from dotenv import load_dotenv

# Load env
load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    raise ValueError("GEMINI_API_KEY not found")

genai.configure(api_key=api_key)

# Auto-pick model
available_models = [
    m.name for m in genai.list_models()
    if "generateContent" in m.supported_generation_methods
]

if not available_models:
    raise ValueError("No valid Gemini model found")

model_name = available_models[0].replace("models/", "")
model = genai.GenerativeModel(model_name)


# =========================
# 🔥 CORE AI FUNCTION
# =========================
def call_ai(prompt, mode="chat"):
    try:
        response = model.generate_content(
            prompt,
            generation_config={
                "temperature": 0.7 if mode == "chat" else 0.8,
            }
        )

        text = response.text

        if not text:
            raise ValueError("Empty response from Gemini")

        text = clean_response(text)

        if mode == "json":
            return parse_json(text)

        return text

    except Exception as e:
        print("GEMINI ERROR:", str(e))

        return fallback_response(mode)


# =========================
# 🧹 CLEAN RESPONSE
# =========================
def clean_response(text):
    return text.replace("```json", "").replace("```", "").strip()


# =========================
# 🧠 JSON PARSER
# =========================
def parse_json(text):
    if not text:
        return {"error": "Empty AI response", "raw": text}

    try:
        return json.loads(text)
    except:
        match = re.search(r'\{.*\}|\[.*\]', text, re.DOTALL)
        if match:
            try:
                return json.loads(match.group())
            except:
                pass

    return {"error": "Invalid JSON", "raw": text}


# =========================
# 🛡️ FALLBACK SYSTEM
# =========================
def fallback_response(mode):
    if mode == "json":
        return [
            {
                "title": "Fallback Idea 1",
                "type": "Test",
                "description": "AI failed, fallback response"
            },
            {
                "title": "Fallback Idea 2",
                "type": "Test",
                "description": "AI failed, fallback response"
            },
            {
                "title": "Fallback Idea 3",
                "type": "Test",
                "description": "AI failed, fallback response"
            }
        ]

    return "Maaf, AI sedang bermasalah. Coba lagi nanti 🙏"