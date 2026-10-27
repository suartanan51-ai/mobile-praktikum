
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/course.dart';

class CourseApiService {
  CourseApiService(this.baseUrl);

  final String baseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<List<Course>> getCourses() async {
    final response = await http.get(_uri('/courses'));

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data Course: '
        '${response.statusCode} ${response.body}',
      );
    }

    final List<dynamic> data =
        jsonDecode(response.body) as List<dynamic>;

    return data.map((item) {
      final json = item as Map<String, dynamic>;

      return Course(
        id: (json['id'] as num?)?.toInt(),
        code: json['code'] as String,
        title: json['title'] as String,
        credits: (json['credits'] as num).toInt(),
        status: json['status'] as String? ?? 'planned',
      );
    }).toList();
  }

  Future<Course> createCourse(Course course) async {
    final response = await http.post(
      _uri('/courses'),
      headers: _headers,
      body: jsonEncode({
        'code': course.code,
        'title': course.title,
        'credits': course.credits,
        'status': course.status,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        'Gagal menambahkan Course: '
        '${response.statusCode} ${response.body}',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;

    return Course(
      id: (json['id'] as num?)?.toInt(),
      code: json['code'] as String? ?? course.code,
      title: json['title'] as String? ?? course.title,
      credits: (json['credits'] as num?)?.toInt() ?? course.credits,
      status: json['status'] as String? ?? course.status,
    );
  }

  Future<void> updateCourse(int id, Course course) async {
    final response = await http.put(
      _uri('/courses/$id'),
      headers: _headers,
      body: jsonEncode({
        'code': course.code,
        'title': course.title,
        'credits': course.credits,
        'status': course.status,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal memperbarui Course: '
        '${response.statusCode} ${response.body}',
      );
    }
  }

  Future<void> patchCourse(int id, Map<String, dynamic> changes) async {
    final response = await http.patch(
      _uri('/courses/$id'),
      headers: _headers,
      body: jsonEncode(changes),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengubah sebagian data Course: '
        '${response.statusCode} ${response.body}',
      );
    }
  }
  
Future<void> deleteCourse(int id) async {
  final response = await http.delete(
    Uri.parse('$baseUrl/courses/$id'),
  );

  if (response.statusCode < 200 || response.statusCode >= 300) {
    throw Exception(
      'Gagal menghapus Course: '
      '${response.statusCode} ${response.body}',
    );
  }
}

}
