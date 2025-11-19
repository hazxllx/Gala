import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:my_project/screens/models/establishment_data.dart';

class Step1ImagesType extends StatefulWidget {
  final EstablishmentData data;
  final VoidCallback onNext;

  const Step1ImagesType({
    super.key,
    required this.data,
    required this.onNext,
  });

  @override
  State<Step1ImagesType> createState() => _Step1ImagesTypeState();
}

class _Step1ImagesTypeState extends State<Step1ImagesType> {
  final ImagePicker _picker = ImagePicker();
  final List<String> _establishmentTypes = ['Cafe', 'Restaurant', 'Bar', 'Park'];
  final List<String> _cities = ['Naga City', 'Siruma', 'Pili', 'Caramoan', 'Pasacao', 'Tinambac'];

  final Color primaryColor = const Color(0xFF12397C);
  bool _isPickingImages = false;

  Future<void> _pickImages() async {
    if (_isPickingImages) return;

    setState(() {
      _isPickingImages = true;
    });

    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        // Check file sizes before adding
        List<File> validImages = [];
        for (var image in images) {
          File file = File(image.path);
          int fileSize = await file.length();
          
          // Check if file size is less than 5MB
          if (fileSize < 5 * 1024 * 1024) {
            validImages.add(file);
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${image.name} is too large (max 5MB)'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        }

        if (validImages.isNotEmpty) {
          setState(() {
            widget.data.images.addAll(validImages);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${validImages.length} image(s) added successfully'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking images: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      setState(() {
        _isPickingImages = false;
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      widget.data.images.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image removed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            "Upload Establishment Images",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "Please upload at least 1 picture and select establishment info.",
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          const Text(
            'Establishment Images',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Image Picker Section
          if (widget.data.images.isEmpty)
            GestureDetector(
              onTap: _isPickingImages ? null : _pickImages,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: _isPickingImages ? Colors.grey[200] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isPickingImages)
                      const CircularProgressIndicator()
                    else
                      Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      _isPickingImages ? 'Loading...' : 'Tap to select images',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (!_isPickingImages) ...[
                      const SizedBox(height: 4),
                      Text(
                        'You can select multiple images (max 5MB each)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.data.images.length + 1,
                    itemBuilder: (context, index) {
                      if (index == widget.data.images.length) {
                        return GestureDetector(
                          onTap: _isPickingImages ? null : _pickImages,
                          child: Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: _isPickingImages ? Colors.grey[200] : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!, width: 2),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isPickingImages)
                                  const SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: CircularProgressIndicator(strokeWidth: 3),
                                  )
                                else
                                  Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey[400]),
                                const SizedBox(height: 8),
                                Text(
                                  _isPickingImages ? 'Loading...' : 'Add More',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Container(
                        width: 150,
                        margin: const EdgeInsets.only(right: 12),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                widget.data.images[index],
                                width: 150,
                                height: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Center(
                                      child: Icon(Icons.error, color: Colors.red),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () => _removeImage(index),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                            // Image number badge
                            Positioned(
                              bottom: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.data.images.length} image(s) selected',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

          const SizedBox(height: 24),

          // Establishment Type Dropdown
          DropdownButtonFormField<String>(
            value: widget.data.type,
            decoration: InputDecoration(
              labelText: 'Establishment Type',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: _establishmentTypes.map((type) {
              return DropdownMenuItem(value: type, child: Text(type));
            }).toList(),
            onChanged: (value) => setState(() => widget.data.type = value!),
          ),

          const SizedBox(height: 20),

          // City Dropdown
          DropdownButtonFormField<String>(
            value: widget.data.city,
            decoration: InputDecoration(
              labelText: 'City',
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            items: _cities.map((city) {
              return DropdownMenuItem(value: city, child: Text(city));
            }).toList(),
            onChanged: (value) => setState(() => widget.data.city = value!),
          ),

          const SizedBox(height: 32),

          // Next Button
          ElevatedButton(
            onPressed: (widget.data.isStep1Valid() && !_isPickingImages) ? widget.onNext : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              disabledBackgroundColor: Colors.grey[300],
            ),
            child: const Text(
              'Next: Add Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
