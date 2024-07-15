from django.db import models

# Create your models here.

class phone_info(models.Model):
    brand_name = models.CharField(max_length=100)
    model = models.CharField(max_length=100)
    build_date = models.DateField()
    price = models.PositiveIntegerField()
    last_modified = models.DateTimeField(auto_now_add = True)
    created_at = models.DateTimeField(auto_now_add = True)

class inventory(models.Model):
    phone = models.ForeignKey(phone_info, on_delete=models.CASCADE)
    quantity = models.PositiveIntegerField()
    color = models.CharField(max_length=100, choices=[('red', 'Red'), ('black', 'Black'), ('green', 'Green')])

    def __str__(self):
        return f"{self.phone.brand_name} - {self.color}"
