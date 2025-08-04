from django.shortcuts import render

# Create your views here.
# records/views.py
from rest_framework import viewsets
from .models import Patient, Admission
from .serializers import PatientSerializer, AdmissionSerializer

class PatientViewSet(viewsets.ModelViewSet):
    queryset = Patient.objects.all()
    serializer_class = PatientSerializer

class AdmissionViewSet(viewsets.ModelViewSet):
    queryset = Admission.objects.all()
    serializer_class = AdmissionSerializer
