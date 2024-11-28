class ChildResponse {
  final bool success;
  final String message;
  final ChildData data;

  ChildResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ChildResponse.fromJson(Map<String, dynamic> json) {
    return ChildResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ChildData.fromJson(json['data']),
    );
  }

  get length => null;
}

class ChildData {
  final int childCount;
  final List<Child> childDetails;

  ChildData({
    required this.childCount,
    required this.childDetails,
  });

  factory ChildData.fromJson(Map<String, dynamic> json) {
    return ChildData(
      childCount: json['child_count'] ?? 0,
      childDetails: (json['child_details'] as List)
          .map((child) => Child.fromJson(child))
          .toList(),
    );
  }
}

class Child {
  final int childId;
  final String uniqueId;
  final String name;
  final String? idCard;

  Child({
    required this.childId,
    required this.uniqueId,
    required this.name,
    this.idCard,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      childId: json['id'],
      uniqueId: json['unique_id'],
      name: json['name'] ?? '',
      idCard: json['id_card'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'childId': childId,
      'uniqueId': uniqueId,
      'name': name,
      'idCard': idCard,
    };
  }
}