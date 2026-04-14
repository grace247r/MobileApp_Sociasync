from rest_framework.decorators import api_view
from rest_framework.decorators import permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from content_gen.models import Content

from .services.ai_service import call_ai, parse_json
from .prompts import idea_prompt, script_prompt, caption_prompt, hashtags_prompt


def _ai_response(data):
    if isinstance(data, dict) and data.get('error'):
        if data.get('error_code') == 'GEMINI_QUOTA_EXCEEDED':
            return Response(data, status=status.HTTP_429_TOO_MANY_REQUESTS)
        return Response(data, status=status.HTTP_503_SERVICE_UNAVAILABLE)
    return Response(data, status=status.HTTP_200_OK)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_ideas(request):
    prompt = idea_prompt(request.data)
    ai_response = call_ai(prompt)
    data = parse_json(ai_response)
    if isinstance(data, list):
        return Response({'ideas': data}, status=status.HTTP_200_OK)
    return _ai_response(data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_script(request):
    prompt = script_prompt(request.data)
    ai_response = call_ai(prompt)
    data = parse_json(ai_response)
    return _ai_response(data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_caption(request):
    prompt = caption_prompt(request.data)
    ai_response = call_ai(prompt)
    data = parse_json(ai_response)
    return _ai_response(data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def generate_hashtags(request):
    prompt = hashtags_prompt(request.data)
    ai_response = call_ai(prompt)
    data = parse_json(ai_response)
    return _ai_response(data)


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def save_content(request):
    idea = request.data.get('idea') or {}
    script = request.data.get('script') or {}
    hashtags = request.data.get('hashtags') or []

    if isinstance(hashtags, str):
        hashtags = [value.strip() for value in hashtags.split() if value.strip()]

    required_fields = {
        'topic': request.data.get('topic'),
        'platform': request.data.get('platform'),
        'idea.title': idea.get('title'),
        'idea.description': idea.get('description'),
        'script.hook': script.get('hook'),
        'script.body': script.get('body'),
        'script.cta': script.get('cta'),
        'caption': request.data.get('caption'),
    }

    missing = [key for key, value in required_fields.items() if not value]
    if missing:
        return Response(
            {'error': f"Missing required fields: {', '.join(missing)}"},
            status=status.HTTP_400_BAD_REQUEST,
        )

    content = Content.objects.create(
        user=request.user,
        topic=request.data.get('topic'),
        platform=request.data.get('platform'),
        idea_title=idea.get('title'),
        idea_description=idea.get('description'),
        hook=script.get('hook'),
        body=script.get('body'),
        cta=script.get('cta'),
        caption=request.data.get('caption'),
        hashtags=hashtags,
    )

    return Response(
        {
            'message': 'saved',
            'content_id': content.id,
        },
        status=status.HTTP_201_CREATED,
    )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def saved_content(request):
    contents = Content.objects.filter(user=request.user).order_by('-created_at')

    data = [
        {
            'id': item.id,
            'topic': item.topic,
            'platform': item.platform,
            'idea': {
                'title': item.idea_title,
                'description': item.idea_description,
            },
            'script': {
                'hook': item.hook,
                'body': item.body,
                'cta': item.cta,
            },
            'caption': item.caption,
            'hashtags': item.hashtags,
            'created_at': item.created_at,
        }
        for item in contents
    ]

    return Response({'results': data}, status=status.HTTP_200_OK)