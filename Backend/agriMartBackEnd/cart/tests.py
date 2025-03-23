import unittest
from unittest.mock import patch, MagicMock
from django.http import JsonResponse
from cart.views import available_crops, clear_cart

class TestCropFunctions(unittest.TestCase):

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db')
    def test_available_crops_missing_token(self, mock_db, mock_verify_token):
        request = MagicMock()
        request.headers = {}
        response = available_crops(request)
        
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.content, b'{"error": "Firebase token is missing"}')

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db')
    def test_available_crops_invalid_token(self, mock_db, mock_verify_token):
        request = MagicMock()
        request.headers = {'Authorization': 'invalidtoken'}
        mock_verify_token.return_value = None
        response = available_crops(request)
        
        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.content, b'{"error": "Invalid Firebase token"}')

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db')
    def test_available_crops_no_user_doc(self, mock_db, mock_verify_token):
        request = MagicMock()
        request.headers = {'Authorization': 'validtoken'}
        mock_verify_token.return_value = {'uid': 'user123'}

        mock_user_doc = MagicMock()
        mock_user_doc.exists = False
        mock_db.collection.return_value.document.return_value.get.return_value = mock_user_doc

        response = available_crops(request)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, b'{"availableCrops": []}')

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db')
    def test_available_crops_empty_cart(self, mock_db, mock_verify_token):
        request = MagicMock()
        request.headers = {'Authorization': 'validtoken'}
        mock_verify_token.return_value = {'uid': 'user123'}

        mock_user_doc = MagicMock()
        mock_user_doc.exists = True
        mock_user_doc.to_dict.return_value = {'cart': []}
        mock_db.collection.return_value.document.return_value.get.return_value = mock_user_doc

        response = available_crops(request)
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, b'{"availableCrops": []}')

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db')
    def test_available_crops_with_items(self, mock_db, mock_verify_token):
        request = MagicMock()
        request.headers = {'Authorization': 'validtoken'}
        mock_verify_token.return_value = {'uid': 'user123'}

        # Mock user document with cart items
        mock_user_doc = MagicMock()
        mock_user_doc.exists = True
        mock_user_doc.to_dict.return_value = {'cart': ['crop1']}
        
        # Mock crop document
        mock_crop_doc = MagicMock()
        mock_crop_doc.exists = True
        mock_crop_doc.to_dict.return_value = {
            'cropName': 'Corn',
            'price': 100,
            'quantity': 50,
            'userId': 'farmer123',
            'imageURLs': ['image-url']
        }
        
        # Mock farmer document
        mock_farmer_doc = MagicMock()
        mock_farmer_doc.exists = True
        mock_farmer_doc.to_dict.return_value = {'name': 'Farmer Joe'}
        
        # Configure mocks to return different documents based on collection and ID
        def mock_collection_side_effect(collection_name):
            mock_coll = MagicMock()
            
            def mock_document_side_effect(doc_id):
                mock_doc = MagicMock()
                
                def mock_get_side_effect():
                    if collection_name == 'users':
                        if doc_id == 'user123':
                            return mock_user_doc
                        elif doc_id == 'farmer123':
                            return mock_farmer_doc
                    elif collection_name == 'crops' and doc_id == 'crop1':
                        return mock_crop_doc
                    return MagicMock()
                
                mock_doc.get.side_effect = mock_get_side_effect
                return mock_doc
            
            mock_coll.document.side_effect = mock_document_side_effect
            return mock_coll
        
        mock_db.collection.side_effect = mock_collection_side_effect
        
        response = available_crops(request)
        self.assertEqual(response.status_code, 200)
        self.assertIn(b'"cropName": "Corn"', response.content)
        self.assertIn(b'"farmer": "Farmer Joe"', response.content)

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db')
    def test_clear_cart_missing_token(self, mock_db, mock_verify_token):
        request = MagicMock()
        request.headers = {}
        response = clear_cart(request)
        
        self.assertEqual(response.status_code, 400)
        self.assertEqual(response.content, b'{"error": "Firebase token is missing"}')

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db')
    def test_clear_cart_invalid_token(self, mock_db, mock_verify_token):
        request = MagicMock()
        request.headers = {'Authorization': 'invalidtoken'}
        mock_verify_token.return_value = None

        response = clear_cart(request)

        self.assertEqual(response.status_code, 401)
        self.assertEqual(response.content, b'{"error": "Invalid Firebase token"}')

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db')
    def test_clear_cart_no_user_doc(self, mock_db, mock_verify_token):
        request = MagicMock()
        request.headers = {'Authorization': 'validtoken'}
        mock_verify_token.return_value = {'uid': 'user123'}

        mock_user_doc = MagicMock()
        mock_user_doc.exists = False
        mock_db.collection.return_value.document.return_value.get.return_value = mock_user_doc
        
        response = clear_cart(request)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, b'{"message": "Cart is already empty"}')

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db')
    def test_clear_cart_empty_cart(self, mock_db, mock_verify_token):
        request = MagicMock()
        request.headers = {'Authorization': 'validtoken'}
        mock_verify_token.return_value = {'uid': 'user123'}

        mock_user_doc = MagicMock()
        mock_user_doc.exists = True
        mock_user_doc.to_dict.return_value = {'cart': []}
        mock_db.collection.return_value.document.return_value.get.return_value = mock_user_doc

        response = clear_cart(request)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, b'{"message": "Cart is already empty"}')

    @patch('firebase.verify_firebase_token')
    @patch('firebase.db')
    def test_clear_cart_success(self, mock_db, mock_verify_token):
        request = MagicMock()
        request.headers = {'Authorization': 'validtoken'}
        mock_verify_token.return_value = {'uid': 'user123'}

        # Mock user document with cart items
        mock_user_doc = MagicMock()
        mock_user_doc.exists = True
        mock_user_doc.to_dict.return_value = {'cart': ['crop1']}
        
        # Mock user and crop references
        mock_user_ref = MagicMock()
        mock_crop_ref = MagicMock()
        
        # Mock crop document
        mock_crop_doc = MagicMock()
        mock_crop_doc.exists = True
        
        # Set up the collection chaining
        mock_db.collection.return_value.document.return_value.get.return_value = mock_user_doc
        
        # Configure mocks to handle different collection requests
        def mock_collection_side_effect(collection_name):
            mock_coll = MagicMock()
            
            def mock_document_side_effect(doc_id):
                if collection_name == 'users' and doc_id == 'user123':
                    return mock_user_ref
                elif collection_name == 'crops' and doc_id == 'crop1':
                    mock_crop_ref.get.return_value = mock_crop_doc
                    return mock_crop_ref
                return MagicMock()
            
            mock_coll.document.side_effect = mock_document_side_effect
            return mock_coll
        
        mock_db.collection.side_effect = mock_collection_side_effect
        mock_user_ref.get.return_value = mock_user_doc

        response = clear_cart(request)

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.content, b'{"message": "Cart cleared successfully"}')
        
        # Verify update calls were made
        mock_crop_ref.update.assert_called_with({"is_in_cart": False})
        mock_user_ref.update.assert_called_with({"cart": []})

if __name__ == '__main__':
    unittest.main()