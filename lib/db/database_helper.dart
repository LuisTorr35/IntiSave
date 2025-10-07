import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ahorros.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const doubleType = 'REAL NOT NULL';

    // Tabla de usuarios
    await db.execute('''
    CREATE TABLE usuarios (
      id $idType,
      nombre $textType,
      correo TEXT,
      saldo $doubleType,
      fecha_creacion $textType
    )
    ''');

    // Tabla de ahorros/gastos
    await db.execute('''
    CREATE TABLE ahorros (
      id $idType,
      usuario_id INTEGER NOT NULL,
      tipo $textType, -- "Ingreso" o "Gasto"
      categoria $textType,
      monto $doubleType,
      descripcion TEXT,
      fecha $textType,
      FOREIGN KEY (usuario_id) REFERENCES usuarios (id) ON DELETE CASCADE
    )
    ''');
  }

  // ================================
  // MÉTODOS PARA USUARIOS
  // ================================
  Future<int> insertUsuario(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('usuarios', row);
  }

  Future<Map<String, dynamic>?> getUsuario(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'usuarios',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }



  Future<int> updateSaldo(int id, double nuevoSaldo) async {
    final db = await instance.database;
    return await db.update(
      'usuarios',
      {'saldo': nuevoSaldo},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================================
  // MÉTODOS PARA AHORROS (INGRESOS/GASTOS)
  // ================================
  Future<int> registrarAhorro(int usuarioId, String tipo, String categoria,
      double monto, String descripcion) async {
    final db = await instance.database;

    // Insertar en tabla ahorros
    final id = await db.insert('ahorros', {
      'usuario_id': usuarioId,
      'tipo': tipo,
      'categoria': categoria,
      'monto': monto,
      'descripcion': descripcion,
      'fecha': DateTime.now().toIso8601String(),
    });

    // Actualizar saldo en tabla usuarios
    final usuario = await getUsuario(usuarioId);
    if (usuario != null) {
      double saldoActual = usuario['saldo'];
      double nuevoSaldo =
      tipo == "Ingreso" ? saldoActual + monto : saldoActual - monto;
      await updateSaldo(usuarioId, nuevoSaldo);
    }

    return id;
  }

  Future<List<Map<String, dynamic>>> queryAllAhorros(int usuarioId) async {
    final db = await instance.database;
    return await db.query(
      'ahorros',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: "fecha DESC",
    );
  }
  // FUNCION PARA EXTRAER EL NOMBRE
  Future<String?> getNombreUsuario(int id) async {
    final db = await instance.database;
    final result = await db.query(
      'usuarios',
      columns: ['nombre'], // Solo seleccionamos el campo 'nombre'
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first['nombre'] as String;
    } else {
      return null; // Si no se encuentra el usuario
    }
  }
  Future<double> getTotalIngresos(int usuarioId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
    SELECT SUM(monto) as total 
    FROM ahorros 
    WHERE usuario_id = ? AND tipo = "Ingreso"
  ''', [usuarioId]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble(); // ✅ seguro
    }
    return 0.0;
  }

  Future<double> getTotalGastos(int usuarioId) async {
    final db = await instance.database;
    final result = await db.rawQuery('''
    SELECT SUM(monto) as total 
    FROM ahorros 
    WHERE usuario_id = ? AND tipo = "Gasto"
  ''', [usuarioId]);

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble(); // ✅ seguro
    }
    return 0.0;
  }
  // ================================
  // OBTENER LOS ÚLTIMOS 5 MOVIMIENTOS
  // ================================
  Future<List<Map<String, dynamic>>> getUltimosMovimientos(int usuarioId) async {
    final db = await instance.database;
    return await db.query(
      'ahorros',
      where: 'usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'fecha DESC',
      limit: 5,
    );
  }
  // ================================
  // Cerrar BD
  // ================================
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
