def idea_prompt(data):
    return f"""
You are a viral content strategist.

Generate EXACTLY 3 highly engaging content ideas.

Context:
Platform: {data['platform']}
Topic: {data['topic']}
Goal: {data['goal']}
Audience: {data['audience']}
Tone: {data['tone']}

Rules:
- Each idea must be unique
- Keep titles short and catchy (max 10 words)
- Focus on viral and engaging concepts
- Description must be 1–2 sentences only

IMPORTANT:
- Return ONLY valid JSON
- Do NOT include explanation, markdown, or extra text

Output format:
[
  {{
    "title": "string",
    "type": "string",
    "description": "string"
  }}
]
"""

def script_prompt(data):
    return f"""
You are a short-form video script expert (TikTok/Reels).

Create a high-retention script.

Content Idea:
Title: {data['title']}
Description: {data['description']}

Rules:
- Hook must grab attention in the first 3 seconds
- Body must be fast-paced and engaging
- CTA must encourage interaction (like, comment, follow)
- Keep language natural and suitable for social media

IMPORTANT:
- Return ONLY valid JSON
- Do NOT include explanation or extra text

Output format:
{{
  "hook": "string",
  "body": "string",
  "cta": "string"
}}
"""

def caption_prompt(data):
    return f"""
You are a social media copywriter.

Create an engaging caption.

Context:
Platform: {data['platform']}
Tone: {data['tone']}

Rules:
- Caption must be engaging and natural
- Include a call-to-action
- Keep caption under 150 words

IMPORTANT:
- Return ONLY valid JSON
- Do NOT include explanation or extra text

Output format:
{{
  "caption": "string"
}}
"""

def hashtags_prompt(data):
    return f"""
You are a social media hashtag strategist.

Generate relevant hashtags for a social media post.

Context:
Platform: {data['platform']}
Topic: {data['topic']}
Tone: {data['tone']}

Rules:
- Generate 8–12 relevant hashtags
- Mix popular and niche hashtags
- Use hashtags appropriate for the platform
- Include trending and evergreen hashtags

IMPORTANT:
- Return ONLY valid JSON
- Do NOT include explanation or extra text

Output format:
{{
  "hashtags": ["string", "string"]
}}
"""