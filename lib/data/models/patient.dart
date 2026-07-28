import 'package:uuid/uuid.dart';

class Patient {
  final String id;
  final String name;
  final String phoneNumber;
  final int age;
  final String gender;
  final DateTime registeredDate;
  final String? notes;

  Patient({
    String? id,
    required this.name,
    required this.phoneNumber,
    required this.age,
    required this.gender,
    DateTime? registeredDate,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        registeredDate = registeredDate ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'age': age,
      'gender': gender,
      'registeredDate': registeredDate.toIso8601String(),
      'notes': notes,
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      age: json['age'] as int,
      gender: json['gender'] as String,
      registeredDate: DateTime.parse(json['registeredDate'] as String),
      notes: json['notes'] as String?,
    );
  }

  // Static validator for phone numbers
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleanPhone.length < 9 || cleanPhone.length > 15) {
      return 'Please enter a valid phone number (9-15 digits)';
    }
    if (!RegExp(r'^\+?[0-9]+$').hasMatch(cleanPhone)) {
      return 'Invalid characters in phone number';
    }
    return null;
  }
}
