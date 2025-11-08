import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_project/screens/models/establishment_data.dart';

class Step3HoursTransportation extends StatefulWidget {
  final EstablishmentData data;
  final VoidCallback onBack;

  const Step3HoursTransportation({
    super.key,
    required this.data,
    required this.onBack,
  });

  @override
  State<Step3HoursTransportation> createState() => _Step3HoursTransportationState();
}

class _Step3HoursTransportationState extends State<Step3HoursTransportation> {
  bool _isSubmitting = false;
  bool _showAllDays = false;

  final List<String> _presetOptions = [
    'Open Daily',
    'Closed Sundays',
    'Weekdays Only',
    'Weekends Only',
  ];
  String _selectedPreset = 'Open Daily';
  String _openTime = '9:00 AM';
  String _closeTime = '9:00 PM';

  @override
  void initState() {
    super.initState();
    _applyPreset();
  }

  void _applyPreset() {
    setState(() {
      for (var i = 0; i < widget.data.businessHours.length; i++) {
        final day = widget.data.businessHours[i];
        switch (_selectedPreset) {
          case 'Open Daily':
            day.isClosed = false;
            day.openTime = _openTime;
            day.closeTime = _closeTime;
            break;
          case 'Closed Sundays':
            if (day.day == 'Sunday') {
              day.isClosed = true;
            } else {
              day.isClosed = false;
              day.openTime = _openTime;
              day.closeTime = _closeTime;
            }
            break;
          case 'Weekdays Only':
            if (day.day == 'Saturday' || day.day == 'Sunday') {
              day.isClosed = true;
            } else {
              day.isClosed = false;
              day.openTime = _openTime;
              day.closeTime = _closeTime;
            }
            break;
          case 'Weekends Only':
            if (day.day == 'Saturday' || day.day == 'Sunday') {
              day.isClosed = false;
              day.openTime = _openTime;
              day.closeTime = _closeTime;
            } else {
              day.isClosed = true;
            }
            break;
        }
      }
    });
  }

