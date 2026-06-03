class ServiceRequestPet {
  final String id;
  final String name;
  final String species;
  final String breed;

  const ServiceRequestPet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
  });

  factory ServiceRequestPet.fromJson(Map<String, dynamic> json) {
    return ServiceRequestPet(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String,
    );
  }
}

class ServiceRequestUser {
  final String id;
  final String name;
  final String phone;

  const ServiceRequestUser({
    required this.id,
    required this.name,
    required this.phone,
  });

  factory ServiceRequestUser.fromJson(Map<String, dynamic> json) {
    return ServiceRequestUser(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
    );
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}

class ServiceRequestReview {
  final String id;
  final int rating;
  final String comment;

  const ServiceRequestReview({
    required this.id,
    required this.rating,
    required this.comment,
  });

  factory ServiceRequestReview.fromJson(Map<String, dynamic> json) {
    return ServiceRequestReview(
      id: json['id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String,
    );
  }
}

class ServiceRequest {
  final String id;
  final String petId;
  final String ownerId;
  final String? caregiverId;
  final String serviceType;
  final DateTime scheduledAt;
  final String meetingAddress;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;
  final ServiceRequestPet pet;
  final ServiceRequestUser owner;
  final ServiceRequestUser? caregiver;
  final ServiceRequestReview? review;

  const ServiceRequest({
    required this.id,
    required this.petId,
    required this.ownerId,
    this.caregiverId,
    required this.serviceType,
    required this.scheduledAt,
    required this.meetingAddress,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
    required this.pet,
    required this.owner,
    this.caregiver,
    this.review,
  });

  factory ServiceRequest.fromJson(Map<String, dynamic> json) {
    return ServiceRequest(
      id: json['id'] as String,
      petId: json['petId'] as String,
      ownerId: json['ownerId'] as String,
      caregiverId: json['caregiverId'] as String?,
      serviceType: json['serviceType'] as String,
      scheduledAt: DateTime.parse(json['scheduledAt'] as String),
      meetingAddress: json['meetingAddress'] as String,
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      pet: ServiceRequestPet.fromJson(json['pet'] as Map<String, dynamic>),
      owner: ServiceRequestUser.fromJson(json['owner'] as Map<String, dynamic>),
      caregiver: json['caregiver'] != null
          ? ServiceRequestUser.fromJson(json['caregiver'] as Map<String, dynamic>)
          : null,
      review: json['review'] != null
          ? ServiceRequestReview.fromJson(json['review'] as Map<String, dynamic>)
          : null,
    );
  }
}
