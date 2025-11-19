import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:my_project/screens/models/establishment_data.dart';
import 'package:my_project/screens/map/map_picker_screen.dart'; // ✅ load your map picker

class Step2Details extends StatefulWidget {
  final EstablishmentData data;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2Details({
    super.key,
    required this.data,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step2Details> createState() => _Step2DetailsState();
}

class _Step2DetailsState extends State<Step2Details> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _descriptionController;

  final Color primaryColor = const Color(0xFF12397C);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.name);
    _addressController = TextEditingController(text: widget.data.address);
    _contactController = TextEditingController(text: widget.data.contactNumber);
    _descriptionController = TextEditingController(text: widget.data.description);
  }

  Future<void> _openMapPicker() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          initialPosition: LatLng(widget.data.latitude, widget.data.longitude),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        widget.data.address = result["address"];
        widget.data.latitude = result["lat"];
        widget.data.longitude = result["lng"];
        _addressController.text = widget.data.address;
      });
    }
  }

  void _saveAndNext() {
    if (_formKey.currentState!.validate()) {
      if (widget.data.latitude == 0 || widget.data.longitude == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select location on map")),
        );
        return;
      }

      widget.data.name = _nameController.text.trim();
      widget.data.address = _addressController.text.trim();
      widget.data.contactNumber = _contactController.text.trim();
      widget.data.description = _descriptionController.text.trim();

      widget.onNext();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Establishment Name',
                prefixIcon: const Icon(Icons.store),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Please enter establishment name' : null,
            ),
            const SizedBox(height: 20),

            // ✅ Click Address → Open Map Picker
            GestureDetector(
              onTap: _openMapPicker,
              child: AbsorbPointer(
                child: TextFormField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Complete Address (Tap to pin on map)',
                    prefixIcon: const Icon(Icons.location_pin),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Select location from map' : null,
                ),
              ),
            ),

            const SizedBox(height: 6),

            // ✅ Show Lat & Lng if selected
            if (widget.data.latitude != 0)
              Text(
                "📍 Lat: ${widget.data.latitude.toStringAsFixed(6)}, "
                "Lng: ${widget.data.longitude.toStringAsFixed(6)}",
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),

            const SizedBox(height: 20),

            TextFormField(
              controller: _contactController,
              decoration: InputDecoration(
                labelText: 'Contact Number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.phone,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Please enter contact number' : null,
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: const Icon(Icons.description),
                hintText: 'Tell us about your establishment',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Please enter description' : null,
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveAndNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Next: Add Transportation',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
