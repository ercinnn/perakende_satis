import 'package:flutter/material.dart';

class CustomDataTable extends StatelessWidget {
  final List<DataRow> rows;
  final List<String> columns;

  const CustomDataTable({
    super.key,
    required this.rows,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: columns.map((col) => DataColumn(label: Text(col))).toList(),
        rows: rows,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}