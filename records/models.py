# # from django.db import models

# # Create your models here.
# # records/models.py

# from django.db import models

# class Patient(models.Model):
#     hospital_id = models.CharField(max_length=20, primary_key=True)
#     name = models.CharField(max_length=100)
#     father_name = models.CharField(max_length=100, blank=True, null=True)
#     surname = models.CharField(max_length=100, blank=True, null=True)
#     nic = models.CharField(max_length=25, blank=True, null=True)
#     dob = models.DateField(blank=True, null=True)
#     age = models.IntegerField(blank=True, null=True)
#     sex = models.CharField(max_length=10, blank=True, null=True)
#     marital_status = models.CharField(max_length=20, blank=True, null=True)
#     religion = models.CharField(max_length=50, blank=True, null=True)
#     education = models.CharField(max_length=50, blank=True, null=True)
#     occupation = models.CharField(max_length=100, blank=True, null=True)
#     address = models.TextField(blank=True, null=True)

#     def __str__(self):
#         return f"{self.hospital_id} - {self.name}"


# class Admission(models.Model):
#     patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
#     date_of_admission = models.DateField()
#     ward_no = models.CharField(max_length=10)
#     ref_source = models.CharField(max_length=100, blank=True, null=True)
#     is_current = models.BooleanField(default=False)

#     def __str__(self):
#         return f"{self.patient.hospital_id} @ {self.date_of_admission}"

# records/models.py

from django.db import models


class Patient(models.Model):
    # hospital_id = models.CharField(max_length=20, blank=True, null=True, db_index=True)
    # hospital_id = models.CharField(max_length=20, primary_key=False, default='')
    hospital_id = models.CharField(max_length=20, blank=True, null=True, db_index=True)
    name = models.CharField(max_length=200, blank=True, null=True)
    father_name = models.CharField(max_length=100, blank=True, null=True)
    surname = models.CharField(max_length=100, blank=True, null=True)
    nic = models.CharField(max_length=25, blank=True, null=True)
    dob = models.DateField(blank=True, null=True)
    age = models.CharField(max_length=10, blank=True, null=True)  # stored as-is e.g. "28.Y"
    sex = models.CharField(max_length=10, blank=True, null=True)
    marital_status = models.CharField(max_length=20, blank=True, null=True)
    religion = models.CharField(max_length=50, blank=True, null=True)
    education = models.CharField(max_length=50, blank=True, null=True)
    occupation = models.CharField(max_length=100, blank=True, null=True)
    address = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"{self.hospital_id or 'N/A'} - {self.name or 'Unknown'}"


class Admission(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE, null=True, blank=True)
    hospital_id_ref = models.CharField(max_length=20, blank=True, null=True)  # raw H_ID_NO for linking
    date_of_admission = models.DateField(blank=True, null=True)
    ward_no = models.CharField(max_length=10, blank=True, null=True)
    ref_source = models.CharField(max_length=100, blank=True, null=True)
    is_current = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.hospital_id_ref} @ {self.date_of_admission}"