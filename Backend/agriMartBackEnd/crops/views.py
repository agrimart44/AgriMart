from django.shortcuts import render

# Create your views here.
from django.http import JsonResponse
from django.views import View
from django.shortcuts import get_object_or_404
from .forms import CropListingForm
from .firebase_helpers import add_crop_to_firestore
from django.contrib.auth.models import User
from django.views.decorators.csrf import csrf_exempt



import firebase_admin
from firebase_admin import auth

def verify_firebase_token(id_token):
    try:
        decoded_token = auth.verify_id_token(id_token)
        return decoded_token
    except:
        return None



class CropListingView(View):
    @csrf_exempt
    def post(self, request, *args, **kwargs):
        # Assuming the user is logged in
        user = request.user
        if not user.is_authenticated:
            return JsonResponse({'error': 'User not authenticated'}, status=401)

        form = CropListingForm(request.POST, request.FILES)
        
        if form.is_valid():
            # Get the form data
            data = form.cleaned_data

            # Add the crop to Firestore and get the crop ID
            crop_id = add_crop_to_firestore(data, user.id)
            
            return JsonResponse({'message': 'Crop listed successfully!', 'crop_id': crop_id}, status=200)
        
        # If form is not valid, return error
        return JsonResponse({'errors': form.errors}, status=400)
