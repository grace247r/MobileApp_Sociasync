class UserProfile {
  UserProfile({
    required this.name,
    required this.gender,
    this.dateOfBirth,
    required this.region,
  });

  final String name;
  final String gender;
  final DateTime? dateOfBirth;
  final String region;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: (json['name'] ?? '') as String,
      gender: (json['gender'] ?? '') as String,
      dateOfBirth:
          json['date_of_birth'] == null ||
              (json['date_of_birth'] as String).isEmpty
          ? null
          : DateTime.tryParse(json['date_of_birth'] as String),
      region: (json['region'] ?? '') as String,
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T').first,
      'region': region,
    };
  }
}
