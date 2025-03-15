from django.http import JsonResponse
from firebase import db, verify_firebase_token
import logging
import google.cloud.firestore_v1.base_query
import google.api_core.exceptions
from google.cloud import firestore
from django.views.decorators.csrf import csrf_exempt
import json

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
                    # Format the crop details
                    crop_details = {
                        "id": crop.id,
                        "cropName": crop_data.get('cropName', ''),
                        "price": crop_data.get('price', 0),
                        "location": crop_data.get('location', ''),
                        "quantity": crop_data.get('quantity', 0),
                        "userId": crop_data.get('userId', ''),
                        "harvestDate": crop_data.get('harvestDate', ''),
                        "description": crop_data.get('description', ''),
                        "is_in_cart": crop_data.get('is_in_cart', False),
                        "imageURLs": crop_data.get('imageURLs', [])
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


def get_crop_details(request, crop_id):
    firebase_token = request.headers.get('Authorization', '').replace('Bearer ', '')
    decoded_token = verify_firebase_token(firebase_token)

    if isinstance(decoded_token, dict) and 'error' in decoded_token:
        return JsonResponse(decoded_token, status=401)

    crop_ref = db.collection('crops').document(crop_id)
    crop_doc = crop_ref.get()

    if crop_doc.exists:
        crop_data = crop_doc.to_dict()

        farmer_ref = db.collection('users').document(crop_data['userId'])
        farmer_doc = farmer_ref.get()

        farmer_data = farmer_doc.to_dict() if farmer_doc.exists else {}

        return JsonResponse({
            "id": crop_doc.id,
            "cropName": crop_data.get('cropName', ''),
            "description": crop_data.get('description', ''),
            "price": crop_data.get('price', 0),
            "location": crop_data.get('location', ''),
            "quantity": crop_data.get('quantity', 0),
            "userId": crop_data.get('userId', ''),
            "harvestDate": crop_data.get('harvestDate', ''),
            "is_booked": crop_data.get('is_booked', False),
            "is_in_cart": crop_data.get('is_in_cart', False),
            "imageURLs": crop_data.get('imageURLs', []),
            # Added fields:
            "farmerName": farmer_ref.get().to_dict().get('name', 'Unknown Farmer'),
            "contactNumber": farmer_ref.get().to_dict().get('phone_number', 'Not available'),
        }, status=200)
    else:
        return JsonResponse({"error": "Crop not found"}, status=404)





@csrf_exempt
def add_to_cart(request):
    try:
        # Ensure the request method is POST
        if request.method != 'POST':
            return JsonResponse({"error": "Invalid request method"}, status=405)
        
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
        
        # Get the crop_id and quantity from the request body (JSON)
        body = json.loads(request.body.decode('utf-8'))
        crop_id = body.get('crop_id')
        quantity = body.get('quantity', 1)  # Default to 1 if not specified
        
        if not crop_id:
            return JsonResponse({"error": "Crop ID is required"}, status=400)
        
        # 1. Check if the crop exists and has enough quantity
        crop_ref = db.collection('crops').document(crop_id)
        crop_doc = crop_ref.get()
        
        if not crop_doc.exists:
            return JsonResponse({"error": "Crop not found"}, status=404)
            
        crop_data = crop_doc.to_dict()
        available_quantity = crop_data.get('quantity', 0)
        
        if quantity > available_quantity:
            return JsonResponse({
                "error": f"Requested quantity ({quantity}kg) exceeds available stock ({available_quantity}kg)"
            }, status=400)
        
        # 2. Check if the crop is already in the user's cart
        user_ref = db.collection('users').document(current_user_id)
        user_doc = user_ref.get()

        if not user_doc.exists:
            return JsonResponse({"error": "User not found"}, status=404)

        user_data = user_doc.to_dict()
        user_cart = user_data.get('cart', [])
        
        if crop_id in user_cart:
            return JsonResponse({"error": "This crop is already in your cart"}, status=400)
        
        # 3. Update the Crop document to set `is_in_cart = true`
        crop_ref.update({'is_in_cart': True})
        
        # 4. Add crop ID to the user's cart with quantity information
        # Create a subcollection for cart details or add to cart array with quantity
        cart_item_ref = user_ref.collection('cart_items').document(crop_id)
        cart_item_ref.set({
            'crop_id': crop_id,
            'quantity': quantity,
            'added_at': firestore.SERVER_TIMESTAMP
        })
        
        # Also add to the main cart array for quick lookups
        user_ref.update({
            'cart': firestore.ArrayUnion([crop_id])
        })

        return JsonResponse({
            "message": f"{quantity}kg of crop added to cart successfully"
        }, status=200)
    
    except Exception as e:
        # Log the error
        logger.error(f"Error adding crop to cart: {str(e)}")
        return JsonResponse({"error": "Internal Server Error", "details": str(e)}, status=500)
    
    