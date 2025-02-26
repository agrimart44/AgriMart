from django.shortcuts import render
from django.views.decorators.csrf import csrf_exempt
from django.http import JsonResponse
from firebase import db  # Assuming firebase.py is set up correctly
from django.contrib.auth.hashers import make_password
import json
import re

# Validation function
def validate_user_data(user_data):
    errors = []
    
    # Validate username
    if not user_data.get('username'):
        errors.append('Username is required.')
    
    # Validate email format
    email = user_data.get('email')
    if not email or not re.match(r"[^@]+@[^@]+\.[^@]+", email):
        errors.append('Invalid email address.')
    
    # Validate password and confirm password match
    password = user_data.get('password')
    confirm_password = user_data.get('confirm_password')
    if not password or password != confirm_password:
        errors.append('Passwords do not match.')
    
    # Validate password strength
    if len(password) < 8:
        errors.append('Password should be at least 8 characters long.')
    
    # Validate occupation
    if not user_data.get('occupation'):
        errors.append('Occupation is required.')
    
    return errors if errors else None

# View to register user
@csrf_exempt
def register_user(request):
    if request.method == 'POST':
        # Get data from the frontend (assuming it’s JSON)
        user_data = json.loads(request.body)

        # Ensure that email is provided
        if 'email' not in user_data:
            return JsonResponse({'error': 'Email is required'}, status=400)

        email = user_data['email']

        # Check if the user already exists in Firestore by email
        user_ref = db.collection('users').document(email)  # Using email as the document ID
        user_doc = user_ref.get()  # Fetch the document

        if user_doc.exists:  # If a document with this email already exists
            return JsonResponse({'error': 'User with this email already exists.'}, status=400)

        # Validate the user data
        validation_errors = validate_user_data(user_data)

        if validation_errors:
            return JsonResponse({'error': validation_errors}, status=400)

        # Hash the password before storing it
        hashed_password = make_password(user_data['password'])
        user_data['password'] = hashed_password  # Replace plain password with hashed one

        # Add the user to Firestore using email as the document ID
        user_ref.set(user_data)

        return JsonResponse({'status': 'success', 'message': 'User registered successfully'})

    return JsonResponse({'error': 'Invalid request method'}, status=405)
