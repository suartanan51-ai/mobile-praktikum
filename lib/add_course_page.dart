import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/course.dart';
import 'providers/course_provider.dart';

class AddCoursePage extends StatefulWidget {
  final Course? course;

  const AddCoursePage({
    super.key,
    this.course,
  });

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _titleController = TextEditingController();
  final _creditsController = TextEditingController();

  String _status = 'planned';

  bool get _isEditing => widget.course != null;

  @override
  void initState() {
    super.initState();

    final course = widget.course;

    if (course != null) {
      _codeController.text = course.code;
      _titleController.text = course.title;
      _creditsController.text = course.credits.toString();
      _status = course.status;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  Future<void> _saveCourse() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<CourseProvider>();

    final course = Course(
      id: widget.course?.id,
      code: _codeController.text.trim(),
      title: _titleController.text.trim(),
      credits: int.parse(_creditsController.text.trim()),
      status: _status,
    );

    try {
      if (_isEditing) {
        final id = widget.course!.id;

        if (id == null) {
          throw Exception('ID course tidak ditemukan.');
        }

        await provider.updateCourse(id, course);
      } else {
        await provider.createCourse(course);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Course berhasil diperbarui'
                : 'Course berhasil ditambahkan',
          ),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan course: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();
    final isSaving = provider.isSaving;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Course' : 'Tambah Course',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _codeController,
              readOnly: _isEditing,
              decoration: const InputDecoration(
                labelText: 'Code',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Code wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title wajib diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _creditsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Credits',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Credits wajib diisi';
                }

                final credits = int.tryParse(value.trim());

                if (credits == null || credits <= 0) {
                  return 'Credits harus berupa angka positif';
                }

                return null;
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'planned',
                  child: Text('Planned'),
                ),
                DropdownMenuItem(
                  value: 'active',
                  child: Text('Active'),
                ),
                DropdownMenuItem(
                  value: 'done',
                  child: Text('Done'),
                ),
              ],
              onChanged: isSaving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _status = value);
                      }
                    },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isSaving ? null : _saveCourse,
              child: isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      _isEditing
                          ? 'Simpan Perubahan'
                          : 'Simpan Course',
                    ),
            ),
          ],
        ),
      ),
    );
  }
}