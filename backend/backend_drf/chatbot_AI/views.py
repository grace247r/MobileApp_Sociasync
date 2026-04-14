from rest_framework.decorators import api_view
from rest_framework.response import Response
from .services.ai_service import call_ai


@api_view(['POST'])
def chat(request):
    message = request.data.get("message", "")
    history = request.data.get("history", [])

    # 🔥 build conversation
    conversation = ""

    for msg in history:
        role = "User" if msg["role"] == "user" else "Assistant"
        conversation += f"{role}: {msg['content']}\n"

    conversation += f"User: {message}\nAssistant:"

    prompt = f"""
You are a smart AI assistant.

Conversation:
{conversation}

Rules:
- Respond naturally like a human
- Keep it concise
- Continue the conversation smoothly
- If context exists, USE IT
"""

    reply = call_ai(prompt, mode="chat")

    return Response({
        "reply": reply
    })