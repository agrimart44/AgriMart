
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from stream_chat import StreamChat
from django.conf import settings
from firebase import db, verify_firebase_token, auth ,firestore
import json
from google.oauth2 import service_account
from google.auth.transport.requests import Request
import requests



USERS_COLLECTION = 'users'


@csrf_exempt  # Only for testing - remove in production
def get_stream_jwt(request):
    if request.method != 'POST':
        return JsonResponse({'error': 'POST method required'}, status=405)

    user_id = request.POST.get('user_id')  # Use POST instead of GET

    if not user_id:
        return JsonResponse({'error': 'user_id is required'}, status=400)

    client = StreamChat(api_key=settings.STREAM_API_KEY, api_secret=settings.STREAM_API_SECRET)
    token = client.create_token(user_id)
    return JsonResponse({'token': token})



def get_user_details(request):
    token = request.headers.get('Authorization')  # Get the token from Authorization header
    if not token:
        return JsonResponse({"error": "No token provided"}, status=400)

    # Remove "Bearer " prefix if it exists
    if token.startswith('Bearer '):
        token = token[7:]

    # Verify the token using the function from firebase.py
    decoded_token = verify_firebase_token(token)
    
    if "error" in decoded_token:
        return JsonResponse(decoded_token, status=401)

    uid = decoded_token['uid']  # Extract UID from the decoded token

    # Fetch user data from Firestore using the UID
    user_ref = firestore.client().collection(USERS_COLLECTION).document(uid)
    user_doc = user_ref.get()

    if user_doc.exists:
        user_data = user_doc.to_dict()
        return JsonResponse(user_data, safe=False)
    else:
        return JsonResponse({"error": "User not found"}, status=404)
    
SERVICE_ACCOUNT_FILE = r'C:\Users\rukshan\Music\Clone5690\AgriMart\Backend\agriMartBackEnd\firebase\agri-mart-add65-firebase-adminsdk-fbsvc-a93f240f48.json'

# Check if the service account file exists
if not os.path.exists(SERVICE_ACCOUNT_FILE):
    raise FileNotFoundError(f"Service account file not found: {SERVICE_ACCOUNT_FILE}")


# Function to get an OAuth2 access token
def get_access_token():
    try:
        print("[DEBUG] Loading credentials from service account file...")
        credentials = service_account.Credentials.from_service_account_file(
            SERVICE_ACCOUNT_FILE,
            scopes=["https://www.googleapis.com/auth/firebase.messaging"]
        )
        print("[DEBUG] Successfully loaded credentials.")

        print("[DEBUG] Refreshing access token...")
        credentials.refresh(Request())
        print("[DEBUG] Access token refreshed successfully.")

        access_token = credentials.token
        print(f"[DEBUG] Retrieved access token: {access_token[:50]}... (truncated)")
        return access_token
    except Exception as e:
        print(f"[ERROR] Failed to retrieve access token: {e}")
        raise


# Function to send notification via FCM v1 API
def send_fcm_notification(token, title, body):
    try:
        print("[DEBUG] Starting notification sending process...")

        # Step 1: Get access token
        print("[DEBUG] Fetching access token...")
        access_token = get_access_token()
        print("[DEBUG] Access token fetched successfully.")

        # Step 2: Prepare FCM API URL and headers
        url = f"https://fcm.googleapis.com/v1/projects/agri-mart-add65/messages:send"
        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json",
        }
        print(f"[DEBUG] FCM API URL: {url}")
        print(f"[DEBUG] Headers: {json.dumps(headers, indent=2)}")

        # Step 3: Prepare payload
        payload = {
            "message": {
                "token": token,
                "notification": {
                    "title": title,
                    "body": body
                },
                "data": {
                    "click_action": "FLUTTER_NOTIFICATION_CLICK",
                    "id": "1",
                    "status": "done"
                }
            }
        }
        print(f"[DEBUG] Notification payload: {json.dumps(payload, indent=2)}")

        # Step 4: Send POST request to FCM
        print("[DEBUG] Sending POST request to FCM API...")
        response = requests.post(url, headers=headers, json=payload)
        print(f"[DEBUG] Response Status Code: {response.status_code}")

        # Step 5: Parse and log response
        try:
            response_data = response.json()
            print(f"[DEBUG] Response Data: {json.dumps(response_data, indent=2)}")
        except ValueError:
            print("[DEBUG] Response is not JSON. Raw response text:")
            print(response.text)

        # Step 6: Handle success or failure
        if response.status_code == 200:
            print("[SUCCESS] Notification sent successfully!")
        else:
            print(f"[ERROR] Failed to send notification. Status Code: {response.status_code}")
            print(f"[ERROR] Error details: {response_data.get('error', 'No error details')}")

    except Exception as e:
        print(f"[ERROR] An unexpected error occurred: {e}")
        raise

def  hii():
 print("hii")
