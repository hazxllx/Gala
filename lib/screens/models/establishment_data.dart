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
  String email = '';
  String description = '';
  List<File> images = [];
  List<TransportationOption> transportOptions = [];
  List<BusinessHours> businessHours = [];

  // Map location support
  double latitude = 0.0;
  double longitude = 0.0;

  EstablishmentData() {
    // Initialize with default business hours
    final days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    businessHours = days
        .map((day) => BusinessHours(
              day: day,
              openTime: '9:00 AM',
              closeTime: '9:00 PM',
              isClosed: false,
            ))
        .toList();
  }

  // Getters for compatibility with partner_submission_page
  Map<String, String> get openingHours {
    Map<String, String> hours = {};
    for (var bh in businessHours) {
      if (bh.isClosed) {
        hours[bh.day] = 'Closed';
      } else {
        hours[bh.day] = '${bh.openTime} - ${bh.closeTime}';
      }
    }
    return hours;
  }

  List<String> get transportation {
    List<String> routes = [];
    for (var option in transportOptions) {
      String routeDescription = '';
      for (int i = 0; i < option.routes.length; i++) {
        var route = option.routes[i];
        if (i > 0) routeDescription += ' → ';
        routeDescription += '${route.mode} (${route.duration}, ${route.fare})';
      }
      if (option.generalNote != null && option.generalNote!.isNotEmpty) {
        routeDescription += ' - ${option.generalNote}';
      }
      routes.add(routeDescription);
    }
    return routes;
  }

  bool isStep1Valid() {
    return images.isNotEmpty && type.isNotEmpty && city.isNotEmpty;
  }

  bool isStep2Valid() {
    // Made email optional - only require if it's filled
    return name.isNotEmpty &&
        address.isNotEmpty &&
        contactNumber.isNotEmpty &&
        description.isNotEmpty &&
        latitude != 0.0 &&
        longitude != 0.0;
  }

  bool isStep3Valid() {
    return businessHours.isNotEmpty && transportOptions.isNotEmpty;
  }

  Map<String, dynamic> toMap(List<String> imageUrls, String ownerId, String ownerEmail) {
    return {
      'name': name,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'images': imageUrls,
      'description': description,
      'contactNumber': contactNumber,
      if (email.isNotEmpty) 'email': email, // Only add if filled
      'type': type,
      'transportation': transportOptions.map((opt) => opt.toMap()).toList(),
      'businessHours': businessHours.map((bh) => bh.toMap()).toList(),
      'openingHours': openingHours,
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'status': 'pending',
      'rating': 0.0,
      'reviewCount': 0,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}
