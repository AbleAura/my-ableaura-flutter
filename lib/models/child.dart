class Child {
  final int childId;
  final String uniqueId;
  final String name;

  Child({
    required this.childId,
    required this.uniqueId,
    required this.name,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      childId: json['id'],
      uniqueId: json['unique_id'],
      name: json['name'],
    );
  }

  // For storing in SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'uniqueId': uniqueId,
      'name': name,
    };
  }
}