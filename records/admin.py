from django.contrib import admin

# Register your models here.
from django.contrib import admin
from .models import Patient, Admission

@admin.register(Patient)
class PatientAdmin(admin.ModelAdmin):
    list_display = ('hospital_id', 'name', 'age', 'sex')
    search_fields = ('hospital_id', 'name', 'nic')
    list_filter = ('sex', 'religion', 'marital_status')

@admin.register(Admission)
class AdmissionAdmin(admin.ModelAdmin):
    list_display = ('patient', 'date_of_admission', 'ward_no', 'is_current')
    search_fields = ('patient__hospital_id',)
    list_filter = ('ward_no', 'is_current')
