import 'package:flutter/material.dart';
import 'package:intisave/pages/login_page.dart';
import 'db/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crear usuario inicial si no existe
  final db = DatabaseHelper.instance;
  final usuario = await db.getUsuario(1);
  if (usuario == null) {
    await db.insertUsuario({
      'nombre': 'Luis',
      'correo': 'luis@mail.com',
      'saldo': 0.0,
      'fecha_creacion': DateTime.now().toIso8601String(),
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IntiSave',
      theme: ThemeData(primaryColor: const Color(0xFF8B0000)),
      home: const LoginPage(),
    );
  }
}
