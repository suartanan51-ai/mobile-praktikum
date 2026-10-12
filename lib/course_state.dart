
import 'package:flutter/foundation.dart';

import 'models/course.dart';
import 'repositories/course_repository.dart';

class CourseState extends ChangeNotifier {
  final CourseRepository repository;

  CourseState(this.repository);

  final Set<String> favorites = {};
  List<Course> courses = [];

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadCourses() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      courses = await repository.getCourses();
    } catch (e) {
      errorMessage = 'Gagal memuat course: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  bool isFavorite(String code) {
    return favorites.contains(code);
  }

  void toggleFavorite(String code) {
    if (!favorites.add(code)) {
      favorites.remove(code);
    }

    notifyListeners();
  }

  List<Course> get favoriteCourses {
    return courses
        .where((course) => favorites.contains(course.code))
        .toList();
  }

  int get totalFavorites => favorites.length;
}
