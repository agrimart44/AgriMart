import firebase_admin
from firebase_admin import credentials, firestore
from firebase_admin import credentials, firestore, auth


# Initialize Firebase with the service account key
cred = credentials.Certificate('firebase/agri-mart-add65-firebase-adminsdk-fbsvc-a93f240f48.json')  # Replace with actual path
firebase_admin.initialize_app(cred)

# Initialize Firestore
db = firestore.client()


def verify_firebase_token(token):
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except auth.ExpiredIdTokenError:
        return {"error": "Token has expired"}
    except auth.RevokedIdTokenError:
        return {"error": "Token has been revoked"}
    except auth.InvalidIdTokenError:
        return {"error": "Invalid token"}
    except Exception as e:
        return {"error": f"Error verifying token: {str(e)}"}
    except Exception as e:
        return None


def verify_firebase_token(token):
    try:
        decoded_token = auth.verify_id_token(token)
        return decoded_token
    except Exception as e:
        return None