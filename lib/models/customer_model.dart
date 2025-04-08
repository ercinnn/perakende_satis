// lib/models/customer_model.dart
class Customer {
  final String id;
  final String name;
  final String phone;
  final double totalPurchases;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.totalPurchases,
  });

  static List<Customer> dummyCustomers = [
    Customer(
      id: '1',
      name: 'Ahmet Yılmaz',
      phone: '0555 555 55 55',
      totalPurchases: 1250.50,
    ),
  ];
}