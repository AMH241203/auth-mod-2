from django.shortcuts import render, redirect
from django.contrib.auth import authenticate, login, logout
from django.contrib import messages
from django.http import HttpResponse
from django.template import loader
from django.contrib.auth.decorators import login_required



def login_user(request):
    if request.method == 'POST':
        username = request.POST["username"]
        password = request.POST["password"]
        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            return redirect('create_view')
        else:
            messages.success(request, ('There was an error in your username or password.'))
            return redirect('login_user')
    else:
        return render(request, 'authenticate/login.html', {})


@login_required
def logout_user(request):
    if request.method == 'POST' or request.method == 'GET':
        logout(request)
        messages.success(request, ('You have been logged out.'))
        return redirect('login_user')
    else:
        return HttpResponse('Method not allowed')
        
def home(request):
    template = loader.get_template('home.html')
    context = {
        'username': request.user.username if request.user.is_authenticated else 'Guest'
    }
    return HttpResponse(template.render(context, request))
