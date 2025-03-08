from agriMartBackEnd.firebsae_config import db, verify_firebase_token


def available_crops(request):
    """View to display all crops with is_in_cart=true that are not from the current user"""
    
    # Get Firebase token from request headers
    firebase_token = request.headers.get('Authorization')
    if not firebase_token:
        return JsonResponse({"error": "Firebase token is missing"}, status=400)
    
    # Verify the Firebase token
    decoded_token = verify_firebase_token(firebase_token)
    if not decoded_token:
        return JsonResponse({"error": "Invalid Firebase token"}, status=401)
    
    # Extract user ID from the decoded token
    current_user_id = decoded_token.get('uid')
    

