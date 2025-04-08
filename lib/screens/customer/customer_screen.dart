import 'package:flutter/material.dart';
import '../../models/customer_model.dart';

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Müşteri Yönetimi')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showAddCustomerDialog(context),
      ),
      body: ListView.builder(
        itemCount: Customer.dummyCustomers.length,
        itemBuilder: (context, index) {
          final customer = Customer.dummyCustomers[index];
          return ListTile(
            title: Text(customer.name),
            subtitle: Text(customer.phone),
            trailing: Text('${customer.totalPurchases.toStringAsFixed(2)} TL'),
          );
        },
      ),
    );
  }

  void _showAddCustomerDialog(BuildContext context) {
    // Müşteri ekleme dialog implementasyonu
  }
}