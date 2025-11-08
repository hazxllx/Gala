import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Partner With Us',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color.fromARGB(255, 11, 113, 197),
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
                _buildStepIndicator(0, 'Images'),
                _buildStepLine(0),
                _buildStepIndicator(1, 'Details'),
                _buildStepLine(1),
                _buildStepIndicator(2, 'Hours & Routes'),
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
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isActive
                ? const Color.fromARGB(255, 11, 113, 197)
                : Colors.grey[300],
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
            color: isActive
                ? const Color.fromARGB(255, 11, 113, 197)
                : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    final isActive = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: isActive
            ? const Color.fromARGB(255, 11, 113, 197)
            : Colors.grey[300],
      ),
    );
  }
}
