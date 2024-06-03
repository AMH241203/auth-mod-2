from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.template import loader
from .models import inventory, phone_info
from .forms import CombinedForm
from django.contrib.auth.decorators import login_required

@login_required
def create_view(request):
    context = {}

    form = CombinedForm(request.POST or None)
    if form.is_valid():
        form.save()

    context['form'] = form
    return render(request, 'phones/create.html', context)

@login_required
def list_view(request):
    # dictionary for initial data with 
    # field names as keys
    inventory_list = inventory.objects.select_related('phone').all()
    context = {
        'inventory_list': inventory_list
    }
    return render(request, "phones/inventoryTable.html", context)
    
    
