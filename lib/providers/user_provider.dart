import 'package:flutter/foundation.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  List<String> _children = [];

  String? get userId => _userId;
  List<String> get children => _children;

  void setUser(String userId, List<String> children) {
    _userId = userId;
    _children = children;
    notifyListeners();
  }

  void clearUser() {
    _userId = null;
    _children.clear();
    notifyListeners();
  }
}