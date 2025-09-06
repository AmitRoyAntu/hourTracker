import 'package:flutter/material.dart';
import '../models/hour_entry.dart';
import '../services/storage_service.dart';

class HourTile extends StatefulWidget {
  final int hour;
  final DateTime date;
  final Function(HourEntry) onEntryChanged;
  final bool isEditMode;

  const HourTile({
    super.key,
    required this.hour,
    required this.date,
    required this.onEntryChanged,
    this.isEditMode = false,
  });

  @override
  State<HourTile> createState() => _HourTileState();
}

class _HourTileState extends State<HourTile> {
  final TextEditingController _controller = TextEditingController();
  final StorageService _storageService = StorageService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingEntry();
  }

  Future<void> _loadExistingEntry() async {
    final existingEntry = await _storageService.getEntryForHour(widget.date, widget.hour);
    if (existingEntry != null) {
      _controller.text = existingEntry.activity;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveEntry() async {
    final entry = HourEntry(
      date: widget.date,
      hour: widget.hour,
      activity: _controller.text.trim(),
    );
    await _storageService.saveEntry(entry);
    widget.onEntryChanged(entry);
  }

  Future<void> _clearEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Entry'),
        content: Text('Clear entry for ${_formatHour(widget.hour)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _controller.clear();
      await _saveEntry();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cleared entry for ${_formatHour(widget.hour)}'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            colorScheme.surface,
            colorScheme.surface.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 90,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  _formatHour(widget.hour),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _isLoading
                    ? Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _controller.text.isNotEmpty 
                                ? colorScheme.primary.withOpacity(0.3)
                                : colorScheme.outline.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            hintText: 'What did you do this hour?',
                            hintStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            suffixIcon: widget.isEditMode && _controller.text.isNotEmpty
                                ? Container(
                                    margin: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: colorScheme.error.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: colorScheme.error,
                                        size: 18,
                                      ),
                                      onPressed: _clearEntry,
                                      tooltip: 'Clear this entry',
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {}); // Rebuild to show/hide clear button
                            // Auto-save after a brief delay
                            Future.delayed(const Duration(milliseconds: 500), () {
                              _saveEntry();
                            });
                          },
                          onSubmitted: (value) {
                            _saveEntry();
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
