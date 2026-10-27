
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/course.dart';

class CourseApiService {
  CourseApiService(this.baseUrl);

  final String baseUrl;

  Future<List<Course>> getCourses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil course: HTTP ${response.statusCode}',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body) as List<dynamic>;

    return data.map((e) {
      final json = e as Map<String, dynamic>;

      // Pemetaan JSONPlaceholder ke model Course.
      return Course(
        id: json['id'] as int?,
        code: 'POST${json['id']}',
        title: json['title'] as String,
        credits: 2,
        status: 'planned',
      );
    }).toList();
  }
}
