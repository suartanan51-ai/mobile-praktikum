
import 'package:flutter/foundation.dart';

import '../models/course.dart';
import '../repositories/course_repository.dart';

class CourseProvider extends ChangeNotifier {
  final CourseRepository repository;

  CourseProvider(this.repository);

  List<Course> courses = [];
  bool isLoading = false;
  String? error;

  Future<void> loadCourses() async {
    // State loading
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // Mengambil data course dari repository
      courses = await repository.getCourses();
    } catch (e) {
      // State error
      error = e.toString();
    } finally {
      // Mengakhiri loading
      isLoading = false;
      notifyListeners();
    }
  }
}
