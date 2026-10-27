
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  Future<List<Course>> getCourses() async {
    try {
      debugPrint('SUPABASE: Mulai mengambil data courses');

      final data = await supabase
          .from('courses')
          .select()
          .order('id');

      debugPrint('SUPABASE: Data diterima = $data');

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
      debugPrint('SUPABASE ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<Course> createCourse(Course course) async {
    throw UnimplementedError(
      'Fitur tambah course belum diimplementasikan.',
    );
  }

  @override
  Future<void> updateCourse(int id, Course course) async {
    throw UnimplementedError(
      'Fitur ubah course belum diimplementasikan.',
    );
  }

  @override
  Future<void> deleteCourse(int id) async {
    throw UnimplementedError(
      'Fitur hapus course belum diimplementasikan.',
    );
  }
}
