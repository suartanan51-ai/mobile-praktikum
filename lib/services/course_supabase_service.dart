
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/course.dart';
import 'course_data_source.dart';

class CourseSupabaseService implements CourseDataSource {
  final SupabaseClient supabase = Supabase.instance.client;

  // GET: Mengambil daftar course.
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
      debugPrint('SUPABASE ERROR GET: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // INSERT: Menambahkan course.
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
      debugPrint('SUPABASE ERROR INSERT: $e');
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

      debugPrint('SUPABASE: Course ID $id berhasil diubah.');
    } catch (e, stackTrace) {
      debugPrint('SUPABASE ERROR UPDATE: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  // DELETE: Menghapus course berdasarkan ID.
  @override
  Future<void> deleteCourse(int id) async {
    try {
      await supabase
          .from('courses')
          .delete()
          .eq('id', id);

      debugPrint('SUPABASE: Course ID $id berhasil dihapus.');
    } catch (e, stackTrace) {
      debugPrint('SUPABASE ERROR DELETE: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
