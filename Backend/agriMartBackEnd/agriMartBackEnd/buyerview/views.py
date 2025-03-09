from django.http import JsonResponse
from agriMartBackEnd.firebsae_config import db, verify_firebase_token
import logging
import google.cloud.firestore_v1.base_query
import google.api_core.exceptions
from google.cloud import firestore
from django.views.decorators.csrf import csrf_exempt  # Import csrf_exempt
import json  # Import json to parse the request body






# Set up logger
logger = logging.getLogger(__name__)

def available_non_booked_crops(request):
    try:
        # Get Firebase token from request headers
        firebase_token = request.headers.get('Authorization')
        if not firebase_token:
            return JsonResponse({"error": "Firebase token is missing"}, status=400)
        
        # Remove 'Bearer ' prefix if present
        if firebase_token.startswith('Bearer '):
            firebase_token = firebase_token[7:]
        
        # Verify the Firebase token
        decoded_token = verify_firebase_token(firebase_token)
        if isinstance(decoded_token, dict) and 'error' in decoded_token:
            return JsonResponse(decoded_token, status=401)
        
        # Extract user ID from the decoded token
        current_user_id = decoded_token.get('uid')
        
        # Query crops collection where is_booked is False
        crops_ref = db.collection('crops')
        
        # Add timeout to the query to prevent hanging
        query = crops_ref.where('is_booked', '==', False).limit(50)
        
        try:
            # Use get() with timeout instead of stream() which can hang
            query_results = query.get(timeout=10)
            
            # Prepare list of crops to send to frontend
            available_crops = []
            for crop in query_results:
                crop_data = crop.to_dict()
                
                # Only include crops that don't belong to the current user
                if crop_data.get('userId') != current_user_id:
                    # Extract the first image URL (if available)
                    image_url = None
                    if 'imageURLs' in crop_data and isinstance(crop_data['imageURLs'], list) and crop_data['imageURLs']:
                        image_url = crop_data['imageURLs'][0]
                    
                    # Format the crop details
                    crop_details = {
                        "id": crop.id,
                        "cropName": crop_data.get('cropName', ''),
                        "price": crop_data.get('price', 0),
                        "location": crop_data.get('location', ''),
                        "quantity": crop_data.get('quantity', 0),
                        "imageURL": image_url
                    }
                    
                    available_crops.append(crop_details)
            
            # Return the available crops
            return JsonResponse({"availableCrops": available_crops}, status=200)
            
        except google.api_core.exceptions.FailedPrecondition as index_error:
            # This catches the specific Firestore index error
            logger.error(f"Firestore index error: {str(index_error)}")
            error_message = str(index_error)
            # Extract the index creation URL from the error message if available
            if "https://" in error_message:
                index_url = error_message[error_message.find("https://"):]
                return JsonResponse({
                    "error": "Missing Firestore index", 
                    "message": "This query requires a composite index. Click the link below to create it:",
                    "index_url": index_url
                }, status=500)
            return JsonResponse({"error": "Missing required Firestore index"}, status=500)
            
        except google.api_core.exceptions.DeadlineExceeded:
            return JsonResponse({"error": "Firestore query timed out"}, status=504)
    
    except Exception as e:
        # Log the error
        logger.error(f"Error fetching crops: {str(e)}")
        
        # Return a cleaner error message
        return JsonResponse({"error": "Internal Server Error", "details": str(e)}, status=500)


