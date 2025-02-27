from django import forms
from django.core.exceptions import ValidationError

class CropListingForm(forms.Form):
    name = forms.CharField(max_length=100)
    description = forms.CharField(max_length=500)
    price = forms.DecimalField(max_digits=10, decimal_places=2)
    location = forms.CharField(max_length=200)
    quantity = forms.IntegerField()
    photos = forms.ImageField(required=False)
    harvest_date = forms.DateField()

    def clean_name(self):
        name = self.cleaned_data.get('name')
        if not name:
            raise ValidationError("Crop name is required.")
        return name

    def clean_price(self):
        price = self.cleaned_data.get('price')
        if price <= 0:
            raise ValidationError("Price should be greater than zero.")
        return price

    def clean_location(self):
        location = self.cleaned_data.get('location')
        if not location:
            raise ValidationError("Location is required.")
        return location

    def clean_quantity(self):
        quantity = self.cleaned_data.get('quantity')
        if quantity <= 0:
            raise ValidationError("Quantity should be greater than zero.")
        return quantity
