from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.http import JsonResponse
from datetime import datetime
import cloudinary.uploader
from agriMartBackEnd.firebsae_config import db, verify_firebase_token

class CropUploadView(APIView):
    def post(self, request):
        # Extract Firebase token from headers
        firebase_token = request.headers.get('Authorization')

        if not firebase_token:
            return JsonResponse({"error": "Firebase token is missing"}, status=status.HTTP_400_BAD_REQUEST)

        # Verify the Firebase token
        decoded_token = verify_firebase_token(firebase_token)

        if not decoded_token:
            return JsonResponse({"error": "Invalid Firebase token"}, status=status.HTTP_401_UNAUTHORIZED)

        user_id = decoded_token['uid']  # Extract the user ID from the token

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
        if not crop_name or not description or not price or not location or not quantity or not harvest_date or not images:
            return JsonResponse({"error": "All fields are required, including at least one image"}, status=status.HTTP_400_BAD_REQUEST)

        if float(price) <= 0:
            return JsonResponse({"error": "Price must be greater than 0"}, status=status.HTTP_400_BAD_REQUEST)

        if int(quantity) <= 0:
            return JsonResponse({"error": "Quantity must be greater than 0"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Convert to correct format: YYYY-MM-DD (Remove time part)
            harvest_date = datetime.strptime(harvest_date, "%Y-%m-%d").date().isoformat()
        except ValueError:
            return JsonResponse({"error": "Invalid harvest date format. Use YYYY-MM-DD"}, status=status.HTTP_400_BAD_REQUEST)

        if datetime.strptime(harvest_date, "%Y-%m-%d").date() < datetime.now().date():
            return JsonResponse({"error": "Harvest date cannot be in the past"}, status=status.HTTP_400_BAD_REQUEST)

        # Upload images to Cloudinary (up to 3 images)
        image_urls = []
        try:
            for i, image in enumerate(images[:3]):  # Limit to 3 images
                upload_result = cloudinary.uploader.upload(image)
                image_urls.append(upload_result["secure_url"])  # Store each image URL
        except Exception as e:
            return JsonResponse({"error": f"Image upload failed: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

        # Generate a unique ID for the crop
        crop_id = f"crop_{datetime.now().strftime('%Y%m%d%H%M%S')}"

        # Prepare the data for Firestore
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

        # Store the crop data in Firestore
        try:
            crop_ref = db.collection('crops').document(crop_id)
            crop_ref.set(crop_data)

            return JsonResponse({
                "message": "Crop uploaded successfully!",
                "cropId": crop_id,
                "imageURLs": image_urls
            }, status=status.HTTP_200_OK)
        except Exception as e:
            return JsonResponse({"error": f"Failed to upload crop: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
