from django.shortcuts import render
from django.http import JsonResponse
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
    
    try:
        # Query crops collection for documents where is_in_cart is true
        crops_ref = db.collection('crops')
        query = crops_ref.where('is_in_cart', '==', True).stream()
        
        # Filter out the user's own crops
        available_crops = []
        for crop in query:
            crop_data = crop.to_dict()
            # Include the document ID
            crop_data['id'] = crop.id
            
            # Only include crops that don't belong to the current user
            if crop_data.get('userId') != current_user_id:
                available_crops.append(crop_data)
        
        # Return the available crops
        return JsonResponse({"availableCrops": available_crops}, status=200)
    
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)
