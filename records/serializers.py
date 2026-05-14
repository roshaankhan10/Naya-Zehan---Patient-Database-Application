# records/serializers.py
from rest_framework import serializers
from .models import Patient, Admission

class PatientSerializer(serializers.ModelSerializer):
    hospital_id = serializers.CharField(max_length=20)
    name = serializers.CharField(max_length=100)
    father_name = serializers.CharField(max_length=100, allow_blank=True, required=False)
    surname = serializers.CharField(max_length=100, allow_blank=True, required=False)
    nic = serializers.CharField(max_length=25, allow_blank=True, required=False)
    dob = serializers.DateField(required=False, allow_null=True)
    age = serializers.IntegerField(required=False, min_value=0, allow_null=True)
    sex = serializers.CharField(max_length=10, allow_blank=True, required=False)
    marital_status = serializers.CharField(max_length=20, allow_blank=True, required=False)
    religion = serializers.CharField(max_length=50, allow_blank=True, required=False)
    education = serializers.CharField(max_length=50, allow_blank=True, required=False)
    occupation = serializers.CharField(max_length=100, allow_blank=True, required=False)
    address = serializers.CharField(allow_blank=True, required=False)

    class Meta:
        model = Patient
        fields = [
            'hospital_id',
            'name',
            'father_name',
            'surname',
            'nic',
            'dob',
            'age',
            'sex',
            'marital_status',
            'religion',
            'education',
            'occupation',
            'address',
        ]

    def validate_nic(self, value):
        if value and len(value) > 25:
            raise serializers.ValidationError('NIC must be at most 25 characters.')
        return value

    def validate_dob(self, value):
        from datetime import date
        if value and value > date.today():
            raise serializers.ValidationError('Date of birth cannot be in the future.')
        return value

    def validate_age(self, value):
        if value is not None and value < 0:
            raise serializers.ValidationError('Age must be a positive number.')
        return value

class AdmissionSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source='patient.name', read_only=True)
    patient_hospital_id = serializers.CharField(source='patient.hospital_id', read_only=True)

    patient = serializers.PrimaryKeyRelatedField(queryset=Patient.objects.all())
    ward_no = serializers.CharField(max_length=10)
    ref_source = serializers.CharField(max_length=100, allow_blank=True, required=False)
    date_of_admission = serializers.DateField()
    is_current = serializers.BooleanField(default=False)

    class Meta:
        model = Admission
        fields = [
            'patient',
            'patient_hospital_id',
            'patient_name',
            'date_of_admission',
            'ward_no',
            'ref_source',
            'is_current',
        ]

    def validate_date_of_admission(self, value):
        from datetime import date
        if value > date.today():
            raise serializers.ValidationError('Admission date cannot be in the future.')
        return value
