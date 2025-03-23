
import json
import re
import unittest
from django.http import JsonResponse
from django.test import RequestFactory, TestCase
from django.views.decorators.csrf import csrf_exempt
from unittest.mock import patch, MagicMock
from firebase_admin import auth
from firebase import db
from register.views import register_user

# Assuming the code from above is placed here

class TestUserRegistration(TestCase):
    def setUp(self):
        self.factory = RequestFactory()

    @patch('firebase_admin.auth.create_user')
    @patch('firebase.db.collection')
    def test_register_user_success(self, mock_db_collection, mock_create_user):
        # Mocking Firestore database
        mock_db_collection.return_value.document.return_value.get.return_value.exists = False
        mock_user = MagicMock()
        mock_user.uid = "123"
        mock_create_user.return_value = mock_user

        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "validPass123",
            "confirm_password": "validPass123",
            "occupation": "tester",
            "location": "Test City",
            "phone_number": "0123456789"
        }

        request = self.factory.post('/register_user', data=json.dumps(user_data), content_type='application/json')
        response = register_user(request)
        self.assertEqual(response.status_code, 200)
        self.assertJSONEqual(response.content, {"status": "success", "message": "User registered successfully"})

    @patch('firebase.db.collection')
    def test_register_user_already_exists(self, mock_db_collection):
        # Mocking Firestore database to return an existing user
        mock_db_collection.return_value.document.return_value.get.return_value.exists = True
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "validPass123",
            "confirm_password": "validPass123",
            "occupation": "tester",
            "location": "Test City",
            "phone_number": "0123456789"
        }

        request = self.factory.post('/register_user', data=json.dumps(user_data), content_type='application/json')
        response = register_user(request)
        self.assertEqual(response.status_code, 400)
        self.assertJSONEqual(response.content, {"error": "User with this email already exists."})

    def test_register_user_missing_email(self):
        user_data = {
            "username": "testuser",
            "password": "validPass123",
            "confirm_password": "validPass123",
            "occupation": "tester",
            "location": "Test City",
            "phone_number": "0123456789"
        }

        request = self.factory.post('/register_user', data=json.dumps(user_data), content_type='application/json')
        response = register_user(request)
        self.assertEqual(response.status_code, 400)
        self.assertJSONEqual(response.content, {"error": "Email is required"})

    @patch('firebase.db.collection')
    def test_register_user_validation_errors(self, mock_db_collection):
        # Mocking Firestore database to not return an existing user
        mock_db_collection.return_value.document.return_value.get.return_value.exists = False

        user_data = {
            "username": "",
            "email": "invalid-email",
            "password": "short",
            "confirm_password": "notsame",
            "occupation": "",
            "location": "",
            "phone_number": "123"
        }

        expected_errors = [
            'Username is required.',
            'Invalid email address.',
            'Passwords do not match.',
            'Password should be at least 8 characters long.',
            'Occupation is required.',
            'Location is required.',
            'Invalid phone number.'
        ]

        request = self.factory.post('/register_user', data=json.dumps(user_data), content_type='application/json')
        response = register_user(request)
        self.assertEqual(response.status_code, 400)
        self.assertJSONEqual(response.content, {"error": expected_errors})

    def test_register_user_get_method(self):
        request = self.factory.get('/register_user')
        response = register_user(request)
        self.assertEqual(response.status_code, 405)
        self.assertJSONEqual(response.content, {"error": "Invalid request method"})

    @patch('firebase_admin.auth.create_user', side_effect=Exception("Create user error"))
    @patch('firebase.db.collection')
    def test_register_user_create_user_exception(self, mock_db_collection, mock_create_user):
        # Mocking Firestore database
        mock_db_collection.return_value.document.return_value.get.return_value.exists = False
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "validPass123",
            "confirm_password": "validPass123",
            "occupation": "tester",
            "location": "Test City",
            "phone_number": "0123456789"
        }

        request = self.factory.post('/register_user', data=json.dumps(user_data), content_type='application/json')
        response = register_user(request)
        self.assertEqual(response.status_code, 500)
        self.assertJSONEqual(response.content, {"error": "Failed to register user: Create user error"})

if __name__ == "__main__":
    unittest.main()
