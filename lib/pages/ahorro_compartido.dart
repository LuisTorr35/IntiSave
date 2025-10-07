import 'package:flutter/material.dart';
import 'package:intisave/pages/home_page.dart';
import '../db/database_helper.dart';

class AhorroCompartidoPage extends StatelessWidget {
  const AhorroCompartidoPage({super.key});

  @override
  Widget build(BuildContext context) {
    const rojoInti = Color(0xFF8B0000);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ahorro compartido", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF8B0000),
      ),
      body: const Center(
        child: Text(
          "No tienes grupos de ahorro.",
          style: TextStyle(fontSize: 18, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ),
      // 🔻 Footer (barra inferior de navegación)
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: rojoInti),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.savings, color: rojoInti),
              onPressed: () {

              },
            ),
          ],
        ),
      ),
    );
  }
}
