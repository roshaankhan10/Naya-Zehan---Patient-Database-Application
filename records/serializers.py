# records/serializers.py
from rest_framework import serializers
from .models import Patient, Admission

class PatientSerializer(serializers.ModelSerializer):
    class Meta:
        model = Patient
        fields = '__all__'

# class AdmissionSerializer(serializers.ModelSerializer):
#     class Meta:
#         model = Admission
#         fields = '__all__'

# records/serializers.py
class AdmissionSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source="patient.name", read_only=True)
    patient_hospital_id = serializers.CharField(source="patient.hospital_id", read_only=True)

    class Meta:
        model = Admission
        fields = [
            "patient",              # FK hospital_id
            "patient_hospital_id",  # hospital_id explicitly
            "patient_name",         # pulled from Patient
            "date_of_admission",
            "ward_no",
            "ref_source",
            "is_current",
        ]
