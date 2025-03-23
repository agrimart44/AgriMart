import json
import unittest
from unittest.mock import patch, Mock, MagicMock
from urllib import response
from django.test import RequestFactory
from django.http import JsonResponse
from firebase_admin import auth
from firebase import db

# Stubbing out the import of the views because we cannot import it normally without Django environment
from user_details.views import get_user_details, verify_firebase_token  

class GetUserDetailsTestCase(unittest.TestCase):
    def setUp(self):
        self.factory = RequestFactory()

    @patch('firebase.verify_firebase_token')  # Patch the function in the current module
    @patch('firebase.db')  # Patch the db in the current module
    def test_get_user_details_successful(self, mock_db, mock_verify_token):
        # Mock the verify_token function
        mock_verify_token.return_value = {'uid': 'test_uid'}
        
        # Mock the Firestore document
        mock_user_doc = MagicMock()
        mock_user_doc.exists = True
        mock_user_doc.to_dict.return_value = {
            'name': 'John Doe',
            'email': 'john.doe@example.com',
            'occupation': 'Engineer',
            'location': 'New York',
            'phone_number': '1234567890'
        }
        
        # Set up the mock db chain
        mock_db.collection.return_value.document.return_value.get.return_value = mock_user_doc
        
        # Create request
        request = self.factory.get('/get-user-details', HTTP_AUTHORIZATION='Bearer valid_token')

        # Test view
        response = get_user_details(request)

        # Assertions
        expected_data = {
            'status': 'success',
            'user_data': {
                'name': 'John Doe',
                'email': 'john.doe@example.com',
                'occupation': 'Engineer',
                'location': 'New York',
                'phone_number': '1234567890'
            }
        }
        self.assertEqual(response.status_code, 200)
        self.assertDictEqual(json.loads(response.content), expected_data)

    @patch('firebase.verify_firebase_token')
    def test_get_user_details_no_token(self, mock_verify_token):
        # Create request without token
        request = self.factory.get('/get-user-details')

        # Test view
        response = get_user_details(request)

        # Assertions
        expected_data = {'error': 'Authorization token is missing'}
        self.assertEqual(response.status_code, 400)
        self.assertDictEqual(json.loads(response.content), expected_data)

    @patch('firebase.verify_firebase_token')
    def test_get_user_details_invalid_token(self, mock_verify_token):
        # Mock verify_firebase_token to return None
        mock_verify_token.return_value = None
        
        # Create request
        request = self.factory.get('/get-user-details', HTTP_AUTHORIZATION='Bearer invalid_token')

        # Test view
        response = get_user_details(request)

        # Assertions
        expected_data = {'error': 'Invalid or expired token'}
        self.assertEqual(response.status_code, 401)
        self.assertDictEqual(json.loads(response.content), expected_data)

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db')
    def test_get_user_details_user_not_found(self, mock_db, mock_verify_token):
        # Mock verify_firebase_token
        mock_verify_token.return_value = {'uid': 'unknown_uid'}
        
        # Mock db response for a non-existing user
        mock_user_doc = MagicMock()
        mock_user_doc.exists = False
        mock_db.collection.return_value.document.return_value.get.return_value = mock_user_doc
        
        # Create request
        request = self.factory.get('/get-user-details', HTTP_AUTHORIZATION='Bearer valid_token')

        # Test view
        response = get_user_details(request)

        # Assertions
        expected_data = {'error': 'User not found'}
        self.assertEqual(response.status_code, 404)
        self.assertDictEqual(json.loads(response.content), expected_data)

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db')
    def test_get_user_details_server_error(self, mock_db, mock_verify_token):
        # Mock verify_firebase_token
        mock_verify_token.return_value = {'uid': 'test_uid'}

        # Simulate exception in fetching user_data
        mock_db.collection.return_value.document.return_value.get.side_effect = Exception("DB Error")

        # Create request
        request = self.factory.get('/get-user-details', HTTP_AUTHORIZATION='Bearer valid_token')

        # Test view
        response = get_user_details(request)

        # Assertions
        self.assertEqual(response.status_code, 500)
        self.assertIn('Error retrieving user data:', json.loads(response.content)['error'])

    def test_get_user_details_invalid_method(self):
        # Use POST instead of GET
        request = self.factory.post('/get-user-details', HTTP_AUTHORIZATION='Bearer valid_token')

        # Test view
        response = get_user_details(request)

        # Assertions
        expected_data = {'error': 'Invalid request method. Only GET is allowed.'}
        self.assertEqual(response.status_code, 405)
        self.assertDictEqual(json.loads(response.content), expected_data)

    @patch('firebase.verify_firebase_token')
    def test_get_user_details_uid_not_found(self, mock_verify_token):
        # Mock verify_firebase_token to return a token without uid
        mock_verify_token.return_value = {'token': 'valid_token'}  # No uid
        
        # Create request
        request = self.factory.get('/get-user-details', HTTP_AUTHORIZATION='Bearer valid_token')

        # Test view
        response = get_user_details(request)

        # Assertions
        expected_data = {'error': 'UID not found in token'}
        self.assertEqual(response.status_code, 400)
        self.assertDictEqual(json.loads(response.content), expected_data)

# For running the tests directly
if __name__ == '__main__':
    # Mock imports that would be provided by Django
    import sys
    from unittest.mock import MagicMock

    # Create mocks for external dependencies
    auth = MagicMock()
    db = MagicMock()

    # Run the tests
    unittest.main()