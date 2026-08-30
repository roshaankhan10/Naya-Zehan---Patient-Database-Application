# records/serializers.py
from rest_framework import serializers
import re
from datetime import date
from .models import Patient, Admission
from django.contrib.auth.models import User
from django.contrib.auth.password_validation import validate_password


class StaffCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, validators=[validate_password])

    class Meta:
        model = User
        fields = ['username', 'email', 'password']

    def create(self, validated_data):
        # is_staff defaults to False -> read-only per IsAdminOrReadOnly
        user = User.objects.create_user(
            username=validated_data['username'],
            email=validated_data.get('email', ''),
            password=validated_data['password'],
        )
        return user

        
class PatientSerializer(serializers.ModelSerializer):
    id = serializers.IntegerField(read_only=True)
    hospital_id = serializers.CharField(max_length=20)
    name = serializers.CharField(max_length=255, min_length=2)
    father_name = serializers.CharField(max_length=100, allow_blank=True, required=False)
    surname = serializers.CharField(max_length=100, allow_blank=True, required=False)
    nic = serializers.CharField(max_length=25, allow_blank=True, required=False)
    dob = serializers.DateField(required=False, allow_null=True)
    # age = serializers.IntegerField(required=False, min_value=0, allow_null=True)
    age = serializers.CharField(max_length=10, allow_blank=True, required=False)
    sex = serializers.CharField(max_length=10, allow_blank=True, required=False)
    marital_status = serializers.CharField(max_length=20, allow_blank=True, required=False)
    religion = serializers.CharField(max_length=50, allow_blank=True, required=False)
    education = serializers.CharField(max_length=50, allow_blank=True, required=False)
    occupation = serializers.CharField(max_length=100, allow_blank=True, required=False)
    address = serializers.CharField(max_length=5000, allow_blank=True, required=False)

    def validate_nic(self, value):
        if value and len(value) > 25:
            raise serializers.ValidationError('NIC must be at most 25 characters.')
        return value

    def validate_dob(self, value):
        if value and value > date.today():
            raise serializers.ValidationError('Date of birth cannot be in the future.')
        return value

    # def validate_age(self, value):
    #     if value is not None and value < 0:
    #         raise serializers.ValidationError('Age must be a positive number.')
    #     return value

    class Meta:
        model = Patient
        fields = [
            'id',
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

class AdmissionSerializer(serializers.ModelSerializer):
    patient_name = serializers.CharField(source='patient.name', read_only=True)
    patient_hospital_id = serializers.CharField(source='patient.hospital_id', read_only=True)

    patient = serializers.PrimaryKeyRelatedField(queryset=Patient.objects.all())
    ward_no = serializers.CharField(max_length=10)
    ref_source = serializers.CharField(max_length=100, allow_blank=True, required=False)
    date_of_admission = serializers.DateField()
    is_current = serializers.BooleanField(default=False)
    id = serializers.IntegerField(read_only=True)
    patient_name = serializers.CharField(source='patient.name', read_only=True)
    patient_hospital_id = serializers.CharField(source='patient.hospital_id', read_only=True)

    def validate(self, data):
        # Note: discharge_date field doesn't exist in current model, so skipping that validation
        return data

    def validate_date_of_admission(self, value):
        if value > date.today():
            raise serializers.ValidationError('Admission date cannot be in the future.')
        return value

    class Meta:
        model = Admission
        fields = [
            'id',    
            'patient',
            'patient_hospital_id',
            'patient_name',
            'date_of_admission',
            'ward_no',
            'ref_source',
            'is_current',
        ]
