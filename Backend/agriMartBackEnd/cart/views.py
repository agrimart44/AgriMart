from django.shortcuts import render
from django.http import JsonResponse
from firebase import db, verify_firebase_token

from django.http import JsonResponse
from firebase import db, verify_firebase_token

def available_crops(request):
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
        # 1. Access the users collection using the authenticated user's UID
        user_ref = db.collection('users').document(current_user_id)
        user_doc = user_ref.get()
        
        # Check if user document exists
        if not user_doc.exists:
            return JsonResponse({"availableCrops": []}, status=200)
        
        user_data = user_doc.to_dict()
        
        # 2. Check if the cart field exists and has content
        if 'cart' not in user_data or not user_data['cart']:
            return JsonResponse({"availableCrops": []}, status=200)
        
        # 3. Get crop IDs from user's cart
        cart_crop_ids = user_data['cart']
        available_crops = []

        # 4. Fetch corresponding crops from crops collection
        for crop_id in cart_crop_ids:
            crop_doc = db.collection('crops').document(crop_id).get()
            
            if crop_doc.exists:
                crop_data = crop_doc.to_dict()
                
                # Fetch user details of the farmer who added the crop
                farmer_id = crop_data.get('userId', '')  # Using userId field from crop document
                farmer_name = "Unknown"
                
                if farmer_id:
                    farmer_doc = db.collection('users').document(farmer_id).get()
                    if farmer_doc.exists:
                        farmer_name = farmer_doc.to_dict().get('name', 'Unknown')
                
                # Get crop name from crop document
                crop_name = crop_data.get('cropName', 'Unknown Crop')
                
                # 5. Structure the response JSON with required fields
                formatted_crop = {
                    'id': crop_id,
                    'name': crop_name,
                    'price': crop_data.get('price', 0),
                    'quantity': crop_data.get('quantity', 0),
                    'farmer': farmer_name  # Changed from 'seller' to 'farmer'
                }
                
                # Extract image URL if available
                if 'imageURLs' in crop_data and isinstance(crop_data['imageURLs'], list) and crop_data['imageURLs']:
                    formatted_crop['imageURL'] = crop_data['imageURLs'][0]
                else:
                    formatted_crop['imageURL'] = None
                
                available_crops.append(formatted_crop)
        
        # 6. Return the structured JSON response
        return JsonResponse({"availableCrops": available_crops}, status=200)
    
    except Exception as e:
        return JsonResponse({"error": f"Failed to fetch cart items: {str(e)}"}, status=500)


def clear_cart(request):
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
        # Access the users collection using the authenticated user's UID
        user_ref = db.collection('users').document(current_user_id)
        user_doc = user_ref.get()
        
        # Check if user document exists
        if not user_doc.exists:
            return JsonResponse({"message": "Cart is already empty"}, status=200)
        
        user_data = user_doc.to_dict()
        
        # Check if cart field exists and has content
        if 'cart' not in user_data or not user_data['cart']:
            return JsonResponse({"message": "Cart is already empty"}, status=200)
        
        # Get crop IDs from user's cart
        cart_crop_ids = user_data['cart']
        
        # Set is_booked to False for each crop in the cart
        for crop_id in cart_crop_ids:
            crop_ref = db.collection('crops').document(crop_id)
            crop_doc = crop_ref.get()
            
            if crop_doc.exists:
                crop_ref.update({"is_in_cart": False})
        
        # Clear the user's cart field
        user_ref.update({"cart": []})
        
        return JsonResponse({"message": "Cart cleared successfully"}, status=200)
    
    except Exception as e:
        return JsonResponse({"error": f"Failed to clear cart: {str(e)}"}, status=500)