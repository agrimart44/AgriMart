import firebase_admin
from firebase_admin import credentials, firestore

# Initialize Firebase with the service account key
cred = credentials.Certificate('firebase/agri-mart-add65-firebase-adminsdk-fbsvc-a93f240f48.json')  # Replace with actual path
firebase_admin.initialize_app(cred)

# Initialize Firestore
db = firestore.client()
