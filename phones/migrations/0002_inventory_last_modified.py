# Generated by Django 5.0.6 on 2024-05-21 07:03

import django.utils.timezone
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("phones", "0001_initial"),
    ]

    operations = [
        migrations.AddField(
            model_name="inventory",
            name="last_modified",
            field=models.DateTimeField(
                auto_now_add=True, default=django.utils.timezone.now
            ),
            preserve_default=False,
        ),
    ]
