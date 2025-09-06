import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hour_entry.dart';

class StorageService {
  static const String _entriesKey = 'hour_entries';

  Future<void> saveEntry(HourEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getAllEntries();
    
    // Remove existing entry for same date and hour if exists
    entries.removeWhere((e) => e.date.day == entry.date.day && 
                             e.date.month == entry.date.month && 
                             e.date.year == entry.date.year && 
                             e.hour == entry.hour);
    
    // Add new entry
    entries.add(entry);
    
    // Convert to JSON strings
    final jsonEntries = entries.map((e) => jsonEncode(e.toJson())).toList();
    
    await prefs.setStringList(_entriesKey, jsonEntries);
  }

  Future<List<HourEntry>> getAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonEntries = prefs.getStringList(_entriesKey) ?? [];
    
    return jsonEntries.map((jsonString) {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return HourEntry.fromJson(json);
    }).toList();
  }

  Future<List<HourEntry>> getEntriesForDate(DateTime date) async {
    final allEntries = await getAllEntries();
    return allEntries.where((entry) =>
        entry.date.year == date.year &&
        entry.date.month == date.month &&
        entry.date.day == date.day).toList();
  }

  Future<HourEntry?> getEntryForHour(DateTime date, int hour) async {
    final entriesForDate = await getEntriesForDate(date);
    try {
      return entriesForDate.firstWhere((entry) => entry.hour == hour);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearAllEntries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_entriesKey);
  }
}
