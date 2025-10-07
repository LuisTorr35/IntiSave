import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import 'manualpage.dart';
import 'voice_page.dart';
import 'ahorro_compartido.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double _saldo = 0.0;
  double _ingresos = 0.0;
  double _gastos = 0.0;
  String _nombre = "";
  List<Map<String, dynamic>> _ultimosMovimientos = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
    _cargarNombre();
    _cargarUltimosMovimientos();
  }

  Future<void> _cargarDatos() async {
    final usuario = await DatabaseHelper.instance.getUsuario(1);
    final ingresos = await DatabaseHelper.instance.getTotalIngresos(1);
    final gastos = await DatabaseHelper.instance.getTotalGastos(1);

    setState(() {
      _saldo = usuario?['saldo'] ?? 0.0;
      _ingresos = ingresos;
      _gastos = gastos;
    });
  }

  Future<void> _cargarNombre() async {
    final nombre = await DatabaseHelper.instance.getNombreUsuario(1);
    setState(() {
      _nombre = nombre ?? "";
    });
  }

  Future<void> _cargarUltimosMovimientos() async {
    final movimientos = await DatabaseHelper.instance.getUltimosMovimientos(1);
    setState(() {
      _ultimosMovimientos = movimientos;
    });
  }

  void _mostrarOpciones() {
    showDialog(
      context: context,
      builder: (context) {
        return Stack(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(color: Colors.black54),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ManualPage()),
                        );
                        if (result == true) {
                          _cargarDatos();
                          _cargarUltimosMovimientos();
                        }
                      },
                      icon: const Icon(Icons.edit, color: Colors.white),
                      label: const Text("Ingreso manual", style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B0000),
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const VoicePage()),
                        );
                        _cargarDatos();
                        _cargarUltimosMovimientos();
                      },
                      icon: const Icon(Icons.mic, color: Colors.white),
                      label: const Text("Ingreso por voz", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const rojoInti = Color(0xFF8B0000);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: rojoInti,
        title: Row(
          children: [
            Image.asset('assets/IntiSave.png', height: 50),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bienvenido $_nombre",
                  style: const TextStyle(color: Colors.white),
                ),
                const Text(
                  "Hacia la libertad financiera",
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // =====================
              // CUADRO ROJO DE SALDOS
              // =====================
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
                decoration: BoxDecoration(
                  color: rojoInti,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Balance",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "S/. ${_saldo.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            const Text(
                              "Ingresos",
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            Text(
                              "S/. ${_ingresos.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Container(width: 1, height: 40, color: Colors.white38),
                        Column(
                          children: [
                            const Text(
                              "Gastos",
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                            Text(
                              "S/. ${_gastos.toStringAsFixed(2)}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // =====================
              // ÚLTIMOS MOVIMIENTOS
              // =====================
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Últimos movimientos",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: rojoInti,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              if (_ultimosMovimientos.isEmpty)
                const Text(
                  "No hay movimientos recientes.",
                  style: TextStyle(color: Colors.grey),
                )
              else
                Column(
                  children: _ultimosMovimientos.map((mov) {
                    bool esIngreso = mov['tipo'].toString().toLowerCase() == 'ingreso';
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 3,
                      child: ListTile(
                        leading: Icon(
                          esIngreso ? Icons.arrow_upward : Icons.arrow_downward,
                          color: esIngreso ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          mov['categoria'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          mov['descripcion'] ?? '',
                          style: const TextStyle(color: Colors.black54),
                        ),
                        trailing: Text(
                          "S/. ${mov['monto'].toStringAsFixed(2)}",
                          style: TextStyle(
                            color: esIngreso ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: rojoInti,
        child: const Icon(Icons.add),
        onPressed: _mostrarOpciones,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

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
                // Ya estamos en Home
              },
            ),
            IconButton(
              icon: const Icon(Icons.savings, color: rojoInti),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AhorroCompartidoPage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
