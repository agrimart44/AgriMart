import json
import unittest
from unittest.mock import patch, MagicMock
from django.http import JsonResponse
from datetime import datetime
from rest_framework import status as Status
from buyerview.views import (available_non_booked_crops, get_crop_details, add_to_cart,
                      get_user_crops_and_stats, delete_crop, CropUpdateView)
import google.api_core.exceptions

class TestAvailableNonBookedCrops(unittest.TestCase):
    @patch('firebase.verify_firebase_token')
    @patch('firebase.db.collection')
    def test_invalid_firebase_token(self, mock_collection, mock_verify_token):
        request = MagicMock()
        request.headers = {'Authorization': 'Bearer invalidtoken'}
        mock_verify_token.return_value = {'error': 'Invalid token'}
        response = available_non_booked_crops(request)
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.content, b'{"error": "Invalid token"}')


class TestGetCropDetails(unittest.TestCase):
    @patch('firebase.verify_firebase_token')
    @patch('firebase.db.collection')
    def test_invalid_firebase_token(self, mock_collection, mock_verify_token):
        request = MagicMock()
        request.headers = {'Authorization': 'Bearer invalidtoken'}
        mock_verify_token.return_value = {'error': 'Invalid token'}
        response = get_crop_details(request, 'crop123')
        self.assertEqual(response.status_code, 401)


class TestAddToCart(unittest.TestCase):
    @patch('firebase.verify_firebase_token')
    @patch('firebase.db.collection')
    def test_invalid_firebase_token(self, mock_collection, mock_verify_token):
        request = MagicMock()
        request.method = 'POST'
        request.headers = {'Authorization': 'Bearer invalidtoken'}
        request.body = json.dumps({}).encode('utf-8')
        mock_verify_token.return_value = {'error': 'Invalid token'}
        response = add_to_cart(request)
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.content, b'{"error": "Invalid token"}')

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db.collection')
    def test_invalid_request_method(self, mock_collection, mock_verify_token):
        request = MagicMock()
        request.method = 'GET'
        request.headers = {}
        response = add_to_cart(request)
        self.assertEqual(response.status_code, 405)
        self.assertEqual(response.content, b'{"error": "Invalid request method"}')


class TestGetUserCropsAndStats(unittest.TestCase):
    @patch('firebase.verify_firebase_token')
    @patch('firebase.db.collection')
    def test_no_firebase_token(self, mock_collection, mock_verify_token):
        request = MagicMock()
        request.headers = {}
        mock_verify_token.return_value = None
        response = get_user_crops_and_stats(request)
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.content, b'{"error": "Firebase token is missing"}')

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db.collection')
    def test_invalid_firebase_token(self, mock_collection, mock_verify_token):
        request = MagicMock()
        request.headers = {'Authorization': 'Bearer invalidtoken'}
        mock_verify_token.return_value = {'error': 'Invalid token'}
        response = get_user_crops_and_stats(request)
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.content, b'{"error": "Invalid token"}')


class TestDeleteCrop(unittest.TestCase):
    @patch('firebase.verify_firebase_token')
    @patch('firebase.db.collection')
    def test_invalid_request_method(self, mock_collection, mock_verify_token):
        request = MagicMock()
        request.method = 'GET'
        response = delete_crop(request, 'crop123')
        self.assertEqual(response.status_code, 405)
        self.assertEqual(response.content, b'{"error": "Invalid request method. Use DELETE."}')
        
    @patch('firebase.verify_firebase_token')
    @patch('firebase.db.collection')
    def test_invalid_firebase_token(self, mock_collection, mock_verify_token):
        request = MagicMock()
        request.method = 'DELETE'
        request.headers = {'Authorization': 'Bearer invalidtoken'}
        mock_verify_token.return_value = {'error': 'Invalid token'}
        response = delete_crop(request, 'crop123')
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.content, b'{"error": "Invalid token"}')


class TestCropUpdateView(unittest.TestCase):
    @patch('firebase.verify_firebase_token')
    @patch('cloudinary.uploader.upload')
    def test_no_firebase_token(self, mock_upload, mock_verify_token):
        request = MagicMock()
        request.method = 'PUT'
        request.data = {}
        request.FILES.getlist.return_value = []
        request.headers = {}
        mock_verify_token.return_value = None
        view = CropUpdateView()
        response = view.put(request, 'crop123')
        self.assertEqual(response.status_code, Status.HTTP_400_BAD_REQUEST)
        self.assertEqual(response.content, b'{"error": "Firebase token is missing"}')


if __name__ == '__main__':
    unittest.main()