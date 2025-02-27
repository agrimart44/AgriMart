from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.http import JsonResponse
from datetime import datetime

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

        # Validate inputs
        if not crop_name or not description or not price or not location or not quantity or not harvest_date:
            return JsonResponse({"error": "All fields are required"}, status=status.HTTP_400_BAD_REQUEST)

        if float(price) <= 0:
            return JsonResponse({"error": "Price must be greater than 0"}, status=status.HTTP_400_BAD_REQUEST)

        if int(quantity) <= 0:
            return JsonResponse({"error": "Quantity must be greater than 0"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            harvest_date = datetime.fromisoformat(harvest_date)
        except ValueError:
            return JsonResponse({"error": "Invalid harvest date format"}, status=status.HTTP_400_BAD_REQUEST)

        if harvest_date < datetime.now():
            return JsonResponse({"error": "Harvest date cannot be in the past"}, status=status.HTTP_400_BAD_REQUEST)

        # Generate a unique ID for the crop (Firestore auto-generates one but we can manually set one if needed)
        crop_id = f"crop_{datetime.now().strftime('%Y%m%d%H%M%S')}"

        # Prepare the data for Firestore
        crop_data = {
            'cropName': crop_name,
            'description': description,
            'price': float(price),
            'location': location,
            'quantity': int(quantity),
            'harvestDate': harvest_date,
            'userId': user_id,  # Store the user ID of the authenticated farmer
            'is_booked': False  # Set default value of is_booked to False
        }

        # Store the crop data in Firestore
        try:
            crop_ref = db.collection('crops').document(crop_id)
            crop_ref.set(crop_data)

            return JsonResponse({"message": "Crop uploaded successfully", "cropId": crop_id}, status=status.HTTP_200_OK)
        except Exception as e:
            return JsonResponse({"error": f"Failed to upload crop: {str(e)}"}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
