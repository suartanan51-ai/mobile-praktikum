
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../course_state.dart';
import 'favorites_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final state = context.read<CourseState>();

      if (state.courses.isEmpty && !state.isLoading) {
        state.loadCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Courses'),
        actions: [
          Consumer<CourseState>(
            builder: (context, state, child) {
              return IconButton(
                tooltip: 'Course Favorites',
                icon: Badge(
                  isLabelVisible: state.totalFavorites > 0,
                  label: Text('${state.totalFavorites}'),
                  child: const Icon(Icons.favorite),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FavoritesPage(),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<CourseState>(
        builder: (context, state, child) {
          if (state.isLoading && state.courses.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state.errorMessage != null &&
              state.courses.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.errorMessage!),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: state.loadCourses,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          if (state.courses.isEmpty) {
            return const Center(
              child: Text('Belum ada course'),
            );
          }

          return ListView.separated(
            itemCount: state.courses.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final course = state.courses[index];
              final favorite =
                  state.isFavorite(course.code);

              return ListTile(
                leading: const Icon(Icons.book),
                title: Text(course.title),
                subtitle: Text(
                  '${course.code} • ${course.credits} SKS',
                ),
                trailing: IconButton(
                  tooltip: favorite
                      ? 'Hapus dari favorit'
                      : 'Tambahkan ke favorit',
                  icon: Icon(
                    favorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: favorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    state.toggleFavorite(course.code);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
