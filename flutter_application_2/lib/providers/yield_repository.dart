import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/yeild_record.dart';

class YieldRepository extends ChangeNotifier {
  static const _storageKey = 'yield_records';

  final List<YieldRecord> _records = [];

  List<YieldRecord> get records => _records;

  YieldRepository() {
    _loadFromStorage();
  }

  Future<void> addRecord(YieldRecord record) async {
    _records.add(record);
    await _saveToStorage();
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _records.map((r) => r.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final storedJson = prefs.getString(_storageKey);

    if (storedJson != null) {
      final List<dynamic> recordsJson = jsonDecode(storedJson);
      _records.clear();
      _records.addAll(
        recordsJson.map(
          (recordJson) => YieldRecord.fromJson(recordJson),
        ),
      );
      notifyListeners();
    }
  }

  /// Last 30 days
  List<YieldRecord> recentRecords() {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return _records.where((r) => r.date.isAfter(cutoff)).toList();
  }

  /// Same month last year
  List<YieldRecord> previousYearRecords() {
    final now = DateTime.now();
    return _records.where((r) =>
        r.date.year == now.year - 1 &&
        r.date.month == now.month).toList();
  }
}
