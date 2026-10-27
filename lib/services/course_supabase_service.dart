
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  // Mengambil seluruh data course.
  @override
  Future<List<Course>> getCourses() async {
    try {
      final data = await supabase
          .from('courses')
          .select()
          .order('id');

      return (data as List)
          .map(
            (e) => Course.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (e, stackTrace) {
      debugPrint('SUPABASE ERROR saat mengambil data: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // INSERT: Menambahkan course baru.
  @override
  Future<Course> createCourse(Course course) async {
    try {
      final row = await supabase
          .from('courses')
          .insert(course.toJson())
          .select()
          .single();

      return Course.fromJson(
        Map<String, dynamic>.from(row),
      );
    } catch (e, stackTrace) {
      debugPrint('SUPABASE ERROR saat menambah course: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // UPDATE: Mengubah course berdasarkan ID.
  @override
  Future<void> updateCourse(int id, Course course) async {
    try {
      await supabase
          .from('courses')
          .update(course.toJson())
          .eq('id', id);

      debugPrint('SUPABASE: Course dengan ID $id berhasil diperbarui.');
    } catch (e, stackTrace) {
      debugPrint('SUPABASE ERROR saat mengubah course: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // DELETE: Belum diimplementasikan pada tahap ini.
  @override
  Future<void> deleteCourse(int id) async {
    throw UnimplementedError(
      'Fitur delete course belum diimplementasikan.',
    );
  }
}
