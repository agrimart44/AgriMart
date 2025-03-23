import os
import requests
from google.auth.transport.requests import Request
from google.oauth2 import service_account
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from stream_chat import StreamChat
from django.conf import settings
import json
from google.oauth2 import service_account
from google.auth.transport.requests import Request
import requests



from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from stream_chat import StreamChat
from django.conf import settings
from firebase import db, verify_firebase_token, auth ,firestore
import json
from google.oauth2 import service_account
from google.auth.transport.requests import Request
import requests



USERS_COLLECTION = 'users'

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


def get_user_details(request):
    token = request.headers.get('Authorization')  # Get the token from Authorization header
    if not token:
        return JsonResponse({"error": "No token provided"}, status=400)

    # Remove "Bearer " prefix if it exists
    if token.startswith('Bearer '):
        token = token[7:]

    # Verify the token using the function from firebase.py
    decoded_token = verify_firebase_token(token)

    if "error" in decoded_token:
        return JsonResponse(decoded_token, status=401)

    uid = decoded_token['uid']  # Extract UID from the decoded token

    # Fetch user data from Firestore using the UID
    user_ref = firestore.client().collection(USERS_COLLECTION).document(uid)
    user_doc = user_ref.get()

    if user_doc.exists:
        user_data = user_doc.to_dict()
        return JsonResponse(user_data, safe=False)
    else:
        return JsonResponse({"error": "User not found"}, status=404)