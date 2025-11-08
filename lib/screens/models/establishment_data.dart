import 'dart:io';

class TransportationRoute {
  String mode;
  String duration;
  String fare;
  String? note;

  TransportationRoute({
    required this.mode,
    required this.duration,
    required this.fare,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'mode': mode,
      'duration': duration,
      'fare': fare,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}

class TransportationOption {
  List<TransportationRoute> routes;
  String? generalNote;

  TransportationOption({
    required this.routes,
    this.generalNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'routes': routes.map((r) => r.toMap()).toList(),
      if (generalNote != null && generalNote!.isNotEmpty) 'generalNote': generalNote,
    };
  }
}

class BusinessHours {
  String day;
  String openTime;
  String closeTime;
  bool isClosed;

  BusinessHours({
    required this.day,
    required this.openTime,
    required this.closeTime,
    this.isClosed = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }
}

class EstablishmentData {
  String type = 'Cafe';
  String city = 'Naga City';
  String name = '';
  String address = '';
  String contactNumber = '';
  String description = '';
  List<File> images = [];
  List<TransportationOption> transportOptions = [];
  List<BusinessHours> businessHours = [];

  EstablishmentData() {
    // Initialize with default business hours
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    businessHours = days.map((day) => BusinessHours(
      day: day,
      openTime: '9:00 AM',
      closeTime: '9:00 PM',
      isClosed: false,
    )).toList();
  }

  bool isStep1Valid() {
    return images.isNotEmpty && type.isNotEmpty && city.isNotEmpty;
  }

  bool isStep2Valid() {
    return name.isNotEmpty && address.isNotEmpty && contactNumber.isNotEmpty && description.isNotEmpty;
  }

  bool isStep3Valid() {
    return businessHours.isNotEmpty && transportOptions.isNotEmpty;
  }

  Map<String, dynamic> toMap(List<String> imageUrls, String ownerId, String ownerEmail) {
    return {
      'name': name,
      'address': address,
      'city': city,
      'imageUrls': imageUrls,
      'description': description,
      'contactNumber': contactNumber,
      'type': type,
      'transportation': transportOptions.map((opt) => opt.toMap()).toList(),
      'businessHours': businessHours.map((bh) => bh.toMap()).toList(),
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'status': 'pending',
    };
  }
}
