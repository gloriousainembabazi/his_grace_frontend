class Patient {
  final int id;
  final String fullName;
  final String patientId;
  final String phone;
  final int? age;
  final String gender;
  final String createdAt;

  Patient({
    required this.id,
    required this.fullName,
    required this.patientId,
    required this.phone,
    this.age,
    required this.gender,
    required this.createdAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      patientId: json['patient_id'] ?? '',
      phone: json['phone'] ?? '',
      age: json['age'],
      gender: json['gender'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'full_name': fullName,
        'phone': phone,
        'age': age,
        'gender': gender,
      };
}