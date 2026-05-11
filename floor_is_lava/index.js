const fs = require("fs").promises;
const readline = require("readline");

// --- CONFIGURACIÓN DEL TABLERO ---
const FILAS = 6;
const COLUMNAS = 8;
const TOTAL_LAVA = 16;
const MAX_PASSES = 32;
const FILAS_LETRAS = ["A", "B", "C", "D", "E", "F"];

let matriz = [];
let posJugador = { fila: 0, col: 0 };
let puntosRestantes = MAX_PASSES;
let lavaVisible = false;

// tablero
function crearTablero() {
    matriz = Array.from({ length: FILAS }, () => Array(COLUMNAS).fill("·"));
    posJugador = { fila: 0, col: 0 };
    puntosRestantes = MAX_PASSES;
    lavaVisible = false;

    matriz[0][0] = "T";
    matriz[5][7] = "*";

    let lavaColocada = 0;
    while (lavaColocada < TOTAL_LAVA) {
        const fila = Math.floor(Math.random() * FILAS);
        const col = Math.floor(Math.random() * COLUMNAS);
        // Evitamos poner lava donde está el jugador o el tesoro
        if (matriz[fila][col] === "·") {
            matriz[fila][col] = "L";
            lavaColocada++;
        }
    }
}

function mostrarTablero() {
    console.clear();
    console.log("--- EL SUELO ES LAVA ---");
    let header = "  " + Array.from({ length: COLUMNAS }, (_, i) => i).join(" ");
    console.log(header);

    for (let i = 0; i < FILAS; i++) {
        let filaStr = FILAS_LETRAS[i] + " ";
        for (let j = 0; j < COLUMNAS; j++) {
            const celda = matriz[i][j];
            // Si es lava y la trampa no está activada, mostramos un punto
            if (celda === "L" && !lavaVisible) {
                filaStr += "· ";
            } else {
                filaStr += celda + " ";
            }
        }
        console.log(filaStr);
    }
    console.log(`\nPunts restants: ${puntosRestantes}`);
    console.log(`Distància al tresor: ${distancia({ fila: 5, col: 7 })}`);
}

function distancia(destino) {
    return Math.abs(posJugador.fila - destino.fila) + Math.abs(posJugador.col - destino.col);
}

// --- Movimiento ---
async function caminar(direccion) {
    let { fila, col } = posJugador;

    switch (direccion.toLowerCase()) {
        case "amunt": fila--; break;
        case "avall": fila++; break;
        case "dreta": col++; break;
        case "esquerra": col--; break;
        default:
            console.log("Direcció desconeguda. Usa amunt/avall/dreta/esquerra");
            return;
    }

    // Comprobar si se sale del tablero
    if (fila < 0 || fila >= FILAS || col < 0 || col >= COLUMNAS) {
        console.log("¡HAS PERDUT! Has caigut per un penyasegat.");
        process.exit(0);
    }

    const casilla = matriz[fila][col];

    if (casilla === "L") {
        puntosRestantes--;
        if (puntosRestantes <= 0) {
            console.log("¡BOOM! Massa lava, t'has quedat sense punts.");
            process.exit(0);
        }
    } else if (casilla === "*") {
        console.log("¡HAS GUANYAT! Has trobat el tresor.");
        process.exit(0);
    }

    // Actualizar posiciones en la matriz
    matriz[posJugador.fila][posJugador.col] = "·";
    matriz[fila][col] = "T";
    posJugador = { fila, col };

    mostrarTablero();
}

// --- Procesar comandos ---
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
    prompt: "Comanda (caminar [dir] / trampa / ajuda): "
});

async function procesarComando(input) {
    const parts = input.trim().split(" ");
    const comando = parts[0].toLowerCase();
    const arg = parts[1];

    switch (comando) {
        case "ajuda":
            console.log("\nInstruccions:\n- caminar <amunt/avall/dreta/esquerra>\n- trampa (activa/desactiva visibilitat)\n- sortir");
            break;

        case "caminar":
            if (!arg) console.log("Indica direcció!");
            else await caminar(arg);
            break;

        case "trampa":
            lavaVisible = !lavaVisible;
            mostrarTablero();
            break;

        case "sortir":
            process.exit(0);
            break;

        default:
            console.log("Comanda no vàlida. Escriu 'ajuda'.");
    }
}


crearTablero();
mostrarTablero();
rl.prompt();

rl.on("line", async (line) => {
    await procesarComando(line);
    rl.prompt();
});