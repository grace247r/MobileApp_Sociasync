from rest_framework.decorators import api_view
from rest_framework.decorators import permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .services.ai_service import AIServiceError, call_ai


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def chat(request):
    message = str(request.data.get("message", "")).strip()
    if not message:
        return Response(
            {"error": "Message tidak boleh kosong."},
            status=status.HTTP_400_BAD_REQUEST,
        )

    history_raw = request.data.get("history", [])
    history = history_raw if isinstance(history_raw, list) else []
    history = history[-20:]

    conversation = ""

    for msg in history:
        if not isinstance(msg, dict):
            continue
        content = str(msg.get("content", "")).strip()
        if not content:
            continue
        role = "User" if str(msg.get("role", "")).lower() == "user" else "Assistant"
        conversation += f"{role}: {content}\n"

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

    try:
        reply = call_ai(prompt, mode="chat")
    except AIServiceError as e:
        return Response(
            {"error": e.message},
            status=e.status_code,
        )

    return Response({
        "reply": reply
    })