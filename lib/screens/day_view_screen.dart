import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hour_entry.dart';
import '../services/storage_service.dart';
import '../widgets/hour_tile.dart';

class DayViewScreen extends StatefulWidget {
  final DateTime selectedDate;

  const DayViewScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  State<DayViewScreen> createState() => _DayViewScreenState();
}

class _DayViewScreenState extends State<DayViewScreen> {
  final StorageService _storageService = StorageService();
  List<HourEntry> _entries = [];
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final entries = await _storageService.getEntriesForDate(widget.selectedDate);
    setState(() {
      _entries = entries;
    });
  }

  void _onEntryChanged(HourEntry entry) {
    setState(() {
      _entries.removeWhere((e) => e.hour == entry.hour);
      _entries.add(entry);
    });
  }

  Future<void> _clearAllEntries() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Entries'),
        content: Text(
          'Are you sure you want to clear all entries for ${DateFormat('MMMM d, y').format(widget.selectedDate)}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear entries for this date
      for (int hour = 0; hour < 24; hour++) {
        final emptyEntry = HourEntry(
          date: widget.selectedDate,
          hour: hour,
          activity: '',
        );
        await _storageService.saveEntry(emptyEntry);
      }
      
      // Reload entries
      await _loadEntries();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All entries cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('EEEE, MMMM d, y');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(dateFormatter.format(widget.selectedDate)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isEditMode ? Icons.done : Icons.edit),
            onPressed: _toggleEditMode,
            tooltip: _isEditMode ? 'Done' : 'Edit Mode',
          ),
          if (_isEditMode)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: _clearAllEntries,
              tooltip: 'Clear All',
              color: Colors.red,
            ),
        ],
      ),
      body: ListView.builder(
        itemCount: 24,
        itemBuilder: (context, index) {
          return HourTile(
            hour: index,
            date: widget.selectedDate,
            onEntryChanged: _onEntryChanged,
            isEditMode: _isEditMode,
          );
        },
      ),
    );
  }
}
