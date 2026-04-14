import google.generativeai as genai
import os
import json
import re
from dotenv import load_dotenv

# Load .env file
load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    raise ValueError("GEMINI_API_KEY not found in environment variables. Check your .env file.")

genai.configure(api_key=api_key)

# Use the first available model that supports generateContent
available_models = [m.name for m in genai.list_models() if "generateContent" in m.supported_generation_methods]
if available_models:
    model_name = available_models[0].replace("models/", "")
    model = genai.GenerativeModel(model_name)
else:
    raise ValueError("No available models that support generateContent")


def call_ai(prompt):
    try:
        response = model.generate_content(
            prompt,
            generation_config={
                "temperature": 0.8,
            }
        )

        text = response.text

        if not text:
            raise ValueError("Empty response from Gemini")

        return clean_response(text)

    except Exception as e:
        print("GEMINI ERROR:", str(e))

        # ✅ fallback biar gak crash
        return """
        [
          {
            "title": "Fallback Idea 1",
            "type": "Test",
            "description": "AI failed, this is fallback"
          },
          {
            "title": "Fallback Idea 2",
            "type": "Test",
            "description": "AI failed, this is fallback"
          },
          {
            "title": "Fallback Idea 3",
            "type": "Test",
            "description": "AI failed, this is fallback"
          }
        ]
        """


def clean_response(text):
    # hapus markdown kalau ada
    text = text.replace("```json", "").replace("```", "").strip()
    return text


def parse_json(text):
    if not text:
        return {
            "error": "Empty AI response",
            "raw": text
        }

    try:
        return json.loads(text)
    except Exception as e:
        # coba extract JSON dari text
        match = re.search(r'\{.*\}|\[.*\]', text, re.DOTALL)
        if match:
            try:
                return json.loads(match.group())
            except Exception as e:
                pass

        return {
            "error": "Invalid JSON format",
            "raw": text
        }