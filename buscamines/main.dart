import 'dart:io';
import 'dart:math';

void main() {
  Buscamines juego = Buscamines();
  juego.iniciar();
}

class Buscamines {
  static const int filas = 6;
  static const int columnas = 6;
  static const int minasTotales = 8;

  // Lo que el jugador ve en pantalla
  List<List<String>> tablero = List.generate(
    filas,
    (_) => List.generate(columnas, (_) => '·'),
  );

  // Donde están las minas
  List<List<bool>> minas = List.generate(
    filas,
    (_) => List.generate(columnas, (_) => false),
  );

  // Casillas destapadas
  List<List<bool>> destapadas = List.generate(
    filas,
    (_) => List.generate(columnas, (_) => false),
  );

  int movimientos = 0;

  // Iniciar juego
  void iniciar() {
    _colocarMinas();
    _jugar();
  }

  // Colocar minas aleatoriamente con al menos 2 por cuadrante
  void _colocarMinas() {
    Random rand = Random();
    int colocadas = 0;

    // cuadrantes para las minas
    List<List<int>> cuadrantes = [
      [0, 2, 0, 2],
      [0, 2, 3, 5],
      [3, 5, 3, 5],
    ];

    // pongo al menos 2 minas por cuadrante
    for (var c in cuadrantes) {
      int minasCuadrante = 0;
      while (minasCuadrante < 2) {
        int fila = rand.nextInt(c[1] - c[0] + 1) + c[0];
        int col = rand.nextInt(c[3] - c[2] + 1) + c[2];
        if (!minas[fila][col]) {
          minas[fila][col] = true;
          minasCuadrante++;
          colocadas++;
        }
      }
    }

    // Colocar las minas restantes aleatoriamente
    while (colocadas < minasTotales) {
      int fila = rand.nextInt(filas);
      int col = rand.nextInt(columnas);
      if (!minas[fila][col]) {
        minas[fila][col] = true;
        colocadas++;
      }
    }
  }

  // Mostrar el tablero
  void _mostrarTablero({bool mostrarMinas = false}) {
    stdout.write('  ');
    for (int c = 0; c < columnas; c++) {
      stdout.write('$c ');
    }
    print('');
    for (int f = 0; f < filas; f++) {
      stdout.write(String.fromCharCode(65 + f) + ' ');
      for (int c = 0; c < columnas; c++) {
        if (mostrarMinas && minas[f][c]) {
          stdout.write('* ');
        } else {
          stdout.write('${tablero[f][c]} ');
        }
      }
      print('');
    }
  }

  // Lógica principal del juego
  void _jugar() {
    while (true) {
      _mostrarTablero();
      stdout.write('Introduce acción (ej: B2, C3 flag, cheat, help): ');
      String? input = stdin.readLineSync();
      if (input == null || input.isEmpty) continue;
      input = input.toLowerCase().trim();

      if (input == 'help' || input == 'ajuda') {
        print('Comandos:');
        print('Seleccionar casilla: letra + número (B2, D5, ...)');
        print('Colocar bandera: letra + número + flag');
        print('Mostrar trampas: cheat');
        continue;
      }

      if (input == 'cheat' || input == 'trampes') {
        _mostrarTablero(mostrarMinas: true);
        continue;
      }

      // Detectar bandera
      bool esBandera = input.endsWith('flag') || input.endsWith('bandera');
      if (esBandera) input = input.split(' ')[0];

      if (input.length < 2) continue;

      int fila = input.codeUnitAt(0) - 97; // 'a' -> 0
      int col = int.tryParse(input.substring(1)) ?? -1;

      if (fila < 0 || fila >= filas || col < 0 || col >= columnas) continue;

      if (esBandera) {
        tablero[fila][col] = tablero[fila][col] == '#' ? '·' : '#';
        continue;
      }

      if (minas[fila][col]) {
        print('¡Boom! Has pisado una mina.');
        _mostrarTablero(mostrarMinas: true);
        print('Movimientos realizados: $movimientos');
        break;
      } else {
        _destapar(fila, col);
        movimientos++;
      }
    }
  }

  // Destapar casillas recursivamente
  void _destapar(int f, int c) {
    if (f < 0 || f >= filas || c < 0 || c >= columnas) return;
    if (destapadas[f][c] || tablero[f][c] == '#') return;

    destapadas[f][c] = true;

    // Contar minas alrededor
    int minasAlrededor = 0;
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        int nf = f + i;
        int nc = c + j;
        if (nf >= 0 &&
            nf < filas &&
            nc >= 0 &&
            nc < columnas &&
            minas[nf][nc]) {
          minasAlrededor++;
        }
      }
    }

    tablero[f][c] = minasAlrededor > 0 ? '$minasAlrededor' : ' ';

    if (minasAlrededor == 0) {
      for (int i = -1; i <= 1; i++) {
        for (int j = -1; j <= 1; j++) {
          if (i != 0 || j != 0) _destapar(f + i, c + j);
        }
      }
    }
  }
}
