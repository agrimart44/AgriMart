import logging
import google.cloud.firestore_v1.base_query
import google.api_core.exceptions
import json
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.http import JsonResponse
from datetime import datetime
import cloudinary.uploader
from firebase import db, verify_firebase_token
from google.cloud import firestore
from django.views.decorators.csrf import csrf_exempt


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
    
    

def get_user_crops_and_stats(request):
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
        
        # Get user profile to retrieve name
        user_ref = db.collection('users').document(current_user_id)
        user_doc = user_ref.get(timeout=10)
        
        user_name = ""
        if user_doc.exists:
            user_data = user_doc.to_dict()
            user_name = user_data.get('name', '')
        
        # Query crops collection where userId matches current user
        crops_ref = db.collection('crops')
        query = crops_ref.where('userId', '==', current_user_id)
        
        try:
            # Fetch crops listed by the user
            query_results = query.get(timeout=10)
            
            # Prepare list of crops to send to frontend
            user_crops = []
            total_value = 0  # Changed from total_price to total_value
            total_quantity = 0
            active_crops = 0
            booked_crops = 0
            
            for crop in query_results:
                crop_data = crop.to_dict()
                price = crop_data.get('price', 0)
                quantity = crop_data.get('quantity', 0)
                is_booked = crop_data.get('is_booked', False)
                
                # Calculate value of this crop (price * quantity)
                crop_value = price * quantity
                
                crop_details = {
                    "id": crop.id,
                    "cropName": crop_data.get('cropName', ''),
                    "price": price,
                    "location": crop_data.get('location', ''),
                    "quantity": quantity,
                    "cropValue": crop_value,  # Added crop value field
                    "harvestDate": crop_data.get('harvestDate', ''),
                    "description": crop_data.get('description', ''),
                    "is_booked": is_booked,
                    "imageURLs": crop_data.get('imageURLs', [])
                }
                
                # Add crop to user crops list
                user_crops.append(crop_details)
                
                # Update statistics
                total_value += crop_value
                total_quantity += quantity
                
                # Count booked vs active crops
                if is_booked:
                    booked_crops += 1
                else:
                    active_crops += 1
            
            # Calculate average price per unit (total value / total quantity)
            average_price = total_value / total_quantity if total_quantity > 0 else 0
            
            # Calculate average value per crop
            average_value_per_crop = total_value / len(user_crops) if user_crops else 0
            
            # Return the user's crops and improved stats
            return JsonResponse({
                "userName": user_name,
                "userCrops": user_crops,
                "stats": {
                    "totalCrops": len(user_crops),
                    "activeCrops": active_crops,
                    "bookedCrops": booked_crops,
                    "totalValue": total_value,
                    "totalQuantity": total_quantity,
                    "averagePricePerUnit": average_price,
                    "averageValuePerCrop": average_value_per_crop
                }
            }, status=200)
            
        except Exception as e:
            # Log any errors
            logger.error(f"Error fetching user crops: {str(e)}")
            return JsonResponse({"error": "Error fetching user crops", "details": str(e)}, status=500)
    
    except Exception as e:
        # Log the error
        logger.error(f"Error processing request: {str(e)}")
        
        # Return a cleaner error message
        return JsonResponse({"error": "Internal Server Error", "details": str(e)}, status=500)
    
    
@csrf_exempt
def delete_crop(request, crop_id):
    try:
        # Ensure the request method is DELETE (for deleting)
        if request.method != 'DELETE':
            return JsonResponse({"error": "Invalid request method. Use DELETE."}, status=405)
        
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
        
        # Get the crop document from Firestore
        crop_ref = db.collection('crops').document(crop_id)
        crop_doc = crop_ref.get()
        
        if not crop_doc.exists:
            return JsonResponse({"error": "Crop not found"}, status=404)
        
        crop_data = crop_doc.to_dict()
        
        # Check if the current user is the owner of the crop
        if crop_data.get('userId') != current_user_id:
            return JsonResponse({"error": "You are not authorized to delete this crop"}, status=403)
        
        # Delete the crop document from Firestore
        crop_ref.delete()
        
        return JsonResponse({"message": "Crop deleted successfully"}, status=200)

    except Exception as e:
        logger.error(f"Error deleting crop: {str(e)}")
        return JsonResponse({"error": "Internal Server Error", "details": str(e)}, status=500)

