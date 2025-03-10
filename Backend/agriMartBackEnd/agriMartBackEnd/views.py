# from django.shortcuts import render
# from django.http import JsonResponse
# from stream_chat import StreamChat
# from django.conf import settings
# from django.views.decorators.http import require_POST



# def get_stream_jwt(request):
#     user_id = request.GET.get('user_id')

#     if not user_id:
#         return JsonResponse({'error': 'user_id is required'}, status=400)

#     # Create StreamChat instance with your API key and secret
#     client = StreamChat(api_key=settings.STREAM_API_KEY, api_secret=settings.STREAM_API_SECRET)

#     # Generate the JWT token for the user
#     token = client.create_token(user_id)

#     # Return the token as JSON
#     return JsonResponse({'token': token})

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from stream_chat import StreamChat
from django.conf import settings

@csrf_exempt  # Only for testing - remove in production
def get_stream_jwt(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'POST method required'}, status=405)

    user_id = request.POST.get('user_id')  # Use POST instead of GET

    if not user_id:
        return JsonResponse({'error': 'user_id is required'}, status=400)

    client = StreamChat(api_key=settings.STREAM_API_KEY, api_secret=settings.STREAM_API_SECRET)
    token = client.create_token(user_id)
    return JsonResponse({'token': token})