  Future<void> _selectTime(int index, bool isOpenTime) async {
    final bh = widget.data.businessHours[index];
    final currentTime = isOpenTime ? bh.openTime : bh.closeTime;
    final parts = currentTime.split(':');
    final hourPart = parts[0].trim();
    final minutePart = parts[1].trim();

    final hour = int.parse(hourPart.replaceAll(RegExp(r'[^0-9]'), ''));
    final minute = int.parse(minutePart.split(' ')[0]);
    final isPM = currentTime.contains('PM');
    final initialTime = TimeOfDay(
      hour: isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour),
      minute: minute,
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      setState(() {
        final formattedTime = picked.format(context);
        if (isOpenTime) {
          bh.openTime = formattedTime;
        } else {
          bh.closeTime = formattedTime;
        }
      });
    }
  }

  void _addTransportOption() {
    showDialog(
      context: context,
      builder: (context) => _AddTransportDialog(
        onAdd: (option) {
          setState(() {
            widget.data.transportOptions.add(option);
          });
        },
      ),
    );
  }

  void _editTransportOption(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddTransportDialog(
        existingOption: widget.data.transportOptions[index],
        onAdd: (option) {
          setState(() {
            widget.data.transportOptions[index] = option;
          });
        },
      ),
    );
  }

  Future<List<String>> _uploadImages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    List<String> imageUrls = [];
    for (int i = 0; i < widget.data.images.length; i++) {
      try {
        final fileName = '${user.uid}_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        final ref = FirebaseStorage.instance
            .ref()
            .child('establishment_images')
            .child(fileName);
        await ref.putFile(widget.data.images[i]);
        final downloadUrl = await ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      } catch (e) {
        debugPrint('Error uploading image $i: $e');
      }
    }
    return imageUrls;
  }

  Future<void> _submitEstablishment() async {
    if (!widget.data.isStep3Valid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one transportation route'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not logged in');
      final imageUrls = await _uploadImages();
      if (imageUrls.isEmpty) throw Exception('Failed to upload images');
      final data = widget.data.toMap(imageUrls, user.uid, user.email ?? '');
      data['submittedAt'] = FieldValue.serverTimestamp();
      await FirebaseFirestore.instance
          .collection('establishment_submissions')
          .add(data);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Submission successful! Awaiting review.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: const Color.fromARGB(255, 11, 113, 197),
                onPressed: widget.onBack,
                tooltip: 'Back',
              ),
              const SizedBox(width: 8),
              const Text(
                "Hours & Transportation",
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 11, 113, 197),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            "Business Hours",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Setup',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedPreset,
                  decoration: InputDecoration(
                    labelText: 'Operating Days',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _presetOptions.map((option) {
                    return DropdownMenuItem(value: option, child: Text(option));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPreset = value!;
                      _applyPreset();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(0, true),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Open Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(_openTime, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const Icon(Icons.access_time, color: Color.fromARGB(255, 11, 113, 197)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTime(0, false),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Close Time', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  Text(_closeTime, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const Icon(Icons.access_time, color: Color.fromARGB(255, 11, 113, 197)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _showAllDays = !_showAllDays;
              });
            },
            icon: Icon(_showAllDays ? Icons.expand_less : Icons.expand_more),
            label: Text(_showAllDays ? 'Hide individual days' : 'Customize individual days'),
            style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 11, 113, 197),
            ),
          ),
          if (_showAllDays) ...[
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.data.businessHours.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final businessHour = widget.data.businessHours[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 85,
                        child: Text(
                          businessHour.day,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: businessHour.isClosed
                            ? const Text(
                                'Closed',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              )
                            : Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => _selectTime(index, true),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            businessHour.openTime,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.access_time, size: 16, color: Color.fromARGB(255, 11, 113, 197)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 2),
                                    child: Text('—'),
                                  ),
                                  GestureDetector(
                                    onTap: () => _selectTime(index, false),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey[300]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Text(
                                            businessHour.closeTime,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.access_time, size: 16, color: Color.fromARGB(255, 11, 113, 197)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      Switch(
                        value: !businessHour.isClosed,
                        onChanged: (value) {
                          setState(() => businessHour.isClosed = !value);
                        },
                        activeColor: const Color.fromARGB(255, 11, 113, 197),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transportation Routes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton.icon(
                onPressed: _addTransportOption,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Add Route'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 11, 113, 197),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.data.transportOptions.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Add transportation routes to help visitors reach your establishment. You can add multiple routes with connecting rides.',
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.data.transportOptions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final option = widget.data.transportOptions[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Route ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  color: const Color.fromARGB(255, 11, 113, 197),
                                  onPressed: () => _editTransportOption(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20),
                                  color: Colors.red,
                                  onPressed: () {
                                    setState(() {
                                      widget.data.transportOptions.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey[300]),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: option.routes.length,
                        separatorBuilder: (context, routeIndex) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              const SizedBox(width: 24),
                              Icon(Icons.arrow_downward, size: 20, color: Colors.grey[400]),
                            ],
                          ),
                        ),
                        itemBuilder: (context, routeIndex) {
                          final route = option.routes[routeIndex];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(255, 11, 113, 197).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.directions_bus,
                                    color: Color.fromARGB(255, 11, 113, 197),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        route.mode,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${route.duration} • ${route.fare}',
                                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                      ),
                                      if (route.note != null && route.note!.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          route.note!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (option.generalNote != null && option.generalNote!.isNotEmpty) ...[
                        Divider(height: 1, color: Colors.grey[300]),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  option.generalNote!,
                                  style: TextStyle(fontSize: 12, color: Colors.grey[700], fontStyle: FontStyle.italic),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Color.fromARGB(255, 11, 113, 197)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color.fromARGB(255, 11, 113, 197)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitEstablishment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 11, 113, 197),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit for Review',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Your submission will be reviewed by our team within 2-3 business days.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

class _AddTransportDialog extends StatefulWidget {
  final Function(TransportationOption) onAdd;
  final TransportationOption? existingOption;

  const _AddTransportDialog({
    required this.onAdd,
    this.existingOption,
  });

  @override
  State<_AddTransportDialog> createState() => _AddTransportDialogState();
}

class _AddTransportDialogState extends State<_AddTransportDialog> {
  final List<TransportationRoute> _routes = [];
  final _generalNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingOption != null) {
      _routes.addAll(widget.existingOption!.routes);
      _generalNoteController.text = widget.existingOption!.generalNote ?? '';
    }
  }

  @override
  void dispose() {
    _generalNoteController.dispose();
    super.dispose();
  }

  void _addRoute() {
    showDialog(
      context: context,
      builder: (context) {
        final durationController = TextEditingController();
        final fareController = TextEditingController();
        final noteController = TextEditingController();
        String selectedMode = 'Tricycle';
        final modes = ['Tricycle', 'Jeepney', 'Bike', 'Walking', 'Car', 'Bus', 'Van'];

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Transport Step'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedMode,
                      decoration: const InputDecoration(
                        labelText: 'Mode',
                        border: OutlineInputBorder(),
                      ),
                      items: modes.map((mode) {
                        return DropdownMenuItem(value: mode, child: Text(mode));
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() => selectedMode = value!);
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration',
                        hintText: 'e.g., 15 minutes',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: fareController,
                      decoration: const InputDecoration(
                        labelText: 'Fare',
                        hintText: 'e.g., ₱15 or Free',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        hintText: 'e.g., Tell driver to drop at...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (durationController.text.isNotEmpty && fareController.text.isNotEmpty) {
                      setState(() {
                        _routes.add(
                          TransportationRoute(
                            mode: selectedMode,
                            duration: durationController.text.trim(),
                            fare: fareController.text.trim(),
                            note: noteController.text.trim().isEmpty
                                ? null
                                : noteController.text.trim(),
                          ),
                        );
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingOption == null ? 'Add Transportation Route' : 'Edit Transportation Route'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transport Steps',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextButton.icon(
                    onPressed: _addRoute,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Step'),
                  ),
                ],
              ),
              if (_routes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      'No transport steps added yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _routes.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final route = _routes[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(route.mode),
                      subtitle: Text('${route.duration} • ${route.fare}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _routes.removeAt(index);
                          });
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
              TextField(
                controller: _generalNoteController,
                decoration: const InputDecoration(
                  labelText: 'General Note (Optional)',
                  hintText: 'Additional instructions for this route',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _routes.isEmpty
              ? null
              : () {
                  widget.onAdd(
                    TransportationOption(
                      routes: _routes,
                      generalNote: _generalNoteController.text.trim().isEmpty
                          ? null
                          : _generalNoteController.text.trim(),
                    ),
                  );
                  Navigator.pop(context);
                },
          child: const Text('Save Route'),
        ),
      ],
    );
  }
}
