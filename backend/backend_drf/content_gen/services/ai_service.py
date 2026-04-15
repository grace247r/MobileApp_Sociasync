import google.generativeai as genai
import os
import json
import re
import time
import hashlib
from dotenv import load_dotenv
from django.conf import settings

# Load .env file
load_dotenv()

api_key = getattr(settings, "GEMINI_API_KEY", None) or os.getenv("GEMINI_API_KEY")
model = None
_cache = {}
_cache_ttl_seconds = 300
_cache_max_items = 256
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


def _cache_key(prompt):
    return hashlib.sha256(prompt.encode("utf-8", errors="ignore")).hexdigest()


def _get_cache(prompt):
    key = _cache_key(prompt)
    now = time.time()
    item = _cache.get(key)
    if not item:
        return None

    expires_at, value = item
    if expires_at <= now:
        _cache.pop(key, None)
        return None

    return value


def _set_cache(prompt, value):
    key = _cache_key(prompt)
    expires_at = time.time() + _cache_ttl_seconds

    if len(_cache) >= _cache_max_items:
        oldest_key = next(iter(_cache), None)
        if oldest_key:
            _cache.pop(oldest_key, None)

    _cache[key] = (expires_at, value)


def call_ai(prompt):
    prompt_lower = prompt.lower()
    is_content_ideas = (
        'generate exactly 3 highly engaging content ideas' in prompt_lower
        or 'content ideas' in prompt_lower
    )
    is_script = (
        'create a high-retention script' in prompt_lower
        or 'hook must grab attention' in prompt_lower
    )
    is_caption_or_hashtags = (
        'create an engaging caption' in prompt_lower
        or 'caption must be engaging' in prompt_lower
        or 'generate relevant hashtags' in prompt_lower
        or 'generate 8–12 relevant hashtags' in prompt_lower
    )
    is_generation_prompt = is_content_ideas or is_script or is_caption_or_hashtags

    cached = _get_cache(prompt)
    if cached is not None:
        return cached

    try:
        if model is None:
            if is_generation_prompt:
                cached_response = json.dumps({
                    'error': 'Gemini API key belum terbaca di backend.',
                    'error_code': 'GEMINI_NOT_CONFIGURED',
                })
                _set_cache(prompt, cached_response)
                return cached_response

            fallback = fallback_response(prompt)
            _set_cache(prompt, fallback)
            return fallback

        response = model.generate_content(
            prompt,
            generation_config={
                "temperature": 0.8,
            }
        )

        text = response.text

        if not text:
            raise ValueError("Empty response from Gemini")

        cleaned = clean_response(text)
        _set_cache(prompt, cleaned)
        return cleaned

    except Exception as e:
        error_text = str(e)
        print("GEMINI ERROR:", error_text)

        if is_generation_prompt:
            lowered = error_text.lower()
            if '429' in error_text or 'quota' in lowered:
                cached_response = json.dumps({
                    'error': 'Kuota Gemini habis. Coba lagi sebentar atau ganti API key/project.',
                    'error_code': 'GEMINI_QUOTA_EXCEEDED',
                })
                _set_cache(prompt, cached_response)
                return cached_response

            cached_response = json.dumps({
                'error': 'Gagal menghubungi Gemini untuk generate konten. Coba lagi sebentar.',
                'error_code': 'GEMINI_REQUEST_FAILED',
            })
            _set_cache(prompt, cached_response)
            return cached_response

        fallback = fallback_response(prompt)
        _set_cache(prompt, fallback)
        return fallback


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