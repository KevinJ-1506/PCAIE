# Generated by Django 5.2.1 on 2025-05-18 01:58

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('vet', '0004_remove_mascota_chip_id_and_more'),
    ]

    operations = [
        migrations.AddField(
            model_name='mascota',
            name='chip_id',
            field=models.CharField(blank=True, max_length=50),
        ),
    ]
