# records/views.py

from django.db.models import Q
from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework.filters import SearchFilter, OrderingFilter

from .models import Patient, Admission
from .serializers import (
    PatientSerializer,
    PatientWithAdmissionsSerializer,
    AdmissionSerializer,
)


class PatientViewSet(viewsets.ModelViewSet):
    """
    CRUD + multi-parameter search for Patient records.

    List:   GET  /api/patients/
    Detail: GET  /api/patients/{hospital_id}/
    Search: GET  /api/patients/search/?hospital_id=&name=&father_name=&surname=

    Supports pagination (50 per page by default).
    """
    queryset = Patient.objects.all().order_by('hospital_id')
    serializer_class = PatientSerializer
    permission_classes = [IsAuthenticated]
    filter_backends = [SearchFilter, OrderingFilter]
    search_fields = ['hospital_id', 'name', 'father_name', 'surname']
    ordering_fields = ['hospital_id', 'name', 'age']

    def get_serializer_class(self):
        """Use nested serializer for detail view to include admissions."""
        if self.action == 'retrieve':
            return PatientWithAdmissionsSerializer
        return PatientSerializer

    @action(detail=False, methods=['get'], url_path='search')
    def search(self, request):
        """
        Multi-parameter patient search.

        Query params (all optional, combined with AND):
          - hospital_id : exact or prefix match
          - name        : case-insensitive contains
          - father_name : case-insensitive contains
          - surname     : case-insensitive contains
          - nic         : exact match
        """
        queryset = Patient.objects.all()

        hospital_id = request.query_params.get('hospital_id', '').strip()
        name = request.query_params.get('name', '').strip()
        father_name = request.query_params.get('father_name', '').strip()
        surname = request.query_params.get('surname', '').strip()
        nic = request.query_params.get('nic', '').strip()

        if hospital_id:
            queryset = queryset.filter(hospital_id__istartswith=hospital_id)
        if name:
            queryset = queryset.filter(name__icontains=name)
        if father_name:
            queryset = queryset.filter(father_name__icontains=father_name)
        if surname:
            queryset = queryset.filter(surname__icontains=surname)
        if nic:
            queryset = queryset.filter(nic=nic)

        # If no filters provided, return empty to avoid dumping entire DB
        if not any([hospital_id, name, father_name, surname, nic]):
            return Response(
                {"detail": "Provide at least one search parameter."},
                status=status.HTTP_400_BAD_REQUEST
            )

        queryset = queryset.order_by('hospital_id')
        page = self.paginate_queryset(queryset)
        if page is not None:
            serializer = PatientSerializer(page, many=True)
            return self.get_paginated_response(serializer.data)

        serializer = PatientSerializer(queryset, many=True)
        return Response(serializer.data)


class AdmissionViewSet(viewsets.ModelViewSet):
    """
    CRUD for Admission records.
    Supports filtering by patient hospital_id via query param.
    """
    queryset = Admission.objects.all().order_by('-date_of_admission')
    serializer_class = AdmissionSerializer
    permission_classes = [IsAuthenticated]

    def get_queryset(self):
        queryset = super().get_queryset()
        patient_id = self.request.query_params.get('patient', None)
        if patient_id:
            queryset = queryset.filter(patient__hospital_id=patient_id)
        return queryset