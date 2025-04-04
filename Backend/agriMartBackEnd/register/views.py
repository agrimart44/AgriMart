import json
import re
from firebase_admin import auth
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import firebase_admin
from django.contrib.auth.hashers import make_password
from firebase import db


# Validation function
def validate_user_data(user_data):
    errors = []
    
    if not user_data.get('username'):
        errors.append('Username is required.')
    
    email = user_data.get('email')
    if not email or not re.match(r"[^@]+@[^@]+\.[^@]+", email):
        errors.append('Invalid email address.')
    
    password = user_data.get('password')
    confirm_password = user_data.get('confirm_password')
    if not password or password != confirm_password:
        errors.append('Passwords do not match.')
    
    if len(password) < 8:
        errors.append('Password should be at least 8 characters long.')
    
    if not user_data.get('occupation'):
        errors.append('Occupation is required.')
    
    # Check if location is provided
    if not user_data.get('location'):
        errors.append('Location is required.')

    # Check if phone number is provided and valid
    phone_number = user_data.get('phone_number')
    if not phone_number or not re.match(r"^0\d{9}$", phone_number):
        errors.append('Invalid phone number.')

    return errors if errors else None

# View to register user
@csrf_exempt
def register_user(request):
    if request.method == 'POST':
        user_data = json.loads(request.body)

        if 'email' not in user_data:
            return JsonResponse({'error': 'Email is required'}, status=400)

        email = user_data['email']

        # Check if the user already exists in Firestore using UID as the document ID
        user_ref = db.collection('users').document(email)  # Using email to look up the user
        user_doc = user_ref.get()

        if user_doc.exists:
            return JsonResponse({'error': 'User with this email already exists.'}, status=400)

        validation_errors = validate_user_data(user_data)

        if validation_errors:
            return JsonResponse({'error': validation_errors}, status=400)

        try:
            # Create the user in Firebase Authentication
            user = auth.create_user(
                email=email,
                password=user_data['password']
            )

            hashed_password = make_password(user_data['password'])
            user_data['password'] = hashed_password  # Optional: If you want to store a hashed password in Firestore

            user_data['uid'] = user.uid  # Store Firebase UID

            # Store user data in Firestore under the UID
            user_ref = db.collection('users').document(user.uid)  # Use UID as the document ID
            user_ref.set({
                'name': user_data.get('username'),
                'email': user_data.get('email'),
                'occupation': user_data.get('occupation'),
                'location': user_data.get('location'),
                'phone_number': user_data.get('phone_number'),  # Store phone number
                # Add any additional user data you need to store
            })

            return JsonResponse({'status': 'success', 'message': 'User registered successfully'})
        
        except Exception as e:
            return JsonResponse({'error': f'Failed to register user: {str(e)}'}, status=500)

    return JsonResponse({'error': 'Invalid request method'}, status=405)
