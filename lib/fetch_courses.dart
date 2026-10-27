
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

const String apiUrl = 'https://jsonplaceholder.typicode.com/posts';

Future<List<dynamic>> fetchCourses() async {
  final response = await http.get(Uri.parse(apiUrl));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as List<dynamic>;

    debugPrint('Jumlah data diterima: ${data.length}');
    return data;
  }

  throw Exception('HTTP ${response.statusCode}');
}
