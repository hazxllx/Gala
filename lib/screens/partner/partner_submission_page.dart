import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import 'dart:convert';
import 'package:my_project/screens/models/establishment_data.dart';
import 'package:my_project/screens/partner/step1_images_type.dart';
import 'package:my_project/screens/partner/step2_details.dart';
import 'package:my_project/screens/partner/step3_hours_transportation.dart';

class PartnerSubmissionPage extends StatefulWidget {
  const PartnerSubmissionPage({super.key});

  @override
  State<PartnerSubmissionPage> createState() => _PartnerSubmissionPageState();
}

class _PartnerSubmissionPageState extends State<PartnerSubmissionPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final EstablishmentData _establishmentData = EstablishmentData();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Convert images to Base64 strings (store in Firestore)
  Future<List<String>> _convertImagesToBase64(List<File> images) async {
    List<String> base64Images = [];
    
    try {
      for (int i = 0; i < images.length; i++) {
        debugPrint('Converting image ${i + 1}/${images.length} to Base64...');
        
        final bytes = await images[i].readAsBytes();
        final base64 = base64Encode(bytes);
        base64Images.add(base64);
        
        debugPrint('✅ Image ${i + 1} converted (${bytes.length} bytes)');
      }
      
      return base64Images;
    } catch (e) {
      debugPrint('❌ Error converting images: $e');
      throw Exception('Failed to process images: $e');
    }
  }

  // Submit establishment to Firestore (WITHOUT Firebase Storage)
  Future<void> _submitEstablishment() async {
    // Check if user is logged in FIRST
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showErrorSnackbar('❌ Please log in first before submitting');
      return;
    }

    debugPrint('✅ User authenticated: ${user.email}');

    // Validate all steps
    if (!_establishmentData.isStep1Valid()) {
      _showErrorSnackbar('❌ Please complete step 1 (Images & Type)');
      return;
    }

    if (!_establishmentData.isStep2Valid()) {
      _showErrorSnackbar('❌ Please complete step 2 (Details)');
      return;
    }

    if (!_establishmentData.isStep3Valid()) {
      _showErrorSnackbar('❌ Please complete step 3 (Hours & Transportation)');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      _showUploadingDialog();

      debugPrint('🚀 Starting submission process...');
      
      // Convert images to Base64
      debugPrint('📸 Processing ${_establishmentData.images.length} images...');
      List<String> base64Images = await _convertImagesToBase64(_establishmentData.images);
      
      if (mounted) Navigator.pop(context);

      // Prepare establishment data
      debugPrint('📝 Preparing establishment data...');
      
      final Map<String, dynamic> establishmentMap = {
        'name': _establishmentData.name,
        'type': _establishmentData.type,
        'city': _establishmentData.city,
        'description': _establishmentData.description,
        'contactNumber': _establishmentData.contactNumber,
        'address': _establishmentData.address,
        'latitude': _establishmentData.latitude,
        'longitude': _establishmentData.longitude,
        'images': base64Images,
        'imageCount': base64Images.length,
        'businessHours': _establishmentData.businessHours
            .map((bh) => {
                  'day': bh.day,
                  'openTime': bh.openTime,
                  'closeTime': bh.closeTime,
                  'isClosed': bh.isClosed,
                })
            .toList(),
        'transportOptions': _establishmentData.transportOptions
            .map((to) => {
                  'routes': to.routes
                      .map((r) => {
                            'mode': r.mode,
                            'duration': r.duration,
                            'fare': r.fare,
                            'note': r.note,
                          })
                      .toList(),
                  'generalNote': to.generalNote,
                })
            .toList(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'rating': 0.0,
        'reviewCount': 0,
        'ownerId': user.uid,
        'ownerEmail': user.email ?? 'unknown@email.com',
      };

      if (_establishmentData.email.isNotEmpty) {
        establishmentMap['email'] = _establishmentData.email;
      }

      // Save to Firestore
      debugPrint('💾 Saving to Firestore...');
      
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('establishment_submissions')
          .add(establishmentMap);

      debugPrint('✅ Establishment saved with ID: ${docRef.id}');

      _showSuccessDialog();

    } on FirebaseException catch (e) {
      if (mounted) {
        try {
          Navigator.pop(context);
        } catch (_) {}
      }
      debugPrint('❌ Firestore Error: ${e.code}');
      debugPrint('Message: ${e.message}');
      _showErrorSnackbar('Error: ${e.message}');
      
    } catch (e) {
      if (mounted) {
        try {
          Navigator.pop(context);
        } catch (_) {}
      }
      debugPrint('❌ Error: $e');
      _showErrorSnackbar(e.toString());
      
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showUploadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF12397C)),
              ),
              const SizedBox(height: 24),
              Text(
                'Processing submission...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please keep the app open',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(32),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF12397C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Color(0xFF12397C),
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'Success!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF12397C),
              ),
            ),
            const SizedBox(height: 16),
            
            // Message (removed first sentence)
            Text(
              'Our team will review your submission within 2-3 business days. You will receive an email notification once it\'s approved.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 32),
            
            // OK Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF12397C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(seconds: 6),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'DISMISS',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF12397C);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Partner With Us',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                _buildStepIndicator(0, 'Images', primaryColor),
                _buildStepLine(0, primaryColor),
                _buildStepIndicator(1, 'Details', primaryColor),
                _buildStepLine(1, primaryColor),
                _buildStepIndicator(2, 'Hours & Routes', primaryColor),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                Step1ImagesType(
                  data: _establishmentData,
                  onNext: _nextStep,
                ),
                Step2Details(
                  data: _establishmentData,
                  onNext: _nextStep,
                  onBack: _previousStep,
                ),
                Step3HoursTransportation(
                  data: _establishmentData,
                  onBack: _previousStep,
                  onSubmit: _submitEstablishment,
                  isSubmitting: _isSubmitting,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, Color primaryColor) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive ? primaryColor : Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? primaryColor : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step, Color primaryColor) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive ? primaryColor : Colors.grey[300],
      ),
    );
  }
}
