import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:provider/provider.dart';

import 'course_state.dart';

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );

  return jsonDecode(jsonString) as Map<String, dynamic>;
}

void main() {
  runApp(
    ChangeNotifierProvider<CourseState>(
      create: (_) => CourseState(),
      child: const CourseExplorerApp(),
    ),
  );
}
class CourseExplorerApp extends StatelessWidget {
  const CourseExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Course Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int selectedIndex = 0;
  bool isSubmitting = false;

  final nameController = TextEditingController();
  final nimController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final hobbyController = TextEditingController();
  final skillController = TextEditingController();

  final GlobalKey<FormState> feedbackFormKey =
      GlobalKey<FormState>();

  final TextEditingController feedbackNameController =
      TextEditingController();

  final TextEditingController feedbackNimController =
      TextEditingController();

  final TextEditingController commentController =
      TextEditingController();

  final List<String> skills = [
    'Dart',
    'Flutter',
    'Git',
    'GitHub',
    'UI Design',
    'Firebase',
  ];

  Future<void> submitFeedback() async {
    if (!feedbackFormKey.currentState!.validate()) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text(
            'Apakah Anda yakin ingin mengirim feedback?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    setState(() {
      isSubmitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil disimpan'),
      ),
    );

    commentController.clear();
  }

  @override
  void dispose() {
    nameController.dispose();
    nimController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    hobbyController.dispose();
    skillController.dispose();
    feedbackNameController.dispose();
    feedbackNimController.dispose();
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: loadStudentData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Course Explorer'),
            ),
            body: Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(
              child: Text('Data tidak tersedia'),
            ),
          );
        }

        final student =
            snapshot.data!['student']
                as Map<String, dynamic>;

        final courses =
            snapshot.data!['courses']
                as List<dynamic>;

        if (nameController.text.isEmpty) {
          nameController.text =
              student['name'] as String;
        }

        if (nimController.text.isEmpty) {
          nimController.text =
              student['nim'] as String;
        }

        if (feedbackNameController.text.isEmpty) {
          feedbackNameController.text =
              student['name'] as String;
        }

        if (feedbackNimController.text.isEmpty) {
          feedbackNimController.text =
              student['nim'] as String;
        }

        final pages = [
          HomePage(
            student: student,
            courses: courses,
            skills: skills,
          ),
          CoursesPage(
            student: student,
            courses: courses,
          ),
          ProfilePage(
            student: student,
            nameController: nameController,
            nimController: nimController,
            emailController: emailController,
            phoneController: phoneController,
            addressController: addressController,
            hobbyController: hobbyController,
            skillController: skillController,
            feedbackFormKey: feedbackFormKey,
            feedbackNameController:
                feedbackNameController,
            feedbackNimController:
                feedbackNimController,
            commentController: commentController,
            submitFeedback: submitFeedback,
            isSubmitting: isSubmitting,
          ),
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 840) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Course Explorer'),
                  actions: [
                    IconButton(
                      tooltip: 'Debugging Challenge',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DebuggingPage(
                              studentName:
                                  student['name']
                                      as String,
                              studentId:
                                  student['nim']
                                      as String,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.bug_report,
                      ),
                    ),
                  ],
                ),
                body: pages[selectedIndex],
                bottomNavigationBar: NavigationBar(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      selectedIndex = index;
                    });
                  },
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(
                        Icons.home_outlined,
                      ),
                      selectedIcon: Icon(
                        Icons.home,
                      ),
                      label: 'Home',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.menu_book_outlined,
                      ),
                      selectedIcon: Icon(
                        Icons.menu_book,
                      ),
                      label: 'Courses',
                    ),
                    NavigationDestination(
                      icon: Icon(
                        Icons.person_outline,
                      ),
                      selectedIcon: Icon(
                        Icons.person,
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              );
            }

            return Scaffold(
              appBar: AppBar(
                title: const Text('Course Explorer'),
                actions: [
                  IconButton(
                    tooltip: 'Debugging Challenge',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DebuggingPage(
                            studentName:
                                student['name']
                                    as String,
                            studentId:
                                student['nim']
                                    as String,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.bug_report,
                    ),
                  ),
                ],
              ),
              body: Row(
                children: [
                  NavigationRail(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: (index) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    labelType:
                        NavigationRailLabelType.all,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(
                          Icons.home_outlined,
                        ),
                        selectedIcon: Icon(
                          Icons.home,
                        ),
                        label: Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(
                          Icons.menu_book_outlined,
                        ),
                        selectedIcon: Icon(
                          Icons.menu_book,
                        ),
                        label: Text('Courses'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(
                          Icons.person_outline,
                        ),
                        selectedIcon: Icon(
                          Icons.person,
                        ),
                        label: Text('Profile'),
                      ),
                    ],
                  ),
                  const VerticalDivider(
                    width: 1,
                  ),
                  Expanded(
                    child: pages[selectedIndex],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  final Map<String, dynamic> student;
  final List<dynamic> courses;
  final List<String> skills;

  const HomePage({
    super.key,
    required this.student,
    required this.courses,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final orientation =
        MediaQuery.of(context).orientation;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          Widget responsiveLayout;

          if (constraints.maxWidth < 600) {
            responsiveLayout = CompactLayout(
              name: student['name'] as String,
              nim: student['nim'] as String,
            );
          } else if (constraints.maxWidth < 840) {
            responsiveLayout = MediumLayout(
              name: student['name'] as String,
              nim: student['nim'] as String,
            );
          } else {
            responsiveLayout = ExpandedLayout(
              name: student['name'] as String,
              nim: student['nim'] as String,
            );
          }

          return Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              ProfileHeader(
                name: student['name'] as String,
                nim: student['nim'] as String,
              ),
              const SizedBox(height: 16),
              responsiveLayout,
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Layar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Nama: ${student['name']}',
                      ),
                      Text(
                        'NIM: ${student['nim']}',
                      ),
                      Text(
                        'Width: ${size.width.toStringAsFixed(0)}',
                      ),
                      Text(
                        'Height: ${size.height.toStringAsFixed(0)}',
                      ),
                      Text(
                        'Orientation: $orientation',
                      ),
                      Text(
                        'Layout: ${size.width < 600 ? 'Compact' : 'Wide'}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Expanded dan Flexible',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(),
                      ),
                      child: const Text(
                        'Panel A',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 100,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(),
                      ),
                      child: const Text(
                        'Panel B',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const FlexiblePanel(),
              const SizedBox(height: 16),
              const Text(
                'Skills',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: skills
                    .map(
                      (skill) => Chip(
                        label: Text(skill),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ringkasan Course',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      title: 'Total',
                      value: '${courses.length}',
                      icon: Icons.menu_book,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SummaryCard(
                      title: 'Selesai',
                      value:
                          '${courses.where((course) => course['status'] == 'done').length}',
                      icon: Icons.check_circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SummaryCard(
                      title: 'Aktif',
                      value:
                          '${courses.where((course) => course['status'] == 'active').length}',
                      icon: Icons.play_circle,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class CoursesPage extends StatefulWidget {
  final Map<String, dynamic> student;
  final List<dynamic> courses;

  const CoursesPage({
    super.key,
    required this.student,
    required this.courses,
  });

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  void showCourseInfo(Map<String, dynamic> course) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(course['title'] as String),
          content: Text(
            'Kode: ${course['code']}\n'
            'SKS: ${course['credits']}\n'
            'Status: ${course['status']}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> openCourse(Map<String, dynamic> course) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailPage(
          course: course,
          name: widget.student['name'] as String,
          nim: widget.student['nim'] as String,
        ),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      final courseState = context.read<CourseState>();
      final code = course['code'] as String;

      if (!courseState.isFavorite(code)) {
        courseState.toggleFavorite(code);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${course['title']} dipilih sebagai favorit.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 600;

        final crossAxisCount = constraints.maxWidth >= 840
            ? 3
            : constraints.maxWidth >= 600
                ? 2
                : 1;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(
                name: widget.student['name'] as String,
                nim: widget.student['nim'] as String,
              ),
              const SizedBox(height: 16),
              const Text(
                'Daftar Course',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const FavoriteCount(),
              const SizedBox(height: 12),
              if (isCompact)
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.courses.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final course =
                        widget.courses[index] as Map<String, dynamic>;

                    return CourseCard(
                      course: course,
                      onLongPress: () => showCourseInfo(course),
                      onTap: () => openCourse(course),
                    );
                  },
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: widget.courses.length,
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio:
                        constraints.maxWidth >= 840 ? 1.35 : 1.5,
                  ),
                  itemBuilder: (context, index) {
                    final course =
                        widget.courses[index] as Map<String, dynamic>;

                    return CourseCard(
                      course: course,
                      onLongPress: () => showCourseInfo(course),
                      onTap: () => openCourse(course),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

class FavoriteCount extends StatelessWidget {
  const FavoriteCount({super.key});

  @override
  Widget build(BuildContext context) {
    final courseState = context.watch<CourseState>();

    return Text(
      'Total Favorit: ${courseState.totalFavorites}',
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  final VoidCallback onLongPress;
  final VoidCallback onTap;

  const CourseCard({
    super.key,
    required this.course,
    required this.onLongPress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final code = course['code'] as String;

    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        course['title'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Consumer<CourseState>(
                      builder: (context, courseState, child) {
                        final isFavorite =
                            courseState.isFavorite(code);

                        return IconButton(
                          tooltip: isFavorite
                              ? 'Hapus dari favorit'
                              : 'Tambahkan ke favorit',
                          onPressed: () {
                            context
                                .read<CourseState>()
                                .toggleFavorite(code);
                          },
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isFavorite ? Colors.red : null,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Kode: ${course['code']}'),
                Text('SKS: ${course['credits']}'),
                const SizedBox(height: 8),
                Chip(
                  label: Text(course['status'] as String),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CourseDetailPage extends StatefulWidget {
  final Map<String, dynamic> course;
  final String name;
  final String nim;

  const CourseDetailPage({
    super.key,
    required this.course,
    required this.name,
    required this.nim,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool showDetail = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Detail'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.course['title'] as String,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (showDetail) ...[
                      Text(
                        'Kode: ${widget.course['code']}',
                      ),
                      Text(
                        'SKS: ${widget.course['credits']}',
                      ),
                      Text(
                        'Status: ${widget.course['status']}',
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          showDetail = !showDetail;
                        });
                      },
                      icon: Icon(
                        showDetail
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      label: Text(
                        showDetail
                            ? 'Sembunyikan Detail'
                            : 'Tampilkan Detail',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Mahasiswa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Nama: ${widget.name}'),
                    Text('NIM: ${widget.nim}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },
                icon: const Icon(
                  Icons.favorite,
                ),
                label: const Text(
                  'Pilih / Favorite',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class ProfilePage extends StatelessWidget {
  final Map<String, dynamic> student;

  final TextEditingController nameController;
  final TextEditingController nimController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController hobbyController;
  final TextEditingController skillController;

  final GlobalKey<FormState> feedbackFormKey;
  final TextEditingController feedbackNameController;
  final TextEditingController feedbackNimController;
  final TextEditingController commentController;

  final Future<void> Function() submitFeedback;
  final bool isSubmitting;

  const ProfilePage({
    super.key,
    required this.student,
    required this.nameController,
    required this.nimController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.hobbyController,
    required this.skillController,
    required this.feedbackFormKey,
    required this.feedbackNameController,
    required this.feedbackNimController,
    required this.commentController,
    required this.submitFeedback,
    required this.isSubmitting,
  });

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border:
              const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          ProfileHeader(
            name: student['name'] as String,
            nim: student['nim'] as String,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  buildTextField(
                    label: 'Nama',
                    controller: nameController,
                  ),
                  buildTextField(
                    label: 'NIM',
                    controller: nimController,
                  ),
                  buildTextField(
                    label: 'Email',
                    controller: emailController,
                  ),
                  buildTextField(
                    label: 'Nomor HP',
                    controller: phoneController,
                  ),
                  buildTextField(
                    label: 'Alamat',
                    controller: addressController,
                    maxLines: 2,
                  ),
                  buildTextField(
                    label: 'Hobi',
                    controller: hobbyController,
                  ),
                  buildTextField(
                    label: 'Skill Utama',
                    controller: skillController,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: feedbackFormKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Form Feedback',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller:
                          feedbackNameController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Nama',
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller:
                          feedbackNimController,
                      decoration:
                          const InputDecoration(
                        labelText: 'NIM',
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'NIM wajib diisi';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller:
                          commentController,
                      maxLines: 4,
                      decoration:
                          const InputDecoration(
                        labelText: 'Komentar',
                        hintText:
                            'Masukkan komentar minimal 5 karakter',
                        border:
                            OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Komentar wajib diisi';
                        }

                        if (value.trim().length <
                            5) {
                          return 'Komentar minimal 5 karakter';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : submitFeedback,
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.send,
                              ),
                        label: Text(
                          isSubmitting
                              ? 'Mengirim...'
                              : 'Kirim Feedback',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final String name;
  final String nim;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.nim,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundImage: AssetImage(
                'assets/images/profile.jpg',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('NIM: $nim'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const SummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            Text(title),
          ],
        ),
      ),
    );
  }
}

class FlexiblePanel extends StatelessWidget {
  const FlexiblePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Flexible(
              flex: 2,
              child: Container(
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(),
                ),
                child: const Text(
                  'Flexible Panel',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(12),
                  border: Border.all(),
                ),
                child: const Text(
                  'Panel',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompactLayout extends StatelessWidget {
  final String name;
  final String nim;

  const CompactLayout({
    super.key,
    required this.name,
    required this.nim,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Compact Layout',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(name),
            Text('NIM: $nim'),
            const SizedBox(height: 8),
            const Text(
              'Tampilan menggunakan layout satu kolom.',
            ),
          ],
        ),
      ),
    );
  }
}

class MediumLayout extends StatelessWidget {
  final String name;
  final String nim;

  const MediumLayout({
    super.key,
    required this.name,
    required this.nim,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Medium Layout',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(name),
            Text('NIM: $nim'),
            const SizedBox(height: 8),
            const Text(
              'Tampilan menggunakan ruang layar yang lebih luas.',
            ),
          ],
        ),
      ),
    );
  }
}

class ExpandedLayout extends StatelessWidget {
  final String name;
  final String nim;

  const ExpandedLayout({
    super.key,
    required this.name,
    required this.nim,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(
              Icons.desktop_windows,
              size: 40,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expanded Layout',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(name),
                  Text('NIM: $nim'),
                  const SizedBox(height: 4),
                  const Text(
                    'Tampilan untuk layar lebar dengan NavigationRail dan grid.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DebuggingPage extends StatefulWidget {
  final String studentName;
  final String studentId;

  const DebuggingPage({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<DebuggingPage> createState() =>
      _DebuggingPageState();
}

class _DebuggingPageState
    extends State<DebuggingPage> {
  bool isNavigating = false;

  Future<void> openDetail() async {
    if (isNavigating) {
      return;
    }

    setState(() {
      isNavigating = true;
    });

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DebugDetailPage(
          studentName: widget.studentName,
          studentId: widget.studentId,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {
      isNavigating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Debugging Challenge',
        ),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.studentName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            Text(
              'NIM: ${widget.studentId}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kasus A - RenderFlex Overflow',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Masalah diperbaiki menggunakan Expanded '
              'agar teks panjang mendapatkan ruang '
              'yang tersedia dan dapat berpindah baris.',
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${widget.studentId} - '
                        '${widget.studentName} - '
                        'Teks yang sangat panjang untuk '
                        'menguji RenderFlex overflow pada Row. '
                        'Dengan Expanded teks akan menyesuaikan '
                        'lebar yang tersedia.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kasus B - ListView dalam Column',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'ListView diberikan batas tinggi menggunakan '
              'SizedBox sehingga tidak mendapatkan '
              'unbounded height.',
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: ListView.builder(
                itemCount: 5,
                itemBuilder:
                    (context, index) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.book,
                      ),
                      title: Text(
                        'Course ${index + 1}',
                      ),
                      subtitle: Text(
                        '${widget.studentName} - '
                        '${widget.studentId}',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kasus C - Keyboard Overflow',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Halaman menggunakan SingleChildScrollView '
              'agar form tetap dapat diakses ketika '
              'keyboard muncul.',
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nama',
                border:
                    OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Komentar',
                border:
                    OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 300),
            const Text(
              'Kasus D - Navigasi Ganda',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tombol dinonaktifkan sementara ketika '
              'navigasi sedang berlangsung sehingga '
              'route tidak ter-push berkali-kali.',
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    isNavigating
                        ? null
                        : openDetail,
                icon: isNavigating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.open_in_new,
                      ),
                label: Text(
                  isNavigating
                      ? 'Membuka...'
                      : 'Buka Detail',
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class DebugDetailPage extends StatelessWidget {
  final String studentName;
  final String studentId;

  const DebugDetailPage({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Debug Detail',
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                size: 70,
              ),
              const SizedBox(height: 16),
              Text(
                studentName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              Text(
                'NIM: $studentId',
              ),
              const SizedBox(height: 24),
              const Text(
                'Navigasi berhasil dibuka.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Kembali',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}