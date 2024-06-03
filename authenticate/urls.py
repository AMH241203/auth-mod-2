from django.contrib import admin
from django.urls import path
from phones import views
import phones
from . import views

urlpatterns = [
        path('', views.login_user, name='login_user'),
        path('home', views.home, name='home'),
        path('phone', phones.views.create_view, name='create_view'),
        path('logout', views.logout_user, name='logout_user'),
    ]