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

from rest_framework.permissions import IsAuthenticated


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

class MeView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        return Response({
            'username': user.username,
            'is_staff': user.is_staff,
            'is_superuser': user.is_superuser,
        })
    
class PatientViewSet(viewsets.ModelViewSet):
    queryset = Patient.objects.all().order_by('id')
    serializer_class = PatientSerializer
    permission_classes = [IsAdminOrReadOnly]
    filter_backends = [filters.SearchFilter]
    search_fields = ['name', 'hospital_id', 'father_name', 'surname', 'nic', 'dob', 'age', 'sex', 'marital_status', 'religion', 'education', 'occupation', 'address']

# class AdmissionViewSet(viewsets.ModelViewSet):
#     queryset = Admission.objects.all()
#     serializer_class = AdmissionSerializer
#     # permission_classes = [IsAuthenticated]
#     permission_classes = [IsAdminOrReadOnly]  # Use the custom permission class

class AdmissionViewSet(viewsets.ModelViewSet):
    queryset = Admission.objects.all().order_by('-date_of_admission')
    serializer_class = AdmissionSerializer
    permission_classes = [IsAdminOrReadOnly]

    def get_queryset(self):
        queryset = Admission.objects.all().order_by('-date_of_admission')
        patient_id = self.request.query_params.get('patient')
        if patient_id:
            queryset = queryset.filter(patient_id=patient_id)
        return queryset

from django.http import HttpResponse

def home(request):
    return HttpResponse("Records API working")