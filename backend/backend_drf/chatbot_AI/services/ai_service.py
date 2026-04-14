import google.generativeai as genai
import os
import json
import re
import time
import hashlib
from threading import Lock
from dotenv import load_dotenv
from django.conf import settings

load_dotenv()


def _resolve_api_key():
    return getattr(settings, "GEMINI_API_KEY", None) or os.getenv("GEMINI_API_KEY")

MODEL_CANDIDATES = [
    "gemini-2.5-flash",
    "gemini-flash-latest",
    "gemini-2.5-flash-lite",
    "gemini-flash-lite-latest",
    "gemini-2.0-flash-lite",
    "gemini-2.0-flash",
]

_CACHE_TTL_SECONDS = 300
_MAX_CACHE_ITEMS = 256
_cache = {}
_cache_lock = Lock()
_model_lock = Lock()
_active_model_name = None


class AIServiceError(Exception):
    def __init__(self, message, status_code=503):
        super().__init__(message)
        self.message = message
        self.status_code = status_code


def _build_model():
    global _active_model_name

    api_key = _resolve_api_key()
    if not api_key:
        print("GEMINI INIT ERROR: GEMINI_API_KEY not found")
        return None

    try:
        genai.configure(api_key=api_key)

        available_models = set()
        try:
            available_models = {
                m.name.replace("models/", "")
                for m in genai.list_models()
                if "generateContent" in m.supported_generation_methods
            }
        except Exception as e:
            print("GEMINI INIT WARN: list_models failed, using fallback candidates", str(e))

        if available_models:
            candidates = [m for m in MODEL_CANDIDATES if m in available_models]
        else:
            candidates = MODEL_CANDIDATES[:]

        for candidate in candidates:
            try:
                built = genai.GenerativeModel(candidate)
                _active_model_name = candidate
                print(f"GEMINI INIT: using model {candidate}")
                return built
            except Exception as e:
                print(f"GEMINI INIT WARN: failed to use model {candidate}: {e}")

        print("GEMINI INIT ERROR: No usable Gemini model found")
        return None
    except Exception as e:
        print("GEMINI INIT ERROR:", str(e))
        return None


model = _build_model()


def _switch_model_after_interactions_error():
    global model
    global _active_model_name

    api_key = _resolve_api_key()
    if not api_key:
        return False

    with _model_lock:
        try:
            genai.configure(api_key=api_key)
            available_models = {
                m.name.replace("models/", "")
                for m in genai.list_models()
                if "generateContent" in m.supported_generation_methods
            }

            if not available_models:
                return False

            fallback_order = [name for name in MODEL_CANDIDATES if name in available_models]

            if not fallback_order:
                return False

            try:
                current_index = fallback_order.index(_active_model_name)
                next_index = current_index + 1
            except Exception:
                next_index = 0

            if next_index >= len(fallback_order):
                return False

            new_name = fallback_order[next_index]
            model = genai.GenerativeModel(new_name)
            _active_model_name = new_name
            print(f"GEMINI SWITCH: using model {new_name}")
            return True
        except Exception as e:
            print("GEMINI SWITCH ERROR:", str(e))
            return False


def _cache_key(prompt, mode):
    payload = f"{mode}:{prompt}".encode("utf-8", errors="ignore")
    return hashlib.sha256(payload).hexdigest()


def _get_cache(prompt, mode):
    key = _cache_key(prompt, mode)
    now = time.time()

    with _cache_lock:
        item = _cache.get(key)
        if not item:
            return None

        expires_at, value = item
        if expires_at <= now:
            _cache.pop(key, None)
            return None

        return value


def _set_cache(prompt, mode, value):
    key = _cache_key(prompt, mode)
    expires_at = time.time() + _CACHE_TTL_SECONDS

    with _cache_lock:
        if len(_cache) >= _MAX_CACHE_ITEMS:
            oldest_key = next(iter(_cache), None)
            if oldest_key:
                _cache.pop(oldest_key, None)
        _cache[key] = (expires_at, value)


def _extract_retry_delay_seconds(error_text):
    if not error_text:
        return None

    match = re.search(r"retry in\s*([0-9]+(?:\.[0-9]+)?)s", error_text, re.IGNORECASE)
    if match:
        return int(float(match.group(1)))

    match = re.search(r"retry_delay\s*\{\s*seconds:\s*([0-9]+)", error_text, re.IGNORECASE)
    if match:
        return int(match.group(1))

    return None


# =========================
# 🔥 CORE AI FUNCTION
# =========================
def call_ai(prompt, mode="chat"):
    global model

    cached = _get_cache(prompt, mode)
    if cached is not None:
        return cached

    if model is None:
        model = _build_model()

    if model is None:
        if mode == "chat":
            raise AIServiceError(
                "Layanan AI belum siap. Periksa GEMINI_API_KEY dan konfigurasi model Gemini.",
                503,
            )
        return fallback_response(mode)

    try:
        attempts = 3
        last_error = None

        for attempt in range(attempts):
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
                    parsed = parse_json(text)
                    _set_cache(prompt, mode, parsed)
                    return parsed

                _set_cache(prompt, mode, text)
                return text

            except Exception as e:
                last_error = str(e)
                lowered = last_error.lower()
                is_quota_or_rate = "429" in lowered or "quota" in lowered
                is_interactions_only = "interactions api" in lowered

                if is_interactions_only and attempt < attempts - 1:
                    switched = _switch_model_after_interactions_error()
                    if switched:
                        continue

                if is_quota_or_rate and attempt < attempts - 1:
                    retry_delay = _extract_retry_delay_seconds(last_error)
                    if retry_delay is None:
                        retry_delay = 2 * (attempt + 1)
                    retry_delay = max(1, min(retry_delay, 30))
                    time.sleep(retry_delay)
                    continue

                raise e

    except Exception as e:
        print("GEMINI ERROR:", str(e))
        error_text = str(e)
        lowered = error_text.lower()

        if mode == "chat" and ("429" in lowered or "quota" in lowered):
            retry = _extract_retry_delay_seconds(error_text)
            if retry is not None:
                raise AIServiceError(
                    f"Kuota AI lagi habis. Coba lagi sekitar {retry} detik lagi ya.",
                    429,
                )
            raise AIServiceError("Kuota AI lagi habis. Coba lagi sebentar ya.", 429)

        if mode == "chat" and "interactions api" in lowered:
            raise AIServiceError(
                "Model AI tidak kompatibel untuk endpoint ini. Coba lagi nanti.",
                503,
            )

        if mode == "chat":
            raise AIServiceError(
                "Layanan AI sedang bermasalah. Coba lagi beberapa saat.",
                503,
            )

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

    return "Maaf, AI sedang bermasalah. Coba lagi nanti."