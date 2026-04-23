# records/serializers.py

from rest_framework import serializers
from .models import Patient, Admission


class PatientSerializer(serializers.ModelSerializer):
    """Flat patient serializer for list views and search results."""

    class Meta:
        model = Patient
        fields = '__all__'


class AdmissionSerializer(serializers.ModelSerializer):
    """Admission serializer with denormalized patient info."""
    patient_name = serializers.CharField(source="patient.name", read_only=True)
    patient_hospital_id = serializers.CharField(source="patient.hospital_id", read_only=True)

    class Meta:
        model = Admission
        fields = [
            "id",
            "patient",               # FK hospital_id (write)
            "patient_hospital_id",    # hospital_id (read)
            "patient_name",           # pulled from Patient (read)
            "date_of_admission",
            "ward_no",
            "ref_source",
            "is_current",
        ]


class PatientWithAdmissionsSerializer(serializers.ModelSerializer):
    """
    Patient serializer with nested admission history.
    Used for detail views to show full patient profile.
    """
    admissions = AdmissionSerializer(
        source='admission_set',
        many=True,
        read_only=True
    )

    class Meta:
        model = Patient
        fields = [
            'hospital_id', 'name', 'father_name', 'surname',
            'nic', 'dob', 'age', 'sex', 'marital_status',
            'religion', 'education', 'occupation', 'address',
            'admissions',
        ]
