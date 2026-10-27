
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    try {
      debugPrint('SUPABASE: Mengambil data courses');

      final data = await supabase
          .from('courses')
          .select()
          .order('id');

      final courses = (data as List)
          .map(
            (e) => Course.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();

      debugPrint(
        'SUPABASE: Berhasil memuat ${courses.length} course',
      );

      return courses;
    } catch (e, stackTrace) {
      debugPrint('SUPABASE ERROR saat mengambil data: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // INSERT: Menambahkan course baru ke Supabase.
  @override
  Future<Course> createCourse(Course course) async {
    try {
      debugPrint('SUPABASE: Menambahkan course ${course.code}');

      final row = await supabase
          .from('courses')
          .insert(course.toJson())
          .select()
          .single();

      final newCourse = Course.fromJson(
        Map<String, dynamic>.from(row),
      );

      debugPrint(
        'SUPABASE: Course berhasil ditambahkan: '
        '${newCourse.code} - ${newCourse.title}',
      );

      return newCourse;
    } catch (e, stackTrace) {
      debugPrint('SUPABASE ERROR saat menambah course: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // Belum diimplementasikan pada tahap ini.
  @override
  Future<void> updateCourse(int id, Course course) async {
    throw UnimplementedError(
      'Fitur update course belum diimplementasikan.',
    );
  }

  // Belum diimplementasikan pada tahap ini.
  @override
  Future<void> deleteCourse(int id) async {
    throw UnimplementedError(
      'Fitur delete course belum diimplementasikan.',
    );
  }
}
