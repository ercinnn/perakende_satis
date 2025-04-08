import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({super.key});

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _selectedParentId;

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return AlertDialog(
      title: const Text('Yeni Kategori Ekle'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Kategori Adı'),
              validator: (value) => value!.isEmpty ? 'Zorunlu alan' : null,
            ),
            DropdownButtonFormField<String>(
              value: _selectedParentId,
              decoration: const InputDecoration(labelText: 'Üst Kategori (isteğe bağlı)'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Ana Kategori')),
                ...categoryProvider.categories
                    .where((c) => c.parentId == null)
                    .map((category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        )),
              ],
              onChanged: (value) => setState(() {
                _selectedParentId = value;
              }),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveCategory,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState!.validate()) {
      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        parentId: _selectedParentId,
      );

      await Provider.of<CategoryProvider>(context, listen: false)
          .addCategory(newCategory);

      if (!mounted) return;
      Navigator.pop(context);
    }
  }
}
