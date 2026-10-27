
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/course.dart';

class CourseApiService {
  CourseApiService(this.baseUrl);

  final String baseUrl;

  // HTTP GET: Mengambil daftar course.
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

      return Course(
        id: json['id'] as int?,
        code: 'POST${json['id']}',
        title: json['title'] as String,
        credits: 2,
        status: 'planned',
      );
    }).toList();
  }

  // HTTP POST: Membuat course baru.
  Future<Course> createCourse(Course course) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'code': course.code,
        'title': course.title,
        'credits': course.credits,
        'status': course.status,
      }),
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw Exception(
        'Gagal membuat course: HTTP ${response.statusCode}',
      );
    }

    final Map<String, dynamic> json =
        jsonDecode(response.body) as Map<String, dynamic>;

    return Course(
      id: json['id'] as int?,
      code: json['code'] as String? ?? course.code,
      title: json['title'] as String? ?? course.title,
      credits: json['credits'] as int? ?? course.credits,
      status: json['status'] as String? ?? course.status,
    );
  }

  // HTTP PUT: Memperbarui course.
  Future<void> updateCourse(int id, Course course) async {
    final response = await http.put(
      Uri.parse('$baseUrl/posts/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'id': id,
        'code': course.code,
        'title': course.title,
        'credits': course.credits,
        'status': course.status,
      }),
    );

    if (response.statusCode < 200 ||
        response.statusCode >= 300) {
      throw Exception(
        'Gagal memperbarui course: HTTP ${response.statusCode}',
      );
    }
  }
}
