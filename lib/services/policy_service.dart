import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_markdown/flutter_markdown.dart';

class PolicyService {
  static Future<String> getPolicyContent(String type) async {
    final String url = type == 'terms' 
        ? 'https://dev.content.web.ableaura.com/api/parents-terms-and-condition'
        : 'https://dev.content.web.ableaura.com/api/parents-privacy-policy';

    try {
      final response = await http.get(Uri.parse(url));
      final data = jsonDecode(response.body);
      
      if (data['data'] != null && data['data']['content'] != null) {
        return data['data']['content'];
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      throw Exception('Failed to load policy content: $e');
    }
  }
}