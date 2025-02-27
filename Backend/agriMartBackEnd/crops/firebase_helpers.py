from django import db
from firebase_admin import firestore, storage
from django.core.files.storage import default_storage
import uuid

def upload_image_to_firebase_storage(image):
    blob = storage.bucket().blob(f'crops/{uuid.uuid4()}/{image.name}')
    blob.upload_from_file(image)
    blob.make_public()  # Set the image to be publicly accessible
    return blob.public_url

def add_crop_to_firestore(data, user_id):
    # Generate a unique ID for the crop listing
    crop_id = str(uuid.uuid4())
    
    crop_data = {
        'name': data['name'],
        'description': data['description'],
        'price': data['price'],
        'location': data['location'],
        'quantity': data['quantity'],
        'harvest_date': data['harvest_date'],
        'user_id': user_id,
        'is_booked': False,  # Default value
        'crop_id': crop_id
    }

    # Upload photos to Firebase Storage and get their URLs
    if 'photos' in data:
        photo_urls = []
        for photo in data['photos']:
            photo_url = upload_image_to_firebase_storage(photo)
            photo_urls.append(photo_url)
        crop_data['photos'] = photo_urls

    # Add the crop data to Firestore
    db.collection('crops').document(crop_id).set(crop_data)

    return crop_id
