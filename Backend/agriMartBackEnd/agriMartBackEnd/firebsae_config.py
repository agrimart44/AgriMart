import firebase_admin
from firebase_admin import credentials, firestore
from firebase_admin import credentials, firestore, auth


# Initialize Firebase with the service account key
cred = credentials.Certificate('firebase/agri-mart-add65-firebase-adminsdk-fbsvc-b8bb3bc221.json')  # Replace with actual path
firebase_admin.initialize_app(cred)

# Initialize Firestore
db = firestore.client()


def verify_firebase_token(token):
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        return None