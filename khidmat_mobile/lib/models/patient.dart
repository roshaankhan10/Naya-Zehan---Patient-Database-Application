/// Typed model for Patient records.
class Patient {
  final String hospitalId;
  final String name;
  final String? fatherName;
  final String? surname;
  final String? nic;
  final String? dob;
  final int? age;
  final String? sex;
  final String? maritalStatus;
  final String? religion;
  final String? education;
  final String? occupation;
  final String? address;
  final List<Map<String, dynamic>>? admissions;

  Patient({
    required this.hospitalId,
    required this.name,
    this.fatherName,
    this.surname,
    this.nic,
    this.dob,
    this.age,
    this.sex,
    this.maritalStatus,
    this.religion,
    this.education,
    this.occupation,
    this.address,
    this.admissions,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      hospitalId: json['hospital_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      fatherName: json['father_name']?.toString(),
      surname: json['surname']?.toString(),
      nic: json['nic']?.toString(),
      dob: json['dob']?.toString(),
      age: json['age'] is int
          ? json['age']
          : int.tryParse(json['age']?.toString() ?? ''),
      sex: json['sex']?.toString(),
      maritalStatus: json['marital_status']?.toString(),
      religion: json['religion']?.toString(),
      education: json['education']?.toString(),
      occupation: json['occupation']?.toString(),
      address: json['address']?.toString(),
      admissions: json['admissions'] != null
          ? List<Map<String, dynamic>>.from(json['admissions'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hospital_id': hospitalId,
      'name': name,
      'father_name': fatherName,
      'surname': surname,
      'nic': nic,
      'dob': dob,
      'age': age,
      'sex': sex,
      'marital_status': maritalStatus,
      'religion': religion,
      'education': education,
      'occupation': occupation,
      'address': address,
    };
  }

  /// Returns a copy with updated fields.
  Patient copyWith({
    String? hospitalId,
    String? name,
    String? fatherName,
    String? surname,
    String? nic,
    String? dob,
    int? age,
    String? sex,
    String? maritalStatus,
    String? religion,
    String? education,
    String? occupation,
    String? address,
    List<Map<String, dynamic>>? admissions,
  }) {
    return Patient(
      hospitalId: hospitalId ?? this.hospitalId,
      name: name ?? this.name,
      fatherName: fatherName ?? this.fatherName,
      surname: surname ?? this.surname,
      nic: nic ?? this.nic,
      dob: dob ?? this.dob,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      religion: religion ?? this.religion,
      education: education ?? this.education,
      occupation: occupation ?? this.occupation,
      address: address ?? this.address,
      admissions: admissions ?? this.admissions,
    );
  }
}
