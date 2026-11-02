import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/yield_repository.dart';
import '../models/yeild_record.dart';
import '../services/api_client.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  final _titleController = TextEditingController(text: "Yield rec-1");
  final _kgController = TextEditingController(text: "320");
  final _acreController = TextEditingController(text: "3");

  DateTime selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _kgController.dispose();
    _acreController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    final title = _titleController.text.trim();
    final kg = double.tryParse(_kgController.text) ?? 0;
    final acre = double.tryParse(_acreController.text) ?? 1;

    if (kg <= 0 || acre <= 0) return;

    final record = YieldRecord(
      title: title,
      date: selectedDate,
      kilograms: kg,
      acres: acre,
    );

    await context.read<YieldRepository>().addRecord(record);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Yield record saved")),
    );

    final apiClient = context.read<ApiClient>();
    if (apiClient.isAuthenticated) {
      try {
        await apiClient.createYieldRecord(record);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Yield record synchronized")),
        );
      } catch (error) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Saved locally; synchronization failed: $error")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String currentDate =
        DateFormat('MMM dd, yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 20,
              right: 12,
              bottom: 24,
            ),
            decoration: const BoxDecoration(
              color: Color(0xFF1E4F9B),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Yield Record",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            "Date: $currentDate",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: _saveRecord,
                  icon: const Icon(Icons.check_circle,
                      color: Colors.white, size: 34),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _titleController,
                    label: "Title",
                    icon: Icons.edit_note,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _kgController,
                          label: "Kilograms",
                          icon: Icons.scale_outlined,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          suffix: "kg",
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          controller: _acreController,
                          label: "Acre",
                          icon: Icons.landscape_outlined,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          suffix: "ac",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    tileColor: Colors.white,
                    leading:
                        const Icon(Icons.date_range, color: Color(0xFF1E4F9B)),
                    title: Text("Select Date: $currentDate"),
                    trailing: const Icon(Icons.edit_calendar),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );

                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                  ),

                  const SizedBox(height: 48),

                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        _titleController.clear();
                        _kgController.clear();
                        _acreController.clear();
                      },
                      icon: const Icon(Icons.delete_sweep_outlined,
                          color: Colors.redAccent),
                      label: const Text(
                        "Discard This Record",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF1E4F9B)),
        suffixText: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide:
              const BorderSide(color: Color(0xFF1E4F9B), width: 1.5),
        ),
      ),
    );
  }
}
