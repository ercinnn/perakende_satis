// lib/models/company_model.dart
class Company {
  final String id;
  final String name;
  final String? taxNumber;
  final DateTime createdAt;

  Company({
    required this.id,
    required this.name,
    this.taxNumber,
    required this.createdAt,
  });

  factory Company.fromMap(Map<String, dynamic> map) {
    return Company(
      id: map['id'] as String,
      name: map['name'] as String,
      taxNumber: map['tax_number'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}