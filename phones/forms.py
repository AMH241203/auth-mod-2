from typing import Any
from django import forms
from .models import inventory, phone_info
from django.core.validators import MinValueValidator

class CombinedForm(forms.ModelForm):
    brand_name = forms.CharField(max_length=100)
    model = forms.CharField(max_length=100)
    build_date = forms.DateField(widget=forms.DateInput(attrs={'type': 'date'}))
    price = forms.IntegerField(validators=[MinValueValidator(1)])

    quantity = forms.IntegerField(validators=[MinValueValidator(1)])
    color = forms.ChoiceField(choices=[('red', 'Red'), ('black', 'Black'), ('green', 'Green')])

    class Meta:
        model = inventory
        fields = ['brand_name', 'model', 'build_date','color', 'price', 'quantity']
        labels = {'Brand Name': 'brand_name', 'Model': 'model', 'Build Date': 'build_date','Color':'color', 'Price': 'price', 'Quantity': 'quantity'}
        widgets = {'build_date': forms.DateInput(attrs={'type': 'date'})}

    def save(self, commit=True):
        phone_data = phone_info(
            brand_name=self.cleaned_data['brand_name'],
            model=self.cleaned_data['model'],
            build_date=self.cleaned_data['build_date'],
            price=self.cleaned_data['price']
        )
        phone_data.save()

        inventory_data = inventory(
            phone=phone_data,
            quantity=self.cleaned_data['quantity'],
            color=self.cleaned_data['color']
        )
        if commit:
            inventory_data.save()
        return inventory_data
