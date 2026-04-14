from rest_framework.decorators import api_view
from rest_framework.response import Response

from content_gen.models import Content

from .services.ai_service import call_ai, parse_json
from .prompts import idea_prompt, script_prompt, caption_prompt, hashtags_prompt


@api_view(['POST'])
def generate_ideas(request):
    prompt = idea_prompt(request.data)
    ai_response = call_ai(prompt)
    data = parse_json(ai_response)
    return Response(data)


@api_view(['POST'])
def generate_script(request):
    prompt = script_prompt(request.data)
    ai_response = call_ai(prompt)
    data = parse_json(ai_response)
    return Response(data)


@api_view(['POST'])
def generate_caption(request):
    prompt = caption_prompt(request.data)
    ai_response = call_ai(prompt)
    data = parse_json(ai_response)
    return Response(data)


@api_view(['POST'])
def generate_hashtags(request):
    prompt = hashtags_prompt(request.data)
    ai_response = call_ai(prompt)
    data = parse_json(ai_response)
    return Response(data)

@api_view(['POST'])
def save_content(request):
    content = Content.objects.create(
        user=request.user,
        topic=request.data['topic'],
        platform=request.data['platform'],
        idea_title=request.data['idea']['title'],
        idea_description=request.data['idea']['description'],
        hook=request.data['script']['hook'],
        body=request.data['script']['body'],
        cta=request.data['script']['cta'],
        caption=request.data['caption'],
        hashtags=request.data['hashtags'],
    )

    return Response({
        "message": "saved",
        "content_id": content.id
    })