class CropUpdateView(APIView):
    def put(self, request, crop_id):
        # Extract Firebase token from headers
        auth_header = request.headers.get('Authorization')
        if not auth_header:
            return JsonResponse({"error": "Firebase token is missing"}, status=status.HTTP_400_BAD_REQUEST)

        # Remove 'Bearer ' prefix if present
        if auth_header.startswith('Bearer '):
            firebase_token = auth_header[7:]  # Remove 'Bearer ' prefix
        else:
            firebase_token = auth_header

        # Verify the Firebase token
        decoded_token = verify_firebase_token(firebase_token)
        if not decoded_token:
            return JsonResponse({"error": "Invalid Firebase token"}, status=status.HTTP_401_UNAUTHORIZED)

        user_id = decoded_token.get('user_id') or decoded_token.get('sub') or decoded_token.get('uid')
        if not user_id:
            return JsonResponse({"error": "User ID not found in token"}, status=status.HTTP_400_BAD_REQUEST)

        # Extract other fields from the request data
        crop_name = request.data.get('cropName')
        description = request.data.get('description')
        price = request.data.get('price')
        location = request.data.get('location')
        quantity = request.data.get('quantity')
        harvest_date = request.data.get('harvestDate')

        # Extract images (Supports up to 3 images)
        images = request.FILES.getlist('images')  # Get a list of uploaded images

        # Validate inputs
        if not crop_name or not description or not price or not location or not quantity or not harvest_date:
            return JsonResponse({"error": "All fields are required"}, status=status.HTTP_400_BAD_REQUEST)

        if float(price) <= 0:
            return JsonResponse({"error": "Price must be greater than 0"}, status=status.HTTP_400_BAD_REQUEST)

        if int(quantity) <= 0:
            return JsonResponse({"error": "Quantity must be greater than 0"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Convert to correct format: YYYY-MM-DD (Remove time part)
            harvest_date = datetime.strptime(harvest_date, "%Y-%m-%d").date().isoformat()
        except ValueError:
            return JsonResponse({"error": "Invalid harvest date format. Use YYYY-MM-DD"}, status=status.HTTP_400_BAD_REQUEST)

        if datetime.strptime(harvest_date, "%Y-%m-%d").date() > datetime.now().date():
            return JsonResponse({"error": "Harvest date cannot be in the Future date"}, status=status.HTTP_400_BAD_REQUEST)

        # Upload images to Cloudinary (up to 3 images)
        image_urls = []
        try:
            for i, image in enumerate(images[:3]):  # Limit to 3 images
                upload_result = cloudinary.uploader.upload(image)
                image_urls.append(upload_result["secure_url"])  # Store each image URL
        except Exception as e:
            return JsonResponse({"error": f"Image upload failed: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # Prepare the updated crop data
        crop_data = {
            'cropName': crop_name,
            'description': description,
            'price': float(price),
            'location': location,
            'quantity': int(quantity),
            'harvestDate': harvest_date,  # Stores only date (YYYY-MM-DD)
            'userId': user_id,
            'imageURLs': image_urls,  # Stores multiple image URLs
            'is_booked': False,
            'is_in_cart': False
        }

        # Fetch the existing crop from Firestore to check ownership and update
        try:
            crop_ref = db.collection('crops').document(crop_id)
            crop_doc = crop_ref.get()

            if not crop_doc.exists:
                return JsonResponse({"error": "Crop not found"}, status=status.HTTP_404_NOT_FOUND)

            existing_crop_data = crop_doc.to_dict()

            # Check if the current user is the owner of the crop
            if existing_crop_data.get('userId') != user_id:
                return JsonResponse({"error": "You are not authorized to update this crop"}, status=status.HTTP_403_FORBIDDEN)

            # Update the crop document in Firestore
            crop_ref.update(crop_data)

            return JsonResponse({
                "message": "Crop updated successfully!",
                "cropId": crop_id,
                "imageURLs": image_urls
            }, status=status.HTTP_200_OK)
        except Exception as e:
            return JsonResponse({"error": f"Failed to update crop: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
