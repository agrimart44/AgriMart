import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from firebase_admin import auth
from firebase import db  

# Utility function to verify Firebase ID token
def verify_firebase_token(token):
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        print(f"Error verifying token: {e}")
        return None


# View to get user details based on the Firebase ID token
@csrf_exempt
def get_user_details(request):
    if request.method == 'GET':
        id_token = request.headers.get('Authorization')

        if not id_token:
            return JsonResponse({'error': 'Authorization token is missing'}, status=400)

        if id_token.startswith('Bearer '):
            id_token = id_token[7:]

        decoded_token = verify_firebase_token(id_token)

        if not decoded_token:
            return JsonResponse({'error': 'Invalid or expired token'}, status=401)

        uid = decoded_token.get('uid')
        print(f"Decoded UID from token: {uid}")  # Debugging log

        try:
            user_ref = db.collection('users').document(uid)
            user_doc = user_ref.get()

            if not user_doc.exists:
                return JsonResponse({'error': 'User not found'}, status=404)

            # Fetch the user data
            user_data = user_doc.to_dict()

            # Ensure the data is returned in the desired order
            ordered_user_data = {
                'name': user_data.get('name'),
                'email': user_data.get('email'),
                'occupation': user_data.get('occupation'),
                'location': user_data.get('location'),
                'phone_number': user_data.get('phone_number')  # Add phone number to the response
            }

            return JsonResponse({'status': 'success', 'user_data': ordered_user_data}, status=200)

        except Exception as e:
            return JsonResponse({'error': f"Error retrieving user data: {str(e)}"}, status=500)

    return JsonResponse({'error': 'Invalid request method. Only GET is allowed.'}, status=405)
