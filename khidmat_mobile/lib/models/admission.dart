/// Typed model for Admission records.
class Admission {
  final int? id;
  final String patientHospitalId;
  final String? patientName;
  final String dateOfAdmission;
  final String wardNo;
  final String? refSource;
  final bool isCurrent;

  Admission({
    this.id,
    required this.patientHospitalId,
    this.patientName,
    required this.dateOfAdmission,
    required this.wardNo,
    this.refSource,
    this.isCurrent = false,
  });

  factory Admission.fromJson(Map<String, dynamic> json) {
    return Admission(
      id: json['id'] as int?,
      patientHospitalId:
          json['patient_hospital_id']?.toString() ?? json['patient']?.toString() ?? '',
      patientName: json['patient_name']?.toString(),
      dateOfAdmission: json['date_of_admission']?.toString() ?? '',
      wardNo: json['ward_no']?.toString() ?? '',
      refSource: json['ref_source']?.toString(),
      isCurrent: json['is_current'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient': patientHospitalId,
      'date_of_admission': dateOfAdmission,
      'ward_no': wardNo,
      'ref_source': refSource,
      'is_current': isCurrent,
    };
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(dateOfAdmission);
      return '${dt.day.toString().padLeft(2, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.year}';
    } catch (_) {
      return dateOfAdmission;
    }
  }
}
