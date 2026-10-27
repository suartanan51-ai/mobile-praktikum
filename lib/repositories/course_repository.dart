
import '../models/course.dart';
import '../services/course_api_service.dart';

class CourseRepository {
  final CourseApiService service;

  CourseRepository(this.service);

  // Mengambil daftar course melalui API service.
  Future<List<Course>> getCourses() async {
    return await service.getCourses();
  }

  // Membuat course baru melalui API service.
  Future<Course> createCourse(Course course) async {
    return await service.createCourse(course);
  }

  Future<void> updateCourse(int id, Course course) async {
    await service.updateCourse(id, course);
 }
}
