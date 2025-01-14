// lib/models/profile.dart

class Profile {
  final String firstName;
  final String? lastName;
  final String phone;
  final String email;
  final List<Map<String, dynamic>> childDetails;

  Profile({
    required this.firstName,
    this.lastName,
    required this.phone,
    required this.email,
    required this.childDetails,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    try {
      // Access profile_data from top level data object
      final profileData = json['profile_data'];
      if (profileData == null) {
        throw Exception('Profile data is null');
      }

      // Access child_details from top level data object
      final List<dynamic> rawChildDetails = json['child_details'] ?? [];
      final childDetails = rawChildDetails.map((child) => 
        Map<String, dynamic>.from(child)
      ).toList();

      return Profile(
        firstName: profileData['first_name'] ?? '',
        lastName: profileData['last_name'],
        phone: profileData['phone'] ?? '',
        email: profileData['email'] ?? '',
        childDetails: childDetails,
      );
    } catch (e) {
      print('Error parsing profile data: $e');
      rethrow;
    }
  }
}