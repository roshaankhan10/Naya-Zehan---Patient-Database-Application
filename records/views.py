from django.shortcuts import render

# Create your views here.
# records/views.py
from rest_framework import viewsets

from records.permissions import IsAdminOrReadOnly
from .models import Patient, Admission
from .serializers import PatientSerializer, AdmissionSerializer
from rest_framework.permissions import IsAuthenticated
from rest_framework import filters
# records/views.py — add these imports and view
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import StaffCreateSerializer
from .permissions import IsAdminOrReadOnly

class StaffCreateView(APIView):
    permission_classes = [IsAdminOrReadOnly]  # write actions require is_staff/is_superuser

    def post(self, request):
        serializer = StaffCreateSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            return Response(
                {'id': user.id, 'username': user.username, 'is_staff': user.is_staff},
                status=status.HTTP_201_CREATED
            )
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class PatientViewSet(viewsets.ModelViewSet):
    queryset = Patient.objects.all()
    serializer_class = PatientSerializer
    permission_classes = [IsAdminOrReadOnly]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name', 'hospital_id', 'father_name', 'surname', 'nic', 'dob', 'age', 'sex', 'marital_status', 'religion', 'education', 'occupation', 'address']

class AdmissionViewSet(viewsets.ModelViewSet):
    queryset = Admission.objects.all()
    serializer_class = AdmissionSerializer
    # permission_classes = [IsAuthenticated]
    permission_classes = [IsAdminOrReadOnly]  # Use the custom permission class

from django.http import HttpResponse

def home(request):
    return HttpResponse("Records API working")