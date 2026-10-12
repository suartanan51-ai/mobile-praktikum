
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../course_state.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Favorites'),
      ),
      body: Consumer<CourseState>(
        builder: (context, state, child) {
          final courses = state.favoriteCourses;

          if (courses.isEmpty) {
            return const Center(
              child: Text('Belum ada course favorit'),
            );
          }

          return ListView.separated(
            itemCount: courses.length,
            separatorBuilder: (_, _) =>
                const Divider(height: 1),
            itemBuilder: (context, index) {
              final course = courses[index];

              return ListTile(
                leading: const Icon(Icons.book),
                title: Text(course.title),
                subtitle: Text(
                  '${course.code} • ${course.credits} SKS',
                ),
                trailing: IconButton(
                  tooltip: 'Hapus dari favorit',
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
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
