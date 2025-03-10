from django.shortcuts import render
from django.http import JsonResponse
from stream_chat import StreamChat
from django.conf import settings

def get_stream_jwt(request):
    user_id = request.GET.get('user_id')

    if not user_id:
        return JsonResponse({'error': 'user_id is required'}, status=400)

    # Create StreamChat instance with your API key and secret
    client = StreamChat(api_key=settings.STREAM_API_KEY, api_secret=settings.STREAM_API_SECRET)

    # Generate the JWT token for the user
    token = client.create_token(user_id)

    # Return the token as JSON
    return JsonResponse({'token': token})
