import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

/// Titik akses data tugas.
///
/// Starter memakai memori agar aplikasi dapat langsung dijalankan. Lengkapi
/// TODO 2 dengan SharedPreferences dan JSON; jangan memindahkan akses storage
/// ke widget.
class TaskStorage {
  TaskStorage({this.loadDelay = const Duration(milliseconds: 450)});

  static List<Task> _memory = <Task>[];

  final Duration loadDelay;

  Future<List<Task>> load({bool simulateError = false}) async {
    await Future<void>.delayed(loadDelay);
    if (simulateError) {
      throw const FormatException('Simulasi data tersimpan yang rusak.');
    }

    // TODO 2a: baca String JSON dari SharedPreferences lalu ubah menjadi
    // List<Task> dengan Task.fromJson. JSON rusak dapat menghasilkan
    // FormatException agar UI menampilkan state error.
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('tasks_json');

    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        throw const FormatException('Format data tugas tidak valid.');
      }

      _memory = decoded.map((item) {
        if (item is! Map) {
          throw const FormatException('Data tugas tidak valid.');
        }
        return Task.fromJson(Map<String, dynamic>.from(item));
      }).toList();
    } else {
      _memory = <Task>[];
    }

    return List<Task>.of(_memory);
  }

  Future<void> save(List<Task> tasks) async {
    // TODO 2b: encode seluruh daftar sebagai JSON String dan tulis melalui
    // SharedPreferences. Periksa nilai bool yang dikembalikan setString.
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(tasks.map((task) => task.toJson()).toList());
    final success = await prefs.setString('tasks_json', raw);

    if (!success) {
      throw StateError('Gagal menyimpan daftar tugas.');
    }

    _memory = List<Task>.of(tasks);
  }

  Future<void> clear() async {
    // TODO 2c: hapus key daftar tugas dari SharedPreferences.
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tasks_json');

    _memory = <Task>[];
  }

  /// Hanya untuk mengisolasi pengujian lokal.
  static void resetMemoryForTest() => _memory = <Task>[];
}