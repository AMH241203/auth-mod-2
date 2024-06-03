from django.contrib import admin
from django.urls import path
from . import views

urlpatterns = [
        path('', views.create_view, name='create_view'),
        path('inventory', views.list_view, name='list_view')
    ]