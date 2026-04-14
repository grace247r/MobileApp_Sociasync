import google.generativeai as genai
import os
import json
import re
from dotenv import load_dotenv

# Load .env file
load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")
model = None
if api_key:
    try:
        genai.configure(api_key=api_key)
        available_models = [
            m.name
            for m in genai.list_models()
            if "generateContent" in m.supported_generation_methods
        ]
        if available_models:
            model_name = available_models[0].replace("models/", "")
            model = genai.GenerativeModel(model_name)
    except Exception as e:
        print("GEMINI INIT ERROR:", str(e))


def call_ai(prompt):
    try:
        if model is None:
            return fallback_response(prompt)

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

        return fallback_response(prompt)


def fallback_response(prompt):
    prompt_lower = prompt.lower()

    if 'generate exactly 3' in prompt_lower or 'content ideas' in prompt_lower:
        return json.dumps([
            {
                'title': 'Hook Cepat',
                'type': 'Content Idea',
                'description': 'Mulai dengan hook singkat yang langsung memancing rasa penasaran.'
            },
            {
                'title': 'Before After',
                'type': 'Content Idea',
                'description': 'Tampilkan perbandingan sebelum dan sesudah untuk mendorong interaksi.'
            },
            {
                'title': 'Behind the Scene',
                'type': 'Content Idea',
                'description': 'Perlihatkan proses singkat agar konten terasa autentik dan relatable.'
            }
        ])

    if 'create a high-retention script' in prompt_lower or 'hook must grab attention' in prompt_lower:
        if 'previous script' in prompt_lower or 'do not repeat' in prompt_lower:
            return json.dumps({
                'hook': 'Kamu bakal kaget sama hasil akhirnya!',
                'body': 'Mulai dari potongan paling menarik, lalu lanjut ke detail singkat yang bikin penasaran.',
                'cta': 'Kalau mau versi lain, simpan dulu dan kasih komentar idemu.'
            })

        return json.dumps({
            'hook': 'Coba lihat ini dulu, hasilnya beda banget!',
            'body': 'Tunjukkan proses inti dengan potongan cepat dan visual yang jelas.',
            'cta': 'Kalau menurut kamu menarik, simpan dan share ke temanmu.'
        })

    if 'create an engaging caption' in prompt_lower or 'caption must be engaging' in prompt_lower:
        return json.dumps({
            'caption': 'Kalau kamu suka konten seperti ini, wajib coba versi lengkapnya. Tulis pendapatmu di komentar ya!'
        })

    if 'generate relevant hashtags' in prompt_lower or 'generate 8–12 relevant hashtags' in prompt_lower:
        return json.dumps({
            'hashtags': [
                '#contentcreator',
                '#viralcontent',
                '#sociasync',
                '#fyp',
                '#reels',
                '#tiktokindonesia',
                '#instagood',
                '#digitalmarketing'
            ]
        })

    return json.dumps({
        'error': 'Fallback AI response not matched to prompt',
    })


